# Memory Index

- [Project Architecture](project_architecture.md) — LangGraph ReAct agents, Qdrant, SSE streaming, BMW ETK parts catalog
- [User Profile](user_profile.md) — auto-shop AI product, willing to pay for data, prefers running systems over cut-corner designs
- [Autonomy Preference](feedback_autonomy.md) — act and build without asking; only stop for irreversible/dangerous ops
- [iOS API Flow](feedback_ios_api_flow.md) — iOS report generation goes through PUT /quotes/{id}/finalize (quotes.py), not POST /sessions/{id}/generate-report (sessions.py)
- [Presigned URL Pitfalls](feedback_presigned_url_pitfalls.md) — never store presigned S3 URLs as identifiers in DB; always store stable S3 URLs and generate presigned URLs fresh at render time
- [React Infinite Loop Debugging](feedback_react_infinite_loop_debugging.md) — all-200s + blank page = JS runtime error; React #185 = unstable useMemo deps; check Console first, not Network tab
- [Vercel Next.js Subdir Deployment](feedback_vercel_nextjs_subdir.md) — don't place vercel.json in web/ when Vercel root is web/; use vercel --prod --force when GitHub integration breaks
- [Alembic migration chain tip](alembic_migration_chain.md) — true head is revision 0023, not the hash file 9c5e490936db
- [iOS SourceKit false positives](feedback_ios_sourcekit.md) — ignore SourceKit "Cannot find type" errors; verify with xcodebuild
- [Homepage/Login/Demo feature progress](project_homepage_login_demo.md) — all code done on feat/ios-technician-chat, awaiting Google Cloud Console OAuth setup from user
- [Product Vision — Three Pillars](project_product_vision.md) — AI technician, owner AI crew, consumer vehicle history + connected ecosystem
