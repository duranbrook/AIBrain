---
name: Presigned S3 URLs must not be used as identifiers — use stable S3 URLs
description: Storing presigned URLs as photo identifiers causes all comparisons to fail because presigned URLs change every request
type: feedback
originSessionId: b58a326c-c2f8-42fe-9d78-e704ccab5080
---
Never store presigned S3 URLs as identifiers in DB records (e.g. findings.photo_url). Presigned URLs include a time-limited signature that changes every time you call `presigned_url()`, so string comparison between a stored presigned URL and a freshly-generated one always fails.

**Why:** This caused all photos to fall into the "unassigned gallery" section of the PDF because `assigned_photo_urls` (set from stored presigned URLs) never matched `media_urls` (freshly generated presigned URLs).

**How to apply:** Always store the original stable S3 URL (e.g. `https://pitagents.s3.us-east-1.amazonaws.com/session/media/file.jpg`) in DB fields. Generate presigned URLs fresh at render/fetch time only. When Claude is given presigned URLs as image sources (for download), give it the stable S3 URL as the identifier to write in output fields.
