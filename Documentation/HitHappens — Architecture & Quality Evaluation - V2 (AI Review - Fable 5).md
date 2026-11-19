# HitHappens — Architecture & Quality Evaluation V2 (AI Notes)

> Second-edition review, July 2026 (branch `claude`). V1 was written before the
> modernization/UX/managers/design sessions; this edition re-verifies every V1 finding
> against the current code and adds three deep-dives requested by the owner:
> CalendarView correctness, SwiftUI render efficiency, and the BaseView pattern.

**Verdict: A− / production-solid** (V1: B+). Architecture unchanged and still excellent;
correctness, hygiene, accessibility, and API currency all moved up. Test coverage did not.

---

## Snapshot

| | |
|---|---|
| **Toolchain** | Swift 5.10 mode / Swift 6.2 toolchain / Xcode 26 / **min iOS 18.0** |
| **Observation** | Fully migrated to `@Observable` (Common's two classes deliberately kept `ObservableObject`) |
| **Pattern** | Clean Architecture + MVVM-C, DI root `ConfigurationViewModel`, root `RouterViewModel` injected at App level |
| **Verified** | Builds green, 14/14 unit tests, boots on simulator in light + dark |

---

## V1 findings — status today

| V1 finding | Status |
|---|---|
| Thin app-level test coverage (14 tests, VMs untested) | **Open** — unchanged; now the single weakest dimension |
| Fire-and-forget `Task {}` writes, `cascadeEvents = nil` sentinel | **Half-fixed** — hot reads now async on background contexts; writes still unserialized, sentinel remains |
| CloudKit `#warning` shipped bug | **Fixed** (offline support commit; no-iCloud handled at boot) |
| `as!` force-casts in DataBaseRepository | **Open** (2) |
| `Learnings/` scratch code shipped in Common | **Open** (deliberate deferral) |
| `DataBaseRepository2` empty class | **Open** |
| Identifier typos | **Partially fixed** — `DependenciesManager` renamed; `2.ClouldKit`, `5.Desigables`, one `typelias` remain |
| `V.EventDetailsView` 528 lines | **Open** (523) |
| Stringly-typed DB event routing | **Open** |

Fixed beyond V1's list: ErrorsManager was a permanent no-op (inverted gate); analytics
`sender` silently dropped on every event + Firebase-invalid event names; boot crash from
eager `@Environment(Type.self)` resolution; XcodeGen Info.plist regen trap; WCAG AA
contrast; Dynamic Type was hard-disabled; dark-mode surfaces were black-on-black.

---

## Deep-dive 1: CalendarView bugs (`DesignSystem/Designables/Calendar/V.CalendarView.swift`)

1. **Weekday header misaligned with the grid (real, user-visible).** `generateDays`
   hardcodes a Monday-first layout (`daysBefore = (firstWeekdayOfMonth + 5) % 7`) while
   `DaysOfWeekView` renders `DateFormatter().shortWeekdaySymbols`, which is **Sunday-first**
   in most locales. Every column is shifted one position relative to its header. Provable
   from the README's own screenshot: Sep 1 2024 (a Sunday) renders under **"Sat"**.
   Fix: derive `daysBefore` from `Calendar.current.firstWeekday` *and* rotate the header
   symbols with the same offset so both follow the locale.
2. **Day-tap triggers a month reload too.** Selecting a day sets `selectedDay` *and*
   `currentDate` (`set(day:)`), so `onChange(of: currentDate)` fires `onSelectedMonth` →
   the VM issues a full-month load and a day load through the *same* debounce
   `operationId`, and only the last one survives. Works by accident; fragile ordering.
3. **Today's cell can't show selection** — the `isToday` background branch wins over the
   `selectedDay` branch, so selecting today gives no visual feedback.
4. **`Array(Set(events))` randomizes gradient color order** per render (Set has no stable
   order) — multi-category day underlines can shuffle colors between refreshes.
5. **Per-render cost**: `generateDays` runs in `body` (42× Calendar math) and resolves
   events via `eventsForDay.filter { $0.key.isSame(day:) }` — O(42·n) linear scans where a
   normalized-key dictionary lookup would be O(1); `DaysOfWeekView` allocates a
   `DateFormatter` every render. Not user-visible yet, but needless.
6. Cosmetic: the row-hiding `EmptyView()` branch still emits its trailing
   `FixedVerticalSpacer`, leaving stray gaps below short months.

## Deep-dive 2: render efficiency ("too many view reloads?")

Post-`@Observable` the app is in decent shape — views only invalidate on properties they
read. The debug tracker showed `Redraw[5–8]` for `FavoriteEventsView` at boot; most of
that is legitimate (appear → async load → env changes). Remaining avoidable causes:

1. **Unconditional reassignment defeats @Observable's granularity.** VMs do
   `favorits = records` / `logs = …` / `tip = ("", .clear)` on every load/action even when
   the value didn't change; `@Observable` fires on *set*, not on *difference*. Every
   debounced DB event re-renders subscriber screens even when data is identical, and
   `EventDetailsViewModel.send` calls `displayTip("")` on **every** action — one wasted
   full-screen render per tap. Fix: equality-guard the assignments (`if favorits != records`)
   and inside `displayTip`.
2. **BaseView couples every screen's body to alert/loading state.** Screens pass
   `viewModel.alertModel`/`loadingModel` *values* into `BaseView.withLoading`, so the whole
   content subtree re-renders on every alert show/auto-dismiss cycle. See deep-dive 3 —
   this is structural, and fixable.
3. **CalendarView recomputes its 42-day grid every body evaluation** (see above).
4. Non-issues checked: `screenRegistry` closures per body are cheap; `MainTabView`'s five
   `onChange(of: navPath)` are fine; `CounterView`'s `@State(initialValue:)` correctly
   ignores re-inits; the Combine bus is debounced.

## Deep-dive 3: the BaseView pattern — is it good? can it improve?

**Verdict: legitimate and worth keeping — as a concept.** A single screen scaffold
(background, alert, loading, offline overlay, analytics screen-in, debug tracker) is
exactly what a design system should centralize; every screen getting consistent chrome
from one place is a strength, not a smell. Two structural weaknesses in the *current*
implementation:

1. **It's a 10-parameter static factory, not SwiftUI composition.** Half the arguments are
   the same at every call site (`ignoresSafeArea: false`, `background: .defaultBackground`,
   `networkStatus: nil`, `sender: "\(Self.self)"`). Idiomatic SwiftUI expresses this as a
   `ViewModifier` with defaults: `content.baseScreen(.favoriteEvents, viewModel: viewModel)`.
2. **It takes alert/loading as values, which is the render-coupling from deep-dive 2.**
   If instead the modifier receives the `BaseViewModel` and the *overlay host view* reads
   `viewModel.alertModel` inside its own `body`, `@Observable` scopes invalidation to the
   overlay — an alert appearing/dismissing would no longer re-render the screen content
   at all. That's the single biggest render win available.

Sketch of the improved shape:

```swift
extension View {
    func baseScreen(
        _ appScreen: AppScreen,
        viewModel: BaseViewModel,            // overlays read alert/loading themselves
        background: BackgroundView.Background = .defaultBackground,
        navigation: BaseView.NavigationViewModel? = .disabled
    ) -> some View { modifier(BaseScreenModifier(...)) }
}
```

Migration is mechanical (every screen's `body` shrinks by ~8 lines) and can coexist with
the old entry point during transition. Recommended, not urgent.

---

## Scorecard V2

| Dimension | V1 | V2 | Note |
|---|---|---|---|
| Architecture / layering | A | **A** | Compiler-enforced modules, unchanged |
| SOLID adherence | A− | **A−** | Repository ISP improved (async read overloads) |
| MVVM-C separation | A− | **A−** | Survived the @Observable migration intact |
| Testability (design) | A | **A** | Seams still unused, still excellent |
| Test coverage (actual) | C | **C** | The unmoved needle |
| Concurrency correctness | B− | **B** | Reads hardened; writes + sentinel remain |
| Code hygiene | B | **B+** | Manager bugs fixed, warning gone; Learnings/, `as!` remain |
| Tooling / CI | A | **A** | Spec drift + regen trap fixed |
| Render efficiency *(new)* | — | **B+** | @Observable done right; equality guards + BaseView coupling pending |
| API currency *(new)* | — | **A** | iOS 18, @Observable, zero deprecated forms |
| Accessibility *(new)* | — | **A−** | AA contrast, Dynamic Type, 44pt targets; localization pending |

## Recommended priorities (V2)

1. **Unit tests for the tab ViewModels** — still #1, unchanged from V1.
2. **CalendarView weekday alignment fix** — user-visible correctness bug.
3. **Equality guards on VM reassignments + `displayTip`** — cheap, immediate render win.
4. **BaseView → `baseScreen` ViewModifier with self-reading overlays** — ergonomics + the
   largest structural render improvement.
5. Carry-overs from V1: write-path serialization + sentinel, `Learnings/` extraction,
   `as!` removal, remaining typo renames, EventDetailsView decomposition.

---

*Generated by Claude Code (Fable 5) — second-edition review; V1 by Opus 4.8.*
