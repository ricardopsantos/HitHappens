# CLAUDE.md — HitHappens

Context file for AI-assisted sessions. Everything here was verified against the codebase (July 2026, branch `dev/V2.0.0`). The user-facing [README.md](README.md) covers the same ground with screenshots; this file adds the operational knowledge that isn't written down anywhere else.

## What the app is

Personal life-event tracker (SwiftUI, App Store). Users create **Trackers** (e.g. "Had a coffee") and tap a flip-counter to log an **occurrence/Log** (timestamped, optional GPS + reverse-geocoded address, note, sound effect, haptic). History is browsable via list, calendar heat-map, and map. Data lives in Core Data, synced via CloudKit.

Naming glossary (code vs UI): `TrackedEntity` = "Tracker", `TrackedLog` = "Event"/occurrence. UI strings come from `AppConstants.entityNameSingle/Plural` etc. in `Source/Application/7.Utils/AppConstants.swift`.

## Current state (as of July 2026)

- **Xcode 26, Swift 5.10 language mode, min iOS 18.0**, Swift 6.2 toolchain.
- App layer fully migrated to **`@Observable`** (`@State`/`@Environment(Type.self)`/`.environment()`). Exceptions kept on `ObservableObject` deliberately: `Common.SharedLocationManagerViewModel` (in Common) and `SyncMonitor` (CloudKitSyncMonitor package) — still consumed with `@StateObject`; mixing is fine.
- Deprecated-API sweep done: two-param `onChange`, `NavigationStack`, `.foregroundStyle`, `.clipShape` — don't reintroduce old forms.
- **Deferred (agreed, not yet done):** Swift 6 strict concurrency; removing `UIScreen.main`-based globals (`screenWidth` etc. in Common); `.task` instead of `onAppear`+`Task`; `TimelineView` for the flip-counter `Timer`; `.sensoryFeedback` / `ContentUnavailableView` swaps.

## Targets & folders (`Source/`)

| Folder | Target | Notes |
|---|---|---|
| `Application/` | HitHappens (app) | Views, ViewModels, Coordinators, Managers, BaseView/BaseViewModel |
| `Domain/` | Domain | Models, protocols, Core Data entity mappers (`2.2.DBModels`), `DBModel.xcdatamodeld` |
| `Core/` | Core | Implementations: `1.Repositories` (Core Data, prefs), `2.Services` (AppConfig, CloudKit), `3.Network` |
| `DesignSystem/` | DesignSystem | `ColorsAndAppearance`, `Fonts`, `Designables/` (reusable views), `Accessibility.swift`, `HapticFeedback.swift` |
| `Common/` | Common (also a SwiftPM package) | Dependency-free utility toolbox; has own tests; `Sources/Learnings/` is showcase code — ignore it |
| `DevTools/` | DevTools | Logging (`DevTools.Log`), known to all targets |
| `UnitTests/`, `UITests/` | test targets | See Testing below |
| `Xcodegen/`, `Scripts/`, `Configuration/` | — | Project specs, helper scripts, per-env xcconfigs |

Application subfolders: `1.Main` (App entry, AppDelegate), `2.Screens` (per-screen folders, `ScreenProtocols.swift`), `3.AppViewModels` (`ConfigurationViewModel` DI root, `RouterViewModel`), `4.Managers` (Analytics, Setup, Dependencies), `5.Desigables` (app-level reusable views: EditView, SyncMonitorView, PickerViews, TipView), `7.Utils` (BaseView, BaseViewModel, AppConstants, model extensions).

### 4.Managers (cleaned up July 2026)

