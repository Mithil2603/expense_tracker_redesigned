# Fingo UI Guidelines & Design System Specification

This document establishes the authoritative design principles, component standards, spacing tokens, and visual rules for building interfaces inside Fingo. Every UI component developed by engineers or AI assistants **must** adhere strictly to this design system.

---

## 1. Design Philosophy: Premium, Vibrant & Responsive

Fingo delivers a state-of-the-art, gamified financial tracking experience. The UI philosophy rests on four visual tenets:
1. **Rich Aesthetics & Glassmorphism**: Interfaces must feel premium and polished. Use subtle glassmorphism (translucent backgrounds with blur filters), vibrant HSL-curated gradient accents, and depth-enhancing surface shadows instead of flat, generic colors.
2. **Dynamic Micro-Animations**: Fingo feels alive. Interactive elements (cards, buttons, charts) must respond to user touch with smooth micro-scale transformations, spring physics, and animated number transitions (`TweenAnimationBuilder`).
3. **Immersive Dark Mode**: Dark mode is a primary design target. Never use pure black (`#000000`) for surface backgrounds; use layered deep slate (`#0A0E1A` to `#161B2E`) with subtle luminous borders to create visual depth without high-contrast eye fatigue.
4. **Content-First Clarity**: Despite rich gamification elements (Finny mascot, XP bars, streak diamonds), financial data (`netSavings`, `healthScore`, `categoryBreakdown`) must remain instantly scannable and crystal clear at a single glance.

---

## 2. Responsive Layout & Spacing System

### 2.1. Spacing Tokens (`AppDimensions`)
All margins, paddings, gaps, and border radii must use predefined grid multiples of **4px / 8px** located in `lib/core/constants/app_dimensions.dart`. **Hardcoded arbitrary numbers (`SizedBox(height: 13)`) are strictly forbidden.**

| Token Name | Value (px) | Usage Scenario |
| :--- | :--- | :--- |
| `AppDimensions.spacing2` | `2.0` | Micro-badge padding, internal border widths |
| `AppDimensions.spacing4` | `4.0` | Tight icon-to-text spacing inside pills |
| `AppDimensions.spacing8` | `8.0` | Standard item spacing in lists, compact card padding |
| `AppDimensions.spacing12` | `12.0` | Default inner padding for buttons and input fields |
| `AppDimensions.spacing16` | `16.0` | Standard screen horizontal padding, card content padding |
| `AppDimensions.spacing20` | `20.0` | Spacing between major section headers and content |
| `AppDimensions.spacing24` | `24.0` | Section separation gap across scrollable layouts |
| `AppDimensions.spacing32` | `32.0` | Hero banner padding, modal dialog top/bottom spacing |
| `AppDimensions.radius8` | `8.0` | Small pills, tags, and micro-cards |
| `AppDimensions.radius12` | `12.0` | Standard buttons, text fields, and list items |
| `AppDimensions.radius16` | `16.0` | Surface cards, chart containers, and dialog modals |
| `AppDimensions.radius24` | `24.0` | Bottom navigation sheets, hero feature cards |

### 2.2. Responsive Grid & Constraints
- **Maximum Reading Width**: For large tablet or desktop screens, wrap primary content columns in a `Center` + `ConstrainedBox(constraints: BoxConstraints(maxWidth: 600))` to prevent ultra-wide unreadable line spans.
- **Safe Area Enforcement**: Top-level screen scaffolds must wrap their body inside `SafeArea` or account for status bars and bottom navigation inset heights cleanly.

---

## 3. Typography System (`AppTextStyles`)

Fingo uses **Outfit / Inter** (`GoogleFonts`) with strict hierarchy scale tokens. Always reference `AppTextStyles` and use `.copyWith(color: ...)` when adjusting context colors. Never instantiate raw `TextStyle(fontSize: ...)` ad-hoc in widgets.

| Token Name | Font Size | Weight | Usage |
| :--- | :--- | :--- | :--- |
| `AppTextStyles.displayLG` | `32px` | Bold (`w700`) | Hero scores, major achievement popups |
| `AppTextStyles.h1` | `24px` | Bold (`w700`) | Screen titles (`Analytics`, `Expenses`) |
| `AppTextStyles.h2` | `20px` | SemiBold (`w600`) | Card section titles (`Financial Health`, `Money Leaks`) |
| `AppTextStyles.h3` | `18px` | SemiBold (`w600`) | Modal headers, chart card headers |
| `AppTextStyles.bodyLG` | `16px` | Regular (`w400`) / Medium (`w500`) | Primary transaction titles, key narrative lines |
| `AppTextStyles.bodyMD` | `14px` | Regular (`w400`) | Standard body paragraphs, form input text |
| `AppTextStyles.bodySM` | `12px` | Regular (`w400`) | Secondary descriptions, timestamps, metadata |
| `AppTextStyles.labelSM` | `10px` | Bold (`w700`) | Uppercase badges (`CRITICAL`, `HIGH IMPACT`) |

---

