# ClientFlow AI agent handoff

Read README.md and LAUNCH-GUIDE.html before changing the app. Preserve the custom logo, cream/navy/gold brand, responsive behavior, reduced-motion support and agreed license tiers.

- Work from a branch. Preserve other agents' changes; do not force-push main.
- Use Node 24. No dependency installation required. Run `npm test` and `npm run build` after behavioral changes. Commit regenerated `dist/` with relevant source updates.
- Preserve tenant isolation, role checks, single-use invitations, CSRF protection, optimistic concurrency and approval gates. Development supplies an owner identity; never expose the development server publicly.
- `.openai/hosting.json` identifies the existing Site. Do not create a replacement Site, change audience, deploy to production, provision billable infrastructure or connect payments without task authorization.
- Keep secrets, `.env`, `.local/`, real client/lead records and credentials out of commits/screenshots. `.env.example` contains variable names only.
- Do not describe disconnected integrations or manual steps as live automation. Record remaining work and test evidence.
- `python scripts/deliverables.py` refreshes previews and ZIP. Update/preserve the comparison HTML separately when designs change.
