# Memory Index

- [Project Architecture](project_architecture.md) — LangGraph ReAct agents, Qdrant, SSE streaming, BMW ETK parts catalog
- [User Profile](user_profile.md) — auto-shop AI product, willing to pay for data, prefers running systems over cut-corner designs
- [Autonomy Preference](feedback_autonomy.md) — act and build without asking; only stop for irreversible/dangerous ops
- [iOS API Flow](feedback_ios_api_flow.md) — iOS report generation goes through PUT /quotes/{id}/finalize (quotes.py), not POST /sessions/{id}/generate-report (sessions.py)
- [Presigned URL Pitfalls](feedback_presigned_url_pitfalls.md) — never store presigned S3 URLs as identifiers in DB; always store stable S3 URLs and generate presigned URLs fresh at render time