## 4. Component Guidelines

### 4.1. Card Design (`AppSurfaceCard`)
- **Visual Structure**: Cards must have a rounded radius (`radius16`), subtle surface background (`AppColors.cardBackground`), and a `1px` translucent border (`AppColors.cardBorder`) to separate them from the canvas.
- **Padding**: Enforce uniform `EdgeInsets.all(16)` for standard cards, and `EdgeInsets.all(20)` for primary summary cards.
- **Interactive Feedback**: Clickable cards must wrap in `InkWell` or `GestureDetector` with animated scaling down to `0.98` on tap.

### 4.2. Charts & Data Visualizations
- **Responsiveness**: Charts (pie charts, bar charts, line graphs) must adapt dynamically to available container widths using `LayoutBuilder` or `Expanded` containers.
- **Empty & Zero-Data Handling**: Never render broken axes or overlapping zero labels when transaction lists are empty. Render a clean placeholder illustration with `AppEmptyState` explaining how to log data.
- **Color Consistency**: Always map expense/income categories to their dedicated, immutable design system colors (`ExpenseCategory.foodAndDining.color`) across all charts and summary lists so users build subconscious visual associations.

### 4.3. Lists & Scrolling
- **Virtualization**: Always use `ListView.builder` or `SliverList.builder` for lists exceeding 10 items.
- **Separators**: Use `ListView.separated` with `SizedBox(height: AppDimensions.spacing12)` rather than baking bottom margins into list item widgets.

### 4.4. Buttons (`AppPrimaryButton`, `AppSecondaryButton`)
- **Height**: Standard touch buttons must have a fixed height of `48px` to guarantee comfortable mobile touch targets (meeting WCAG 44x44px minimum accessibility guidelines).
- **Loading State**: When `isLoading == true`, buttons must disable click interactions and replace label text with an inline `20x20px` `CircularProgressIndicator` matching the label contrast color.

### 4.5. Dialogs & Bottom Sheets
- **Bottom Sheets**: Prefer `showModalBottomSheet` with `isScrollControlled: true` and rounded top corners (`radius24`) over centered popup dialogs for mobile forms and filters.
- **Finny Coach Dialogs**: Gamified coaching alerts must display the Finny mascot illustration alongside clear, action-driven CTA buttons.

---

## 5. UI State Guidelines: Loading, Empty, and Error States

Every screen and feature card **must** handle three critical non-ideal states cleanly:

### 5.1. Loading States (`AppLoadingIndicator` / Shimmer)
- **Shimmer Skeletons**: For full-screen or card content loading (`AnalyticsScreen`), render skeleton shimmer boxes (`Shimmer.fromColors`) matching the exact size and layout of the final cards. **Avoid showing blank screens with a single centered spinner.**

### 5.2. Empty States (`AppEmptyState`)
- **Action-Driven Empty States**: When a user has zero transactions or filtered reports return empty results, render:
  1. A custom vector illustration (`assets/images/finny/empty_state.png`).
  2. A clear headline (`"No transactions found for this period"`).
  3. A helpful secondary description (`"Try selecting a different month or log your first expense today!"`).
  4. An optional primary action button (`"Add Transaction"`).

### 5.3. Error States (`AppErrorBanner` / Error Screen)
- **User-Friendly Error Copy**: Never display raw technical stack traces or cryptic exception codes (`"Null check operator used on a null value"`) to the user.
- **Actionable Retry**: Always provide a visible `"Retry"` button that re-dispatches the starting BLoC event (`context.read<ReportBloc>().add(WatchTransactionsStarted())`).

---

## 6. Accessibility (a11y) Standards

1. **Color Contrast**: All text and icons must maintain at least a **4.5:1 contrast ratio** against their background colors (and **3:1** for large `displayLG`/`h1` headings).
2. **Semantic Labels**: All icon-only buttons (`IconButton`) and decorative charts must provide `semanticsLabel` properties (`IconButton(icon: Icon(Icons.add), tooltip: 'Add new transaction')`).
3. **Dynamic Font Scaling**: Text must wrap or scale gracefully when users increase system font sizes in iOS/Android accessibility settings without causing overflow `RenderFlex` clipping errors.

---

## 7. Reusable Shared Widget Strategy

### 7.1. Where Shared Widgets Live
- Universal, multi-feature UI widgets belong strictly inside `lib/core/widgets/` organized by structural category (`buttons/`, `cards/`, `inputs/`, `feedback/`).
- Feature-exclusive widgets (such as `GoalPredictionCard` or `MoneyLeaksCard`) belong inside `lib/features/analytics/presentation/widgets/`.

### 7.2. When to Create or Promote a Shared Widget
- **Rule of Two**: If a UI pattern or custom card is built for one screen, keep it private inside that feature's `presentation/widgets/` folder.
- **Promotion Threshold**: As soon as a second, unrelated feature requires the exact same visual structure, **promote and refactor** that component into `lib/core/widgets/` with clean, generic constructor parameters, replacing both feature-specific instances with the shared component.
