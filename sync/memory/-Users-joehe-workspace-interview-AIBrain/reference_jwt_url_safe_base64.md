---
name: JWT URL-safe base64 trap
description: Swift `Data(base64Encoded:)` rejects URL-safe base64 (`-`/`_`) — JWT payloads decode to nil silently. Convert before decoding.
type: reference
originSessionId: b5fa9f85-cee3-44ee-bed5-07f219e2bd47
---
JWT payload segments are URL-safe base64: `+`→`-`, `/`→`_`. Many language stdlibs decode standard base64 only and silently return nil on URL-safe input.

**The trap:** the bug only surfaces when a particular token's bytes happen to use `-` or `_`. Since these are byte-position-dependent, your dev token may decode fine while the user's token (different `iat`/`sub`) does not. Unit tests with a fixed token can pass while production fails.

**Per-platform fix:**
- **Swift / iOS** — `Data(base64Encoded:)` is standard base64. Before decoding, replace:
  ```swift
  base64 = base64.replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
  ```
  Or use a JWT library (e.g., `JWTDecode.swift`) that handles this for you.
- **Kotlin / Android** — `android.util.Base64` has `URL_SAFE` mode (use it). `java.util.Base64.getUrlDecoder()` is the JVM equivalent.
- **Python** — `base64.urlsafe_b64decode` (note the `urlsafe_`).
- **JS** — atob() is standard; for URL-safe, replace before decoding or use `Buffer.from(s, 'base64url')` in Node 16+.

**Symptom of the bug in an app:** Profile/account fields that read from JWT claims (`email`, `role`, etc.) are blank for *some* users — never an error, just empty strings. Easy to misdiagnose as "the backend forgot to set the claim."

**Padding is a separate issue** but often appears together. After the URL-safe character substitution, also pad to a multiple of 4 with `=`.
