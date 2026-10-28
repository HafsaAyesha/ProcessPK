// ProcessPK "Ask" API: answers a question about one guide using Gemini,
// grounded only in that guide's verified content. The Gemini key stays
// here as a Cloudflare secret and never ships inside the app.
import data from '../../assets/guides.json' with { type: 'json' };

const guides = new Map(data.guides.map((g) => [g.id, g]));

const MAX_QUESTION_CHARS = 500;

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS },
  });
}

/** Turns one guide into plain text the model can quote from. */
export function guideToContext(guide, lang) {
  const t = guide[lang] ?? guide.en;
  const lines = [
    `Title: ${t.title}`,
    `Summary: ${t.summary}`,
    `What it is: ${t.what}`,
    `Who needs it: ${t.who}`,
    'Required documents:',
    ...t.documents.map((d) => `- ${d}`),
    `Fees: ${t.fees}`,
    `Estimated time: ${t.time}`,
    'Steps:',
    ...t.steps.map((s, i) => `${i + 1}. ${s}`),
    'Common mistakes:',
    ...t.mistakes.map((m) => `- ${m}`),
    'Problems people face and fixes:',
    ...(t.problems ?? []).map((p) => `- Problem: ${p.problem} Fix: ${p.solution}`),
    'Contacts:',
    ...(guide.contacts ?? []).map((c) =>
      `- ${c.name}: ${[c.phone, c.email, c.url, c.note].filter(Boolean).join(', ')}`),
    'Official sources:',
    ...guide.sources.map((s) => `- ${s.name}: ${s.url}`),
    `Last verified: ${guide.lastVerified ?? 'not yet verified'}`,
  ];
  return lines.join('\n');
}

export function systemPrompt(guide, lang) {
  const language = lang === 'ur' ? 'Urdu (in Urdu script)' : 'English';
  const others = data.guides
    .filter((g) => g.id !== guide.id)
    .map((g) => `- ${(g[lang] ?? g.en).title}`)
    .join('\n');
  return [
    'You are ProcessPK, a friendly helper for students and young people in Pakistan dealing with government and education processes.',
    'Facts: use ONLY the GUIDE below for fees, dates, documents, offices, phone numbers, links and rules. Never invent or guess any of these.',
    'If the guide does not contain the answer, say plainly that ProcessPK cannot verify this, then point to the most relevant contact or official source from the guide.',
    'You may add one short practical tip (for example: go early, keep photocopies, save the tracking number), labelled "Tip:", as long as it does not state a new fact.',
    'How to answer:',
    '1. Start with the direct answer in one sentence.',
    '2. Then give the details as a short numbered list or 2 to 4 short lines. Refer to the guide\'s step numbers when useful ("see step 3").',
    '3. If the user is stuck or something went wrong, use the "Problems people face" section and the contacts.',
    '4. Keep it under 120 words. Use simple words a 16 year old understands.',
    'Formatting: plain text only. No markdown, no asterisks, no bold, no headings, no tables. Use "1." for lists and "- " for bullets.',
    `Reply in ${language}, even if the question is written in Roman Urdu or mixed language.`,
    'If the question is about a different process, say so briefly and name the matching ProcessPK guide from this list if there is one:',
    others,
    'ProcessPK is independent and not affiliated with the Government of Pakistan. Never claim otherwise.',
    '',
    'GUIDE:',
    guideToContext(guide, lang),
  ].join('\n');
}

const MAX_HISTORY = 6;

/** Keeps only well-formed recent turns so follow-up questions have context. */
export function cleanHistory(history) {
  if (!Array.isArray(history)) return [];
  return history
    .filter((h) => h && typeof h.q === 'string' && typeof h.a === 'string')
    .slice(-MAX_HISTORY)
    .flatMap((h) => [
      { role: 'user', parts: [{ text: h.q.slice(0, MAX_QUESTION_CHARS) }] },
      { role: 'model', parts: [{ text: h.a.slice(0, 2000) }] },
    ]);
}

/** Removes markdown the app would otherwise show as raw symbols. */
export function toPlainText(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '$1')
    .replace(/__(.+?)__/g, '$1')
    .replace(/^#{1,6}\s*/gm, '')
    .replace(/^\s*[*•]\s+/gm, '- ')
    .replace(/(^|\s)\*(\S[^*]*?)\*(?=\s|$|[.,!?])/g, '$1$2')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

async function askGemini(env, guide, question, lang, history) {
  const model = env.GEMINI_MODEL || 'gemini-3.8-flash';
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': env.GEMINI_API_KEY,
    },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: systemPrompt(guide, lang) }] },
      contents: [
        ...cleanHistory(history),
        { role: 'user', parts: [{ text: question }] },
      ],
      // Room for the model's internal reasoning so answers are not cut off.
      generationConfig: { temperature: 0.3, maxOutputTokens: 4096 },
    }),
  });
  if (!res.ok) {
    throw new Error(`Gemini returned ${res.status}: ${(await res.text()).slice(0, 300)}`);
  }
  const body = await res.json();
  const text = (body.candidates?.[0]?.content?.parts ?? [])
    .filter((p) => !p.thought)
    .map((p) => p.text ?? '')
    .join('')
    .trim();
  if (!text) throw new Error('Gemini returned an empty answer');
  return toPlainText(text);
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return new Response(null, { headers: CORS });
    const { pathname } = new URL(request.url);
    if (request.method === 'GET' && pathname === '/') {
      return json({ ok: true, guides: guides.size });
    }
    if (request.method !== 'POST' || pathname !== '/ask') {
      return json({ error: 'not_found' }, 404);
    }

    // Short-window abuse protection per IP (configured in wrangler.toml).
    if (env.LIMITER) {
      const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
      const { success } = await env.LIMITER.limit({ key: ip });
      if (!success) return json({ error: 'rate_limited' }, 429);
    }

    let input;
    try {
      input = await request.json();
    } catch {
      return json({ error: 'bad_request' }, 400);
    }
    const guide = guides.get(input?.guideId);
    const question = String(input?.question ?? '').trim();
    const lang = input?.lang === 'ur' ? 'ur' : 'en';
    if (!guide) return json({ error: 'unknown_guide' }, 400);
    if (!question || question.length > MAX_QUESTION_CHARS) {
      return json({ error: 'bad_question' }, 400);
    }
    if (!env.GEMINI_API_KEY) return json({ error: 'not_configured' }, 500);

    try {
      const answer = await askGemini(env, guide, question, lang, input?.history);
      return json({
        answer,
        guideTitle: (guide[lang] ?? guide.en).title,
        lastVerified: guide.lastVerified ?? null,
        sources: guide.sources,
      });
    } catch (e) {
      console.error(e);
      return json({ error: 'ai_failed' }, 502);
    }
  },
};
