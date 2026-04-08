---
name: iOS SwiftUI patterns for BuildCo
description: Swift/SwiftUI conventions used in the buildco-ios app
type: feedback
---

Use xcodegen for all project structure changes. Never hand-edit `.pbxproj`.

**Why:** `.pbxproj` is fragile XML. xcodegen + `project.yml` is the source of truth.

**How to apply:** After any structural change (new file group, new target, new dependency), run `xcodegen generate` from `/workspace/buildco-ios`.

## Key patterns

**Auth state:** Single `AuthStore` (`@MainActor`, `ObservableObject`) injected as `@EnvironmentObject`. Token stored in Keychain via Security framework directly (not a library).

**Navigation:** `NavigationStack` at root. All screens use `NavigationLink` or `navigationDestination`. `RootView` decides authenticated vs unauthenticated stack.

**API calls:** `APIClient` is an `actor` singleton. All requests go through `request<T: Decodable>(path:method:body:token:)`.

**SSE streaming:** `SSEClient.stream()` returns `AsyncThrowingStream<String, Error>` using `URLSession.bytes(for:)` and iterating `.lines`.

**Clean test state:** App checks `CommandLine.arguments.contains("--uitesting")` on init and calls `Keychain.delete()`. UI tests launch with `app.launchArguments = ["--uitesting"]`.

**Accessibility identifiers:** All interactive elements get `.accessibilityIdentifier("...")`. Convention: `btn_` for buttons, `field_` for inputs, `lbl_` for labels, `employee_ROLE_NAME` for employee cards.

## navigationDestination(item:) requires Hashable

Any enum used with `navigationDestination(item:)` must conform to both `Identifiable` AND `Hashable`. Learned from LoginView.LoginDestination error.

## swiftc for syntax checking

Without Xcode installed, use:
```bash
swiftc -typecheck File1.swift File2.swift File3.swift
```
Note: SwiftUI/UIKit types won't resolve without the SDK, so only pure Swift files (services, models) can be checked this way.
