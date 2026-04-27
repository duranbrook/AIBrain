---
name: iOS inspection uses quotes flow not sessions flow
description: The iOS app goes through PUT /quotes/{id}/finalize to generate reports, not POST /sessions/{id}/generate-report
type: feedback
originSessionId: b58a326c-c2f8-42fe-9d78-e704ccab5080
---
The iOS app uses the QUOTES flow (PUT /quotes/{id}/finalize), not the SESSIONS flow (POST /sessions/{id}/generate-report). Any backend fix to sessions.py alone will not affect iOS behavior.

**Why:** The iOS SessionAPI.swift calls `finalizeQuote()` → `/quotes/{id}/finalize`. The sessions generate-report endpoint is only used by the web app.

**How to apply:** When fixing report generation bugs that the user reports via iOS testing, always check quotes.py::finalize_quote as the entry point, not sessions.py::generate_report.
