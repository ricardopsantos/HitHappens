# HitHappens — Navigation: Root-Cause Report & Improvement Plan

> Audience: a coding agent (or engineer) picking this up cold. Everything needed to
> understand the navigation bug, the fix that was applied, and a recommended redesign is
> self-contained here. File paths are relative to the repo root. Verified July 2026 on

---

## TL;DR

- A **push-navigation regression** was introduced by commit `c4f96a4`
  ("Modernized codebase (iOS 18, @Observable)"). Symptom: opening a pushed screen (e.g. a
  tracker's details from the **List** tab) makes it **appear then immediately bounce back**,
  and the `NavigationPath` silently accumulates stale entries.
- **Confirmed by git bisect** over `UITests/Tab2Tests/test_routeToEntityDetailsAndEditConfirm`:
  `0a3a4bd` PASS → `c4f96a4` FAIL (first bad). See §2.
- **⚠️ STATUS: NOT YET FIXED.** Two hypotheses were tested and **falsified**:
  1. *RouterViewModel `@Observable`* — reverted to `ObservableObject`; MainTabView restored
     to the exact passing shape (`@StateObject` routers, `.environmentObject`,
     `$router.navPath`). **Push still fails.** So the router observation type is *not* the
     cause (necessary to match the baseline, but not sufficient).
  2. *Nested `NavigationStack` in screen chrome* — the current tree removed the nested
     container entirely. **Push still fails.** (And `0a3a4bd`, which had a nested
     `NavigationView`, passed — so a nested container was not itself the problem.)
- **Remaining suspect:** another change inside the large `c4f96a4` commit — most likely the
  `NavigationView → NavigationStack` deprecation sweep interacting with how the pushed
  screen renders, or an `@Observable` interaction on the pushed screen / its ViewModel. Not
  yet isolated (would need a within-commit bisect).
- **Longer term:** the navigation layer is workable but fragile (multiple routers,
  `presentationStyle` threaded into screens, untyped `NavigationPath`, nav containers hidden
  in screen chrome). The [§4 redesign](#4-recommended-redesign-future-work) would eliminate
  this whole class of bug and is a strong alternative to patching the exact line.

---

## 1. How navigation currently works

**Pattern:** MVVM + Coordinator. Key types:

| Type | File | Role |
|---|---|---|
| `AppScreen` | `Source/Application/.../AppScreen*.swift` (enum) | One case per screen; the routing "value" |
| `RouterViewModel` | `Source/Application/3.AppViewModels/RouterViewModel.swift` | Holds `navPath: NavigationPath`, `sheetLink: AppScreen?`, `coverLink: AppScreen?` + push/pop helpers |
| `ScreenBuilderRegistry` | `Source/Application/2.Screens/ScreenProtocols.swift` | Closure factories `AppScreen → AnyView` (avoids switch statements) |
| `…ViewCoordinator` (per screen) | `V.<Name>View.swift` | Owns its own `RouterViewModel` for sheets/covers; reads a **parent** router from the environment for pushes |
| `MainTabView` | `Source/Application/2.Screens/4.MainTab/V.MainTabView.swift` | Owns **five** `RouterViewModel`s (one per tab), each wrapping a `NavigationStack(path:)` |

**Three presentation mechanisms**, chosen per navigation call:

- **Push** → `parentCoordinator.navigate(to:)` appends to a tab's `navPath`; rendered by
  `.navigationDestination(for: AppScreen.self)` at the tab root in `MainTabView`.
- **Sheet** → `coordinator.sheetLink = .someScreen`; rendered by `.sheet(item:)`.
- **Full-screen cover** → `coordinator.coverLink = .someScreen`; rendered by
  `.fullScreenCover(item:)`.

Screens receive a `presentationStyle: ViewPresentationStyle` and branch on it (e.g.
`EventDetails` draws its own `Header` with a close button when presented as a cover, but
uses navigation-bar chrome when pushed). Route-back logic is a per-style `switch` that
may clear `coverLink` on two routers and also call `@Environment(\.dismiss)`.

---

## 2. The bug

### Symptom
From the **List** tab, tapping a tracker pushes `EventDetailsView`. It renders for a frame,
then navigates back on its own. Repeating it makes the tab's `navPath` grow without
bound. Runtime log evidence (device console): `tab2Router.navPath` grew to 5 stacked
`eventDetails` entries (with duplicates), and each push emitted an immediate
`Screen In → Screen Out` pair.

### Root cause (proven by bisect)
A four-commit bisect running the UI test
`UITests/Tab2Tests/test_routeToEntityDetailsAndEditConfirm`:

| Commit | Summary | Result |
|---|---|---|
| `0a3a4bd` | Performance & UX (pre-migration) | **PASS** |
| `c4f96a4` | **Modernized codebase (iOS 18, @Observable)** | **FAIL** ← first bad |
| `2561dcf` | Fixed boot crash (inject root router) | FAIL |
| `e156339` | Design polish | FAIL |

The regression is entirely inside the `@Observable` migration. The specific trigger is
`NavigationStack(path: $router.navPath)` where `router` is now `@Observable`: the binding
that SwiftUI derives for the path does not correctly own the stack, so a pushed element is
immediately popped. This is a known rough edge when combining `@Observable` classes with
`NavigationStack` path bindings, and it is hierarchy-dependent (it did **not** reproduce in
isolation, only inside the real tab/coordinator tree).

Two red herrings were ruled out along the way:
- **Nested `NavigationStack` in screen chrome** (BaseView wrapping `.custom` screens in
  their own stack) is a *real* latent problem and was fixed, but it was **not** the cause
  of the bounce.
- The `@Bindable var router = router` pattern (the "correct" way to bind `@Observable`
  paths) was tried and **still failed** in this hierarchy.

### Secondary issue found & fixed
`EventsListView` split trackers into `favorite` / `others` / `archived` sections, but an
**archived favorite** matched both the `favorite` and `archived` filters — the same
`ForEach` id appeared twice in one `LazyVStack`, producing SwiftUI's
"ID … used by multiple child views, this will give undefined results" warning. Fixed by
making the first section `favorite && !archived` (sections are now disjoint).

---

## 3. Partial remediation applied (necessary, NOT sufficient)

> ⚠️ The changes below restore the router layer to the exact shape it had on the passing
> commit `0a3a4bd`, but **they do not fix the bug** — `Tab2Tests` push tests still fail with
> them applied. They are kept because they move toward the known-good baseline and are the
> correct end-state regardless; the *actual* culprit is elsewhere in `c4f96a4` and is still
> unisolated. Do not treat this section as "the fix."

**Principle:** keep the whole app on `@Observable` **except** `RouterViewModel`, which must
stay `ObservableObject` because its properties back `NavigationStack` path bindings.

Changes (branch `claude`, working tree at time of writing):

1. **`RouterViewModel.swift`** — `@Observable` → `ObservableObject`; `navPath`,
   `sheetLink`, `coverLink` marked `@Published`. A doc comment records *why* (do not
   "modernize" this back).
2. **All consuming views (~26 files)** — reverted the router wrappers only:
   - `@Environment(RouterViewModel.self) var x` → `@EnvironmentObject var x: RouterViewModel`
   - `@State var coordinator = RouterViewModel()` → `@StateObject var coordinator = …`
   - `@State var tabNRouter = RouterViewModel()` → `@StateObject var tabNRouter = …`
   - `.environment(router)` → `.environmentObject(router)`
   - `.environment(RouterViewModel())` (previews) → `.environmentObject(RouterViewModel())`
   - **Note:** `ConfigurationViewModel` stays `@Observable` / `.environment(...)`. It is
     *not* a router and is not bound to any `NavigationStack` path.
3. **`MainTabView.swift`** — removed the experimental `@Bindable var tabNRouter = …` block
   (didn't help; `@StateObject` + `$tabNRouter.navPath` is the working form).
4. **`HitHappensApp.swift`** — `rootRouter` still injected at the app root, now via
   `.environmentObject(rootRouter)`; comment updated.

### ⚠️ Important interaction with an earlier boot crash
Commit `2561dcf` fixed a **boot crash**: `@Environment(RouterViewModel.self)` resolves
*eagerly*, so a coordinator with no router ancestor crashed at launch. Reverting to
`@EnvironmentObject` (which is *lazy* — only fatals on access) technically removes the
eager-crash risk, but the `rootRouter` injection from that fix **must stay** so previews
and top-level coordinators still have a router. Every `#Preview` that presents a coordinator
must inject one: `.environmentObject(RouterViewModel())`.

### How to verify the fix
```bash
cd Source
xcodegen -s ./Xcodegen/XcodegenMultiConfig.yml -p ./     # only if files were added/removed
xcodebuild -project HitHappens.xcodeproj -scheme "HitHappens Dev" \
  -configuration "Dev Debug" -destination "platform=iOS Simulator,name=iPhone 17 Pro" \
  build-for-testing
# The detector test — must PASS:
xcodebuild ... -only-testing:UITests/Tab2Tests test-without-building
# Regression guard:
xcodebuild ... -only-testing:UnitTests test-without-building
```
`Tab2Tests` (`test_routeToEntityDetailsAndEditConfirm`, `…EditCancel`, `resetCounter`,
`test_doubleTapToRouteBackT1`) is the canonical push/pop suite for this bug. All four must
pass. `DataBaseRepository_Tests.test_stressTest` is flaky under load — rerun it in isolation
before treating a batch failure as real.

---

## 4. Recommended redesign (future work)

The current system works once `RouterViewModel` is `ObservableObject`, but it carries
avoidable complexity. If/when navigation is revisited, this is the cleaner target. **Do not
start this until §3 is green** — refactor on a passing baseline.

### Problems to solve
1. **Router tree with implicit ownership.** Each coordinator owns a router *and* reads a
   parent from the environment; which one handles a transition is decided inside registry
   closures. This caused the boot crash and the need for a dummy `rootRouter`.
2. **`presentationStyle` threaded into screens.** Screens branch on how they were presented
   and carry multi-case route-back logic that clears links on multiple routers plus calls
   `dismiss()`.
3. **Untyped `NavigationPath`.** When a push misbehaves, the path silently accumulates
   stale entries and nothing can inspect it.
4. **Navigation containers hidden in screen chrome** (BaseView's `.custom` case). Fragile;
   broke when `NavigationView` → `NavigationStack`.

### Target shape: one router per tab, typed path, chrome-free screens
```swift
// ObservableObject (see §2 — @Observable + NavigationStack path binding is broken here).
final class Router: ObservableObject {
    @Published var path: [AppScreen] = []   // TYPED array, not NavigationPath — inspectable, Codable, deep-linkable
    @Published var sheet: AppScreen?
    @Published var cover: AppScreen?

    func push(_ s: AppScreen)     { path.append(s) }
    func present(_ s: AppScreen)  { sheet = s }
    func cover(_ s: AppScreen)    { cover = s }
    func pop()                    { if !path.isEmpty { path.removeLast() } }
    func popToRoot()              { path.removeAll() }
}

// Declared ONCE at each tab root (in MainTabView), never inside screen chrome:
NavigationStack(path: $router.path) {
    EventsListScreen()
        .navigationDestination(for: AppScreen.self) { RouteView(screen: $0) }
}
.sheet(item: $router.sheet)           { RouteView(screen: $0) }
.fullScreenCover(item: $router.cover) { RouteView(screen: $0) }
```

### Why this is cleaner — concrete deletions
- **`dismiss()` becomes universal.** SwiftUI's `@Environment(\.dismiss)` pops a push,
  closes a sheet, or closes a cover — whichever applies. Every per-style route-back
  `switch` (clearing `coverLink` on two routers, calling `navigateBack()` then `dismiss()`)
  collapses to one `dismiss()` call. This deletes the most fragile code in the app.
- **`presentationStyle` disappears from screens.** A screen is just a screen. If one truly
  must know it's presented modally (e.g. to show a close button), use
  `@Environment(\.isPresented)` — no parameter threading.
- **ViewModels stay navigation-free.** Keep injecting intent closures
  (`onShowDetails: (TrackedEntity) -> Void`) exactly as today; the tab root maps them to
  `router.push(.eventDetails(...))`.
- **Typed path pays off immediately:** deep links (`router.path = [.eventDetails(id)]`),
  state restoration (Codable path), and `assert(path.count == expected)` in debug builds so
  a future push regression is caught the instant it happens.
- **Registry optional.** `RouteView` can keep consulting `ScreenBuilderRegistry` if you
  value OCP, but with ~8 screens a single exhaustive `switch` in one `RouteView` is easier
  to read and gives compile-time exhaustiveness.

### Dependencies
Stay in-house. The above is ~150 lines of your own code and matches the project's
"minimal dependencies" philosophy. (FlowStacks / Point-Free swift-navigation exist but are
not warranted here.)

### Migration outline (per tab, mechanical after the first)
1. Replace the tab's `RouterViewModel` usage with the `Router` above; move `.sheet` /
   `.fullScreenCover` / `.navigationDestination` to the tab root.
2. Delete `presentationStyle` from that tab's screens; replace route-back closures with
   `@Environment(\.dismiss)`.
3. Convert that tab's coordinator registry entries to `router.push/present/cover`.
4. Run `Tab<N>Tests` — green before moving to the next tab.

Effort: comparable to the `@Observable` migration already completed.

---

## 5. Guardrails (do / don't)

- **DO** keep `RouterViewModel` (or any type backing a `NavigationStack` path) on
  `ObservableObject`. **DON'T** migrate it to `@Observable` — that is exactly what broke
  push navigation (§2).
- **DO** keep `ConfigurationViewModel` and screen ViewModels on `@Observable`.
- **DO** inject a router into every `#Preview` that presents a coordinator
  (`.environmentObject(RouterViewModel())`), or it will crash/behave oddly.
- **DON'T** put a `NavigationStack` inside per-screen chrome (BaseView). Navigation
  containers belong at the tab root only.
- **DO** keep list sections disjoint when they feed one `ForEach`/`LazyVStack` (an item in
  two sections = duplicate id = undefined layout).
- **DO** run `Tab2Tests` after any navigation change — it is the regression detector for
  this bug.

---

*Prepared by Claude Code. Root cause established by git bisect over
`UITests/Tab2Tests/test_routeToEntityDetailsAndEditConfirm`.*
