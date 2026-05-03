---
name: iOS SourceKit false positives
description: SourceKit shows many "Cannot find type X in scope" errors for cross-file Swift types — builds still succeed
type: feedback
originSessionId: 8ccd2e6c-9a9d-470a-adb3-7ee2aa89375e
---
SourceKit (the IDE language server) consistently shows "Cannot find type X in scope" errors for types defined in other Swift files (e.g., APIClient, ChatHistoryItem, Agent, UIImagePickerController, UIColor). These are false positives.

**Why:** SourceKit indexes files in isolation without full project context; Xcode's build system resolves cross-file references correctly.

**How to apply:** When SourceKit diagnostics appear in the conversation, DO NOT treat them as build errors. Verify correctness with `xcodebuild ... build 2>&1 | grep "error:\|BUILD"` instead. If build succeeds, ignore SourceKit warnings and proceed.
