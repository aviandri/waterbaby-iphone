# MilkBaby — build plan

MilkBaby is a Waterllama-style iPhone app for tracking a **baby's milk intake**. The mascot is a
**capybara** (Waterllama uses a llama). The core interaction is the same: a big capybara
silhouette fills up from the bottom with coloured bands as feeds are logged through the day.

Stack: SwiftUI, iOS 17+, SwiftData (`FeedEntry`), `@Observable AppSettings` in the environment,
XcodeGen (`project.yml`). There is no Xcode on the Linux machine where the code is written, so
write careful, compile-clean Swift: no third-party packages, only Apple frameworks.

## References (from Mobbin, Waterllama iOS)

All in `docs/references/`. Open them with the Read tool before building your screens.

| File | What to take from it |
|---|---|
| `splash-logo.jpg` | Centred logo on white |
| `onboarding-welcome-mascot.jpg`, `onboarding-welcome-confetti.jpg` | "Track your intake" + mascot art + dark GET STARTED pill |
| `onboarding-units.jpg`, `onboarding-first-day-of-week.jpg` | Bottom-sheet single-choice questions over a dimmed home |
| `goal-calculator.jpg` | "See how much you need" rows → computed goal |
| `onboarding-reminders.jpg` | Smart reminders pitch card + CTA, SKIP top-right |
| `home-empty-first-sip.jpg`, `home-partial-fill.jpg`, `home-silhouette-filled.jpg`, `home-silhouette-layered-by-drink.jpg` | Home: big amount, "% of your goal", filling silhouette, drink-type carousel at the bottom |
| `home-streak-badge.jpg` | Top-left streak badge, top-right menu button |
| `add-drink-bottle.jpg`, `add-drink-custom-amount.jpg` | Add sheet: bottle that fills to the chosen amount, horizontal amount picker, tinted "+ TYPE" pill, custom-amount keypad sheet |
| `day-log-list.jpg`, `drink-entry-detail.jpg` | Day log: date title, summary line, rows "TYPE · time · amount" with red minus, ADD MISSED DRINK |
| `history-calendar-goal-met.jpg`, `history-calendar-partial.jpg` | Big % ring for the selected day + month calendar with goal-met days highlighted |

## Wording map

Waterllama → MilkBaby: drink → **feed**, hydration → **milk today**, "Add your first sip" →
"Log the first feed", "ADD MISSED DRINK" → "ADD MISSED FEED", llama → **capybara**.
Feed types: Breast Milk, Pumped Milk, Formula, Whole Milk (`MilkType`).

## Shared foundation (already on `main` — do not restructure)

- `Models/` — `FeedEntry` (SwiftData), `MilkType`, `VolumeUnit`, `GoalCalculator`, `AppSettings`, `FillSegment`
- `Theme/Theme.swift` — colours, rounded heavy font, `PillButtonStyle`, `SoftPillButtonStyle`, `CloseButton`
- `App/` — `MilkBabyApp`, `RootView` (splash → onboarding or home)

If you need a change in a shared file, keep it additive and small, and mention it in your PR.

## Ownership

Each session works **only** in its own folders, on its own branch, in its own git worktree.

| Session | Branch | Owns |
|---|---|---|
| water-baby-5a — **Mascot & brand** | `feat/mascot` | `MilkBaby/Mascot/**`, `MilkBaby/Resources/Assets.xcassets/AppIcon.appiconset/**`, `docs/brand/**` |
| water-baby-aa — **Home & logging** | `feat/home-logging` | `MilkBaby/Features/Home/**`, `MilkBaby/Features/Logging/**` |
| water-baby-72 — **Onboarding, history, settings** | `feat/onboarding-history` | `MilkBaby/Features/Onboarding/**`, `MilkBaby/Features/History/**`, `MilkBaby/Features/Settings/**`, `MilkBaby/Notifications/**` |

Stubs in those folders define the contract (type names + init signatures) other sessions call.
Keep those signatures; you may add optional parameters with defaults.

### Mascot & brand
1. `CapybaraSilhouette: Shape` — recognisable side-profile capybara (blocky body, flat head,
   small round ear, short legs), aspect ~1.25:1. Built from Bézier curves in unit space, scaled to `rect`.
2. `MascotFillView(segments:)` — empty silhouette in `Theme.silhouetteEmpty`, bands stacked
   bottom-up clipped to the shape, spring-animated, total clamped to 100%. Subtle wave on the top edge is a plus.
3. `CapybaraLogo` — capybara head brand mark (Waterllama's mark is a stacked-colour llama head:
   do the same idea with milk colours + capybara head).
4. `CapybaraIllustration` — full-colour friendly capybara holding a baby bottle, for onboarding.
5. `SplashView`.
6. App icon: `docs/brand/app-icon.svg` (1024×1024) and the same as `AppIcon.png` in the appiconset.
   No raster tools on this machine: try `pip install --user cairosvg` to render; if that fails,
   commit the SVG and say so in the PR.

### Home & logging
1. `HomeView` — top-left streak badge (consecutive days goal met; opens `HistoryView` sheet),
   top-right menu button (opens `SettingsView` sheet), big amount in `settings.unit`,
   "Milk today · N% of your goal", `MascotFillView(segments: FillSegment.from(todayEntries, goalML:))`
   (tapping it opens the day log), bottom horizontal carousel of `MilkType` icons with "+" badges and caps labels.
   Empty state: "Log the first feed".
2. `AddFeedSheet(type:)` — bottle illustration filling to the selected amount, horizontal snapping
   amount picker from `type.presetsML` (+ "custom" dot button → keypad sheet), tinted "+ FORMULA" pill
   that inserts a `FeedEntry`. Haptic on save.
3. `DayLogView(day:)` — date title, summary "480ml milk · 69% of your goal", rows with type icon,
   caps name, "6:39 PM · 120ml", red minus to delete, "ADD MISSED FEED" (pick time + type + amount).
4. Light success celebration (confetti) when the goal is first reached today.

### Onboarding, history, settings
1. `OnboardingFlow` — Welcome ("Track your baby's milk", `CapybaraIllustration`, GET STARTED) →
   baby name → birth date → weight → goal ("See how much they need", rows → `GoalCalculator`, "SET CUSTOM") →
   units sheet (oz/ml) → first day of week sheet → reminders pitch (requests notification permission, SKIP) →
   sets `settings.hasOnboarded = true`.
2. `HistoryView` — big % ring for the selected day, month calendar (respects `settings.firstWeekday`)
   with goal-met days filled, partial days dotted, today outlined, month paging; tapping a day selects it and
   shows its `DayLogView(day:)` content below (DayLogView is owned by Home & logging — call it, don't rebuild it).
3. `SettingsView` — baby profile, daily goal, unit, first weekday, reminders toggle + interval, reset data.
4. `Notifications/ReminderScheduler.swift` — `UNUserNotificationCenter` repeating feed reminders.

## Definition of done (per branch)
- Builds conceptually against `main`'s contracts; no edits outside owned folders (except tiny additive shared changes, called out).
- `#Preview` for every screen.
- PR opened against `main` with a summary and the list of any shared-file changes.
