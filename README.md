# ClientFlow AI

Client Systems. AI Workflows.

Premium responsive landing page and multi-venture client operating system, upgraded with Hallmark 2. This public repository is the shared handoff for Tiny and collaborating agents. Work is in progress; external integrations require setup.

## Start locally

Use Node.js 24 (recommended; built-in SQLite). No npm dependencies are required.

```sh
git clone https://github.com/tinyrassmann-tweek/clientflow-ai-hallmark.git
cd clientflow-ai-hallmark
npm test
npm run build
npm run dev
```

Open http://localhost:3000 for the landing page and http://localhost:3000/app for the saved local workspace. Development supplies a local owner identity and stores data in `.local/`; use it locally only. `/app?demo=1` is an isolated sample workspace.

## Included

| Location | Contents |
| --- | --- |
| `public/` | Landing page, app, login, responsive CSS, motion, custom logo, generated imagery, screenshots and manifest |
| `src/` | API/domain logic and storage adapters |
| `scripts/` | Node server, Worker builder, preview packager and Google Cloud deployment script |
| `tests/` | Domain and security regression tests |
| `dist/` | Committed deployable Worker build and hosting metadata |
| `drizzle/` | D1 database migration |
| `deliverables/` | Standalone landing/app previews, comparison, launch guide and complete ZIP |
| `.hallmark/`, `design.md` | Design decisions, review evidence and version provenance |
| `LAUNCH-GUIDE.html` | Detailed setup, deployment and feature status |
| `AGENTS.md` | Handoff instructions for collaborating agents |

Download and open HTML files in `deliverables/` for self-contained previews. The downloaded landing preview directs submissions to the hosted application. The app preview uses sample data, not a shared production database.

## Working now

Lead validation and persistence; workspace records; CRM stages; offers; eight specialist templates; optional AI drafting; manual workflow checklists; approval and staging; deployment URL recording; insights; tenant-scoped memberships and revocable invitations.

Nine tests cover lead persistence, tenant isolation, roles, invitation use/revocation, approval gates, stale updates and cross-origin protection.

## External setup still required

- AI: configure `OPENAI_API_KEY` for live generation. No live provider call was verified.
- Payments: Stripe checkout links/price IDs are not connected.
- Google Cloud: Cloud Run source, Dockerfile and deployment script are included. An existing project, Firestore, Firebase email/password authentication and runtime configuration are required. No Google Cloud deployment has been completed from this repository.
- Automation: native CRM sync, autonomous email/booking and direct publishing are not implemented. Workflow and deployment tracking are manual.

The existing Sites deployment uses authenticated access and D1. `.openai/hosting.json` identifies that existing project; reuse it only when authorized to update that Site. Repository public visibility does not change the live Site audience.

## Deployment

For Google Cloud, read `LAUNCH-GUIDE.html` and `.env.example`; use `scripts/deploy-google.sh` in Cloud Shell after supplying documented environment variables. Never commit real secrets. Cloud resources can incur charges; the script is provided, not run automatically.

For the existing Sites Worker, `npm run build` emits `dist/server/index.js`; database binding is `DB`, with migrations in `drizzle/`.

## Provenance

Exported from Site source commit `52b0d675a7c0480e6f6b3820b5fb3e4ab1a453a7`, with documentation and portable packaging added. Hallmark 2 revision: `407fa689f4a276f2fd389208d271d0fef08f5058` (https://github.com/nutlope/hallmark).

Runtime databases, real environment files, credentials, dependency folders and unrelated venture files are excluded. Public visibility is for collaboration while the project is being completed. This handoff does not assign an open-source license.
