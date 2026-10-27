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

export function systemPrompt(lang) {
  const language = lang === 'ur' ? 'Urdu (in Urdu script)' : 'English';
  return [
    'You are ProcessPK, a helper for young people in Pakistan dealing with government and education processes.',
    'Answer ONLY using the guide provided below. Do not use outside knowledge, and never invent fees, dates, phone numbers or rules.',
    'If the guide does not contain the answer, say clearly that ProcessPK cannot verify this, and tell the user to check the official source listed in the guide.',
    'ProcessPK is independent and not affiliated with the Government of Pakistan. Never claim otherwise.',
    `Reply in ${language}. Keep it short: at most 6 sentences or a short numbered list. Use simple words.`,
    'If the question is unrelated to this guide, politely say you can only help with this guide.',
  ].join('\n');
}

async function askGemini(env, guide, question, lang) {
  const model = env.GEMINI_MODEL || 'gemini-2.5-flash';
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': env.GEMINI_API_KEY,
    },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: systemPrompt(lang) }] },
      contents: [{
        role: 'user',
        parts: [{ text: `GUIDE:\n${guideToContext(guide, lang)}\n\nQUESTION:\n${question}` }],
      }],
      generationConfig: { temperature: 0.2, maxOutputTokens: 800 },
    }),
  });
  if (!res.ok) {
    throw new Error(`Gemini returned ${res.status}: ${(await res.text()).slice(0, 300)}`);
  }
  const body = await res.json();
  const text = (body.candidates?.[0]?.content?.parts ?? [])
    .map((p) => p.text ?? '')
    .join('')
    .trim();
  if (!text) throw new Error('Gemini returned an empty answer');
  return text;
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
      const answer = await askGemini(env, guide, question, lang);
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