- `AnalyticsManager` — all events funnel through one private `handle(eventType:properties:label:sender:)` that attaches `sender`/`label` params and uses `firebaseEventName` (sanitized: alphanumeric+underscore, ≤40 chars — Firebase rejects raw labels with spaces). Injected via `\.analyticsManager` environment key; `NullAnalyticsManager` for tests/UI-testing.
- `ErrorsManager` — always logs locally via `DevTools.Log.error`; Crashlytics only on real device + Release + Firebase configured. (Historic bug: it was gated `onSimulator && onRelease`, i.e. never fired — don't reintroduce.)
- `DependenciesManager` — composition root mapping protocols → singletons. `appConfigService`/`cloudKitService` are `static let` on purpose (they own caches); repositories are computed vars over `.shared`.
- `SetupManager` — one-shot boot wiring (login counter, Firebase configure, fonts, UI-testing hooks, appearance, CloudKit). `FirebaseApp.configIsValidAndAvailable` validates the *plist* (works pre-configure); a no-Firebase shim `enum FirebaseApp` exists in `7.Utils/Extensions/Firebase+Extension.swift` so calls compile without `FIREBASE_ENABLED`.
- `InterfaceStyleManager` — static appearance state; `applyAppearance` applies global state once and overrides every window of every connected scene.
- `UITestingManager` — reads `CommandLine.arguments` flags (`onUITesting`, `shouldResetAllContent`, `isOnboardingCompleted`, ...); `shouldResetAllContent` wipes prefs/DB and seeds mock default events.
- `AppFeaturesManager` — only `Debug.canDisplayRenderedView` remains; don't add speculative feature flags with no readers.

## Architecture & patterns

- **MVVM + Coordinator.** Each screen folder has `V.<Name>View.swift` (contains BOTH the `...ViewCoordinator` and the View) and `VM.<Name>ViewModel.swift`. Coordinators conform to `ViewCoordinatorProtocol` and declare a `screenRegistry: ScreenBuilderRegistry` (closure factories, no switch). Routing state lives in `RouterViewModel` (`navPath`/`sheetLink`/`coverLink`).
- **⚠️ Environment routers**: every coordinator declares `@Environment(RouterViewModel.self) var parentCoordinator`. Unlike `@EnvironmentObject` (lazy — fatals only on read), **`@Environment(Type.self)` resolves eagerly when the view is installed** — a missing ancestor injection crashes at boot ("No Observable object of type RouterViewModel found"). `HitHappensApp` injects a `rootRouter` for top-level coordinators; **every `#Preview` must inject BOTH** `.environment(ConfigurationViewModel.defaultForPreviews)` and `.environment(RouterViewModel())`. Any new view presented outside the coordinator chain needs the same pair.
- **ViewModels**: subclass `BaseViewModel` (`@MainActor @Observable`, provides `alertModel` with auto-dismiss, `loadingModel`, `tip`, `insertTrackedLog`, error handling). Screen VMs expose a single `send(_ action: Actions)` with an `Actions` enum; dependencies arrive via a typed `Dependencies` struct.
- **DI root**: `ConfigurationViewModel`, injected via `.environment()` from `HitHappensApp`; previews use `ConfigurationViewModel.defaultForPreviews`.
- **Data flow / reactivity**: repositories emit change events through a Combine `PassthroughSubject` bus (`CommonBaseCoreDataManager.output`, exposed via `DatabaseOutputRepositoryProtocol.output(_:)`). VMs subscribe in `startListeningEvents()` (`.sink` + `CancelBag`), debounce with `Common.ExecutionControlManager.debounce`, and reload. This bus is a deliberate keep — don't migrate it to AsyncStream without asking.
- **Repository protocols** (`Domain/3.Repositories/DataBaseRepositoryProtocol.swift`) are split into narrow sub-protocols (read/write/log/output); `DataBaseRepositoryProtocol` is the composite. Reads for hot paths have **async overloads running on a background context** (`trackedEntityGetAll(...) async`), plus `trackedEntityCount` (store-level `count(for:)`). Prefer these from VMs; the sync versions run on `viewContext`.
- **First launch**: `AppConfigService` seeds default trackers when `numberOfLogins == 1` and DB is empty (needs network for remote config). UI tests rely on launch arguments (`.shouldResetAllContent`, `.isOnboardingCompleted`).

## DesignSystem conventions

- Colors: `ColorSemantic.<name>.color`; fonts: `.fontSemantic(.body)`; spacing: `SizeNames.*`; text color helper `.textColor(...)`.
- Reusable components live in `DesignSystem/Designables/` (TextButton, ImageButton, ListItemView, EmptyStateView, CounterView, CustomTextField, CalendarView, GenericMapView, ConfirmationSheetV2...). App-level composites in `Application/5.Desigables`.
- `HapticFeedback` (DesignSystem root): `.impact()` for the quick-log tap (fired inside CounterView's throttle), `.notify(.success/.warning)` on save / before destructive confirmations.
- **Accessibility identifiers**: enum `Accessibility` in `DesignSystem/Accessibility.swift` **duplicated by hand** in `UITests/Auxiliar/Constants.swift` — when adding a case, add it to BOTH.
- Strings use `.localizedMissing` (marker: localization not done yet).

## UX decisions already made (don't regress)

- Saving a tracker/log applies immediately — **confirmation sheets are only for destructive actions** (delete, reset counter), which also fire a warning haptic.
- Quick-log success banner offers **Undo** (via `Model.AlertModel.undo` closure) and tap-to-edit.
- Empty states use `EmptyStateView` with a real button (`emptyStateAddButton` id), never bare tappable text.
- Trackers list has search (`CustomTextField`, filters name/category) and context menus (favorite/archive; archiving un-favorites — same rule as details screen).

## Build, run, test

- **Adding/removing files requires regenerating the project**: from `Source/`: `xcodegen -s ./Xcodegen/XcodegenMultiConfig.yml -p ./` (pbxproj is old-format, not filesystem-synchronized). Full clean rebuild: `./makefile.sh` → `Scripts/makeProject.sh`. The Firebase variant spec is `XcodegenMultiConfigAndFirebase.yml`.
- The app-target spec must keep `Info.plist` excluded from sources + `INFOPLIST_FILE` pinned in settings, or the build fails with "Multiple commands produce Info.plist" (fixed July 2026 in both specs — keep it that way after XcodeGen upgrades).
- Build: scheme **"HitHappens Dev"**, config "Dev Debug", `platform=iOS Simulator,name=iPhone 17 Pro`. Schemes: Dev / QA / Production variants.
- Unit tests: `-only-testing:UnitTests` (fast, ~15s). **`DataBaseRepository_Tests.test_stressTest` is flaky under simulator load** — rerun in isolation before treating a batch failure as real.
- UI tests: compile-check with `build-for-testing`; full execution is slow — leave to CI (Bitrise). Tests tap by accessibility id via helpers (`tap(button:on:)` etc. in `UITests/Auxiliar`).
- SwiftLint + SwiftFormat run as build phases; match their style (they may reformat files after edits).
- **Runtime verification on simulator** (compile-green is not enough — the @Observable boot crash compiled fine): `xcrun simctl bootstatus "iPhone 17 Pro" -b` (headless `simctl boot` alone is flaky — "server died"/screen-surface timeouts), then `simctl install` the built `.app` from DerivedData, `simctl launch --terminate-running-process "iPhone 17 Pro" com.hit.happens.app.id`, wait ~5s and confirm the pid is still in `simctl spawn ... launchctl list | grep hit.happens`; `simctl io ... screenshot` to eyeball the UI. Dev-build banner "Redraw[n]: <View>" at the top is the render tracker, not a bug.

## Working preferences (owner: Ricardo Santos)

- For larger changes: present an eval/report first, get explicit scope approval, then implement.
- Commit style: short imperative title + itemized body when warranted. He sometimes commits mid-session — check `git log` before staging.
- Keep the README human-sounding; small edits fine, bigger rewrites need confirmation.
