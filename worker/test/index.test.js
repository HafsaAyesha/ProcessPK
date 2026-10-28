import { test } from 'node:test';
import assert from 'node:assert/strict';
import worker from '../src/index.js';

const env = { GEMINI_API_KEY: 'test-key', GEMINI_MODEL: 'gemini-test' };

function ask(body) {
  return new Request('https://x.workers.dev/ask', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

test('answers using only the chosen guide', async () => {
  let sent;
  globalThis.fetch = async (url, init) => {
    sent = { url, init, body: JSON.parse(init.body) };
    return new Response(JSON.stringify({
      candidates: [{ content: { parts: [{ text: 'Call 7000.' }] } }],
    }));
  };
  const res = await worker.fetch(ask({ guideId: 'first-cnic', question: 'Helpline?', lang: 'en' }), env);
  assert.equal(res.status, 200);
  const out = await res.json();
  assert.equal(out.answer, 'Call 7000.');
  assert.equal(out.guideTitle, 'Get your first CNIC');
  assert.ok(out.sources.length > 0);
  assert.match(sent.url, /gemini-test:generateContent/);
  assert.equal(sent.init.headers['x-goog-api-key'], 'test-key');
  const prompt = sent.body.systemInstruction.parts[0].text;
  assert.match(prompt, /051-111-786-100/);
  assert.doesNotMatch(prompt, /dgip\.gov/i);
  assert.equal(sent.body.contents.at(-1).parts[0].text, 'Helpline?');
});

test('Urdu questions get the Urdu guide and an Urdu reply instruction', async () => {
  let body;
  globalThis.fetch = async (_u, init) => {
    body = JSON.parse(init.body);
    return new Response(JSON.stringify({ candidates: [{ content: { parts: [{ text: 'جواب' }] } }] }));
  };
  const res = await worker.fetch(ask({ guideId: 'first-cnic', question: 'فیس؟', lang: 'ur' }), env);
  assert.equal(res.status, 200);
  assert.match(body.systemInstruction.parts[0].text, /Urdu/);
  assert.match(body.systemInstruction.parts[0].text, /شناختی کارڈ/);
});

test('rejects unknown guides, empty questions and missing key', async () => {
  assert.equal((await worker.fetch(ask({ guideId: 'nope', question: 'hi' }), env)).status, 400);
  assert.equal((await worker.fetch(ask({ guideId: 'first-cnic', question: ' ' }), env)).status, 400);
  assert.equal((await worker.fetch(ask({ guideId: 'first-cnic', question: 'x'.repeat(501) }), env)).status, 400);
  assert.equal((await worker.fetch(ask({ guideId: 'first-cnic', question: 'hi' }), {})).status, 500);
});

test('reports AI failures as 502 and respects the rate limiter', async () => {
  globalThis.fetch = async () => new Response('boom', { status: 500 });
  const orig = console.error;
  console.error = () => {};
  assert.equal((await worker.fetch(ask({ guideId: 'first-cnic', question: 'hi' }), env)).status, 502);
  console.error = orig;
  const limited = { ...env, LIMITER: { limit: async () => ({ success: false }) } };
  assert.equal((await worker.fetch(ask({ guideId: 'first-cnic', question: 'hi' }), limited)).status, 429);
});

test('sends recent follow-up history and strips markdown from answers', async () => {
  let body;
  globalThis.fetch = async (_u, init) => {
    body = JSON.parse(init.body);
    return new Response(JSON.stringify({ candidates: [{ content: { parts: [
      { text: 'thinking', thought: true },
      { text: '**Fee:** free\n* bring B-Form' },
    ] } }] }));
  };
  const history = [{ q: 'What docs?', a: 'B-Form.' }, { bad: true }];
  const res = await worker.fetch(ask({ guideId: 'first-cnic', question: 'And fee?', lang: 'en', history }), env);
  const out = await res.json();
  assert.equal(out.answer, 'Fee: free\n- bring B-Form');
  assert.deepEqual(body.contents.map((c) => c.role), ['user', 'model', 'user']);
  assert.equal(body.contents[1].parts[0].text, 'B-Form.');
});
