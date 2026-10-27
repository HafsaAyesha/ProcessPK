# ProcessPK Ask API (Cloudflare Worker)

Answers questions about one guide with Google Gemini, using only that guide's
content from `../assets/guides.json`. The Gemini key is stored as a Cloudflare
secret, never in the app.

## Deploy (about 10 minutes)

Needs Node.js 20 or newer (wrangler is pinned to 4.86.0, the last version tested on Node 20).

```
cd worker
npm install
npx wrangler login                     # opens Cloudflare in your browser
npx wrangler secret put GEMINI_API_KEY # paste your Gemini key when asked
npx wrangler deploy
```

`deploy` prints your URL, e.g. `https://processpk-ask.yourname.workers.dev`.
Check it works by opening that URL: it shows `{"ok":true,"guides":9}`.

Then put the URL in `lib/config.dart` (`aiEndpoint`) and rebuild the app.
The "Ask ProcessPK" button appears on every guide.

Re-run `npx wrangler deploy` whenever you change `assets/guides.json`, so the
AI answers from the latest guides.

## Limits

- Each phone gets 5 free questions a day (`aiDailyLimit` in `lib/config.dart`).
- Each IP address can ask at most 10 questions a minute (`wrangler.toml`).
- To change the Gemini model, edit `GEMINI_MODEL` in `wrangler.toml`.

## Test

```
npm test
```
