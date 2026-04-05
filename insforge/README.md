# InsForge integration (Fiora)

This folder complements the runnable API in `/backend`. [InsForge](https://docs.insforge.dev/introduction) is a BaaS with **PostgreSQL**, **JWT authentication**, **Realtime WebSockets**, **Edge Functions (Deno)**, **AI completions**, and **S3-compatible storage**.

## MCP note

The InsForge MCP `fetch-docs` tool was not available in the build environment; the implementation follows the public index at [docs.insforge.dev/llms.txt](https://docs.insforge.dev/llms.txt) (authentication, database records, realtime channels, functions, AI API).

## When to use InsForge vs MongoDB Atlas

- **MongoDB Atlas + FastAPI (`/backend`)**: Best fit for this repository’s deployable service, Python ML microservices, and flexible health documents.
- **InsForge PostgreSQL**: Use `schema.sql` here if you want managed tables-as-API, InsForge Realtime, and InsForge Auth as the source of truth. You can keep FastAPI only for heavy ML or WebSocket bridges, or replace it gradually.

## Mapping features

| Feature | InsForge capability | Notes |
|--------|---------------------|--------|
| JWT auth | Built-in login/register/refresh | Flutter can use [Kotlin](https://docs.insforge.dev/sdks/kotlin/overview) / [Swift](https://docs.insforge.dev/sdks/swift/overview) SDKs. |
| Magic.link | Custom OAuth or DID verification in an Edge Function | Mirror `/api/v1/auth/magic` behaviour; validate DID server-side, then call InsForge register/login or mint a session. |
| Profiles & partners | `fiora_profiles` table + JSON `partners` | Use record APIs; add RLS policies per user. |
| Period tracking & prediction | `fiora_period_entries` + scheduled Function | Run cycle math in a Function or call your Fiora ML URL. |
| HealthKit / Health Connect | Client → your API → `fiora_wearable_events` | Batch uploads from the Flutter app. |
| Anomaly / Fiora ML | Edge Function `POST` proxy to `FIORA_ML_URL` | Keeps API keys in InsForge secrets. |
| Gemini questions | InsForge AI API or Function calling Google | Same prompts as `app/services/gemini_client.py`. |
| Points | `fiora_points_ledger` | Sum `delta` per user for balance. |
| Exercise | Static config in app or a small table | Same JSON shape as `/api/v1/exercise/recommendations`. |
| Chat + voice | Realtime channels + AI stream; ElevenLabs in a Function | Do not expose ElevenLabs keys to clients. |

## OpenAPI

InsForge publishes OpenAPI fragments (see “OpenAPI Specs” in [llms.txt](https://docs.insforge.dev/llms.txt)) for auth, records, AI, realtime, and storage.

## Security

Follow [Deployment security guide](https://docs.insforge.dev/deployment/deployment-security-guide.md): least-privilege API keys, RLS on tables, secrets for third-party keys, and rate limits at the edge or gateway.
