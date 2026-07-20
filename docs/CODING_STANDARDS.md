# Fingo Coding Standards & Development Guidelines

This document establishes the rigorous, non-negotiable coding standards for the Fingo codebase. Every human developer and AI coding agent working on Fingo must comply with these exact conventions to ensure maintainability, readability, performance, and stability at scale.

---

## 1. Comprehensive Naming Conventions

Consistency in naming allows engineers and automated tools to identify the purpose, layer, and lifecycle of any code artifact instantly without inspecting its implementation.

| Code Artifact | Convention | Example | Rules / Rationale |
| :--- | :--- | :--- | :--- |
| **Files** | `snake_case.dart` | `transaction_repository_impl.dart`, `health_score_card.dart` | Lowercase letters with underscores separating words. Must match the primary class name inside the file. |
| **Directories** | `snake_case` | `features/analytics/domain/usecases/`, `core/widgets/buttons/` | Lowercase letters with underscores. Pluralized for grouping folders (`usecases/`, `repositories/`, `widgets/`). |
| **Classes** | `PascalCase` | `TransactionRemoteDataSourceImpl`, `ReportBloc` | UpperCamelCase for all class names, abstract interfaces, and mixins. |
| **Widgets** | `PascalCase` + `[Suffix]` | `AnalyticsScreen`, `HealthScoreCard`, `PrimaryButton` | Top-level routes must end in `Screen` or `Page`. Reusable components must describe their structure (`Card`, `Button`, `Section`, `Dialog`). |
| **Methods & Functions** | `camelCase` | `calculateHealthScore()`, `watchTransactions()` | LowerCamelCase starting with a clear action verb (`get`, `fetch`, `watch`, `add`, `update`, `delete`, `calculate`, `validate`). |
| **Variables & Properties** | `camelCase` | `totalExpense`, `monthlyBudget`, `currentDate` | LowerCamelCase descriptive nouns. Boolean properties must start with `is`, `has`, `can`, or `should` (`isLoading`, `hasError`, `canSubmit`). |
| **Private Members** | `_camelCase` | `_allTransactions`, `_recalculateAndEmit()` | Prefix with a single underscore (`_`). Private fields must be placed at the top of the class definition before public methods. |
| **Constants** | `kPascalCase` or `UPPER_SNAKE_CASE` | `kDefaultMonthlyBudget`, `kMaxStreakRewardDiamonds`, `MAX_RETRY_ATTEMPTS` | Prefix domain/UI constants with `k` followed by PascalCase. Use `UPPER_SNAKE_CASE` exclusively for global system timeouts or OS-level environment keys. |
| **Enums & Values** | `PascalCase` (Enum)<br>`camelCase` (Values) | `enum ExpenseCategory { foodAndDining, shoppingAndFashion }` | Enums use PascalCase; individual enum values use clean camelCase (never uppercase or underscored). |
| **Extensions** | `PascalCase` + `Extension` | `CurrencyFormattingExtension`, `DateUtilsExtension` | Descriptive name ending in `Extension`. Must explicitly state what type it extends (`on double`, `on DateTime`). |
| **Repositories (Interface)** | `PascalCase` + `Repository` | `TransactionRepository`, `AuthRepository` | Pure abstract class inside `domain/repositories/`. No `I` prefix (`ITransactionRepository` is forbidden). |
| **Repositories (Impl)** | `PascalCase` + `RepositoryImpl` | `TransactionRepositoryImpl`, `AuthRepositoryImpl` | Class inside `data/repositories/` implementing the domain contract. |
| **BLoC / Cubit** | `PascalCase` + `Bloc` / `Cubit` | `TransactionBloc`, `ReportBloc`, `ThemeCubit` | State management class inside `presentation/bloc/`. |
| **BLoC Events** | `[Feature][Action]Event` | `TransactionAddedEvent`, `WatchTransactionsStartedEvent` | Must describe the past-tense action or user trigger that fired the event. |
| **BLoC States** | `[Feature][Status]State` | `TransactionLoadingState`, `TransactionLoadedState`, `TransactionErrorState` | Must explicitly represent the exact UI condition. |
| **Use Cases** | `[Verb][Noun]` | `AddTransaction`, `GenerateReport`, `SignInWithEmail` | PascalCase verb phrase inside `domain/usecases/`. Must implement `call(...)` method. |
| **Entities** | `PascalCase` (+ `Entity` optional) | `TransactionEntity`, `FinancialReport`, `MoneyLeak` | Pure domain class inside `domain/entities/`. Append `Entity` when naming collisions occur with existing external framework classes. |

### 1.1. Forbidden Generic Filenames & Anti-Patterns
To prevent architectural degradation where utility and helper folders become disorganized dumping grounds, **the following generic filenames are strictly forbidden across `lib/features/` and `lib/core/` unless explicitly qualified with their exact domain responsibility:**
- **FORBIDDEN**: `helper.dart`, `helpers.dart`, `utils.dart`, `utilities.dart`, `common.dart`, `shared.dart`, `manager.dart`, `handler.dart`, `service.dart`, `controller.dart`, `data.dart`, `misc.dart`.
- **REQUIRED QUALIFICATION**: Always name files after what they actually do or manage: `date_formatters.dart`, `sms_transaction_parser.dart`, `theme_mode_controller.dart`, `remote_config_service.dart`, `currency_extensions.dart`. If you cannot name a file without using `helper` or `common`, its responsibility is too vague and must be broken down.

---

## 2. Formatting & Syntax Standards

1. **Line Length & Formatting**: Enforce `80` to `100` characters max line width where practical. Always run `dart format .` or let IDE auto-format on save using official Dart formatting rules.
2. **Trailing Commas**: **Always insert trailing commas** on every multi-line constructor, method invocation, and widget tree structure. This ensures clean, readable `git diff` outputs.
3. **`const` Correctness**: Prefer `const` constructors everywhere possible (`const SizedBox(height: 16)`, `const PrimaryButton(...)`). The Dart compiler optimizes const widgets out of the rebuild tree, providing massive UI performance gains.
4. **Imports Hierarchy**: Organize imports neatly in three distinct, blank-line-separated blocks:
   ```dart
   // 1. Dart SDK imports
   import 'dart:async';
   import 'dart:math';

   // 2. External package imports
   import 'package:flutter/material.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:dartz/dartz.dart';

   // 3. Project internal imports (relative paths within feature, package paths across boundaries)
   import '../../domain/entities/transaction_entity.dart';
   import '../../../../core/utils/logger.dart';
   ```

---

## 3. Comments & Documentation Standards

1. **Self-Documenting Code First**: Write clear, descriptive method and variable names. Avoid redundant inline comments that merely restate what the code syntax already says (`// increment i` over `i++`).
2. **Class & Public API Docstrings**: Every public class, repository method, use case, and shared widget **must** have a standard Dart docstring (`///`) explaining *why* it exists and what business constraints apply:
   ```dart
   /// Orchestrates real-time transaction ingestion from Firebase Firestore.
   ///
   /// Emits [Either<Failure, List<TransactionEntity>>] whenever the underlying
   /// user document or collection changes. Automatically handles offline cache fallbacks.
   class WatchTransactions { ... }
   ```
3. **Complex Logic Rationale**: Use single-line `//` comments exclusively to explain *non-obvious mathematical formulas, workarounds for third-party SDK bugs, or critical business edge cases*.

---

## 4. Error Handling & Exception Standards

1. **No Raw Try/Catch in Presentation**: UI Widgets and BLoCs must **never** catch raw framework `Exception` instances directly. All exceptions (`FirebaseException`, `SocketException`, `FormatException`) must be caught inside `data/repositories/` and converted into typed `Failure` classes via `dartz`.
2. **Standard Either Pattern**: All async domain operations must return `Future<Either<Failure, T>>` (or `Stream<Either<Failure, T>>`). Never return nullable data types (`Future<T?>`) to signify business failures.
3. **Explicit Failure Hierarchy**: Always map specific data source exceptions to corresponding `Failure` subclasses (`ServerFailure`, `NetworkFailure`, `AuthFailure`, `ValidationFailure`, `CacheFailure`).
4. **Never Ignore Errors**: Never write empty `catch (e) {}` blocks. If an error is safely ignorable by intentional design, log it with a warning (`AppLogger.w('Ignored non-fatal error: $e')`).

---

## 5. Null Safety & Immutability Rules

1. **No Bang Operator (`!`)**: The null-assertion operator (`!.` or `!`) is **strictly forbidden** across domain and presentation code unless guaranteed by an immediate prior null check within the same block. Use clean null-coalescing (`??`), pattern matching (`if (value case final v?)`), or explicit early returns (`if (value == null) return;`).
2. **Strict Immutability**: All Domain Entities, BLoC States, and BLoC Events must be marked with `const` constructors and declare every field as `final`.
3. **Value Equality (`Equatable`)**: Entities, Models, and States must extend `Equatable` and override `get props` with all member properties. Without value equality, BLoC emits identical state instances over and over, triggering excessive widget rebuilds.

---

## 6. Async Programming & Streams

1. **Avoid `DateTime.now()` inside Pure Domain Use Cases**: Use cases must remain deterministic and testable. Pass `DateTime currentDate` from the BLoC or caller into the use case `call(...)` method (`generateInsights(..., currentDate: DateTime.now())`).
2. **Stream Lifecycle Management**: Whenever a BLoC or service subscribes to a `Stream`, the resulting `StreamSubscription` **must** be stored in a private field (`_subscription`) and explicitly cancelled in the `close()` or `dispose()` method.
3. **Prefer `async/await` over `.then()`**: Write synchronous-looking, readable asynchronous workflows using `async/await`. Avoid nested callback chains using `.then().catchError()`.

---

## 7. Dependency Injection Standards

1. **Constructor Injection Only**: All Use Cases, Repositories, Data Sources, and BLoCs must receive their dependencies via constructor parameters (`GenerateInsights({required this.generateReport})`). Never access global service locators (`sl<T>()`) directly from inside business logic or domain methods.
2. **Factory vs. Singleton**:
   - Register BLoCs/Cubits exclusively as `Factory` (`sl.registerFactory(() => ReportBloc(...))`).
   - Register Use Cases, Repositories, and Data Sources as `LazySingleton`.

---

## 8. Testing Standards & Coverage Guidelines

1. **Domain Layer (100% Target Coverage)**: Because pure domain use cases (`GenerateReport`, `GenerateInsights`) and entities have zero framework dependencies, they must be rigorously covered by fast unit tests verifying exact mathematical formulas, boundary conditions, and explainability reasons.
2. **Repository Unit Tests**: Test repository implementations by mocking remote and local data sources using `mockito` or `mocktail`. Verify that successful data source calls return `Right(Entity)` and exceptions return `Left(Failure)`.
3. **BLoC Tests (`bloc_test`)**: Verify state transitions using `blocTest<Bloc, State>()`. Test that emitting an event triggers the expected sequence of `Loading -> Loaded` or `Loading -> Error` states.
4. **Widget / Headless Tests**: Verify that presentation screens render required UI states cleanly without crashes when supplied with mock BLoC states (`BlocProvider<ReportBloc>.value(value: mockReportBloc, child: AnalyticsScreen())`).

---

## 9. Project-Wide Performance Guidelines

To maintain a rock-solid `60 FPS` (and `120 FPS` on ProMotion/High-refresh displays) across complex financial charts and long transaction histories, every developer and AI agent must adhere to these performance architecture rules:

### 9.1. Frame Rate Budget & Repaint Isolation (`RepaintBoundary`)
- **Repaint Boundaries for Animations & Charts**: Any widget that animates (`ProgressIndicator`, `FLChart`, particle effects, glowing headers) or updates frequently independent of its parent **must be wrapped in a `RepaintBoundary`**. This forces Flutter to composite the widget on a dedicated display layer, preventing expensive re-rasterization of surrounding static widgets (`AppSurfaceCard`, text labels).
- **Target Frame Time**: All synchronous `build()` execution across a screen must complete within `8 milliseconds` (`16ms` budget split between CPU build and GPU rasterization).

### 9.2. `const` Element Tree Optimization
- **Mandatory `const` Constructors**: Every widget with immutable parameters must be instantiated with `const` (`const SizedBox(height: 16)`, `const AppEmptyState(...)`). When a parent widget rebuilds, Flutter short-circuits evaluation for any child marked `const`, preserving existing element allocations and avoiding object churn.
- **Class vs Function Extraction**: Always extract UI sections into `StatelessWidget` classes (`class _HeaderSection extends StatelessWidget`) rather than private helper functions (`Widget _buildHeader()`). Functions re-execute entirely on parent rebuilds, whereas class widgets leverage `const` caching and short-circuit reconciliation.

### 9.3. Isolate Offloading for Heavy Computation (`Isolate.run()`)
- **Offload CPU-Intensive Tasks**: Never run heavy JSON/VCF parsing, multi-thousand-item aggregation, large CSV generation, or cryptographic operations on the main UI thread (`Isolate`).
- **Standard Offload Pattern**: Use `await Isolate.run(() => heavyCalculation(data))` inside repository implementations (`data/repositories/`) or heavy domain usecases (`GenerateReport`) to keep the UI frame rate buttery smooth during processing.

### 9.4. Virtualized & Lazy Rendering (`SliverList` / `ListView.builder`)
- **No Unbounded Lists**: Never render scrollable collections using `Column(children: list.map(...).toList())` or `ListView(children: ...)`. For lists exceeding 15 items, **always use lazy-loading virtualization via `ListView.builder` or `CustomScrollView` with `SliverList.builder`**.
- **Fixed Extent Caching**: Whenever item heights are uniform (`TransactionItemRow`), use `ListView.builder(itemExtent: 72.0, ...)` or `SliverFixedExtentList`. This allows Flutter's scroll engine to calculate layout offsets in $O(1)$ constant time rather than measuring every item dynamically.

### 9.5. Precision BLoC Rebuild Filtering (`buildWhen` & `BlocSelector`)
- **Never Rebuild on Unrelated State Fields**: When connecting a widget to a complex BLoC state (`ReportState`), always provide a explicit `buildWhen: (previous, current) => previous.selectedPeriod != current.selectedPeriod` or use `BlocSelector<ReportBloc, ReportState, String>`. This prevents chart widgets from rebuilding when unrelated UI flags (`isExporting`) toggle.

### 9.6. Zero Domain UI String Formatting
- **Domain Numeric Purity**: The `domain` layer must return raw numeric primitives (`double netSavings`, `double? amount`). All string formatting (`.toCurrency()`, `toStringAsFixed()`, locale symbols) must occur inside `presentation/widgets/` to avoid unnecessary object allocation and locale coupling inside business logic.

## 10. BLoC UI Widget Usage Strategy

When connecting presentation widgets to BLoCs (`flutter_bloc`), select the exact widget that matches your reactivity requirement to eliminate redundant rebuilds and side-effect bugs:

| BLoC Widget | Primary Purpose | When to Use | When NOT to Use |
| :--- | :--- | :--- | :--- |
| **`BlocBuilder`** | Pure UI rendering based on state changes. | When building or rebuilding a widget tree in response to state changes (`if (state is ReportLoaded) return SummaryCards();`). Always supply `buildWhen` if only a subset of state fields matter. | Do **NOT** use for navigation, showing `SnackBar` or dialogs, or firing external callbacks. |
| **`BlocSelector`** | Precision rendering based on a single property. | When a widget only cares about a specific primitive property (`bool isLoading` or `int totalTransactions`) from a complex state object. Prevents rebuilds when unrelated state fields change. | Do not use if the widget depends on the entire state class hierarchy or multiple unrelated properties. |
| **`BlocListener`** | One-time side effects (`void` actions). | For navigation (`context.go()`), showing `SnackBar`/`Dialog`, triggering haptics, or calling analytics events when state changes. Always supply `listenWhen` to prevent re-firing on duplicate transitions. | Do **NOT** return widgets or perform UI rendering inside `listener`. |
| **`BlocConsumer`** | Combined UI rendering AND one-time side effects. | When a screen must both render UI (`builder`) **and** perform side effects (`listener`), such as showing a loading spinner while listening for an error snackbar or success navigation. | Do not use when you only need one of the two capabilities (`builder` without `listener` or vice versa). |

---

## 11. Required Lint Rules & Analysis Options

To enforce architectural integrity automatically, our `analysis_options.yaml` (and CI pipelines) must mandate the following strict lint rules (`linter: rules:`):

```yaml
linter:
  rules:
    # Architectural & Clean Boundary Protection
    - avoid_relative_lib_imports
    - always_use_package_imports
    - avoid_empty_else
    - avoid_print
    - camel_case_types
    - camel_case_extensions
    - constant_identifier_names
    - non_constant_identifier_names
    - package_names
    - file_names
    
    # Immutability & Const Correctness
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - prefer_final_in_for_each
    
    # Error Prevention & Async Safety
    - unawaited_futures
    - cancel_subscriptions
    - close_sinks
    - avoid_returning_null_for_future
    - avoid_shadowing_type_parameters
    - no_duplicate_case_values
    - valid_regexps
    - use_build_context_synchronously
```

---

## 12. Size Recommendations & Widget Extraction Guidelines

### 12.1. Method & Class Size Recommendations
- **Methods (`<= 30 lines`)**: Any single method exceeding 30 lines of code is trying to do too much. Extract distinct calculation blocks or widget assembly steps into private helper methods or separate pure functions.
- **Classes (`<= 200 lines`)**: Keep classes laser-focused on a single responsibility. If a class surpasses 200 lines, split it into smaller delegates, mixins, or distinct domain objects.

### 12.2. Widget Extraction & `build()` Complexity Limits
- **`build()` Method Limit (`<= 50 lines`)**: A widget `build(BuildContext context)` method must never exceed 50 lines. If a `build()` method grows larger, you must immediately break down the layout tree.
- **Class Extraction Over Helper Methods (`class` vs `Widget _build...()`)**:
  - **MANDATORY**: Always extract complex UI sub-trees into distinct, private or public `StatelessWidget` classes (`class _SummaryHeaderSection extends StatelessWidget`).
  - **FORBIDDEN**: Do not use private methods returning `Widget` (`Widget _buildHeader(BuildContext context)`) to structure complex layouts. Class-based widgets allow Flutter's rendering pipeline to short-circuit rebuilds using `const` and element caching, whereas helper methods force the entire method body to re-execute every time the parent widget rebuilds.

---

## 13. AI & Developer Code Review Checklist

Before committing any code or finalizing an AI-assisted prompt response, verify every item on this checklist:

- [ ] **Clean Boundaries**: Does `domain/` have zero imports from `flutter/material.dart`, `data/`, `presentation/`, or `app_extensions.dart`?
- [ ] **Constructor Injection**: Are all dependencies passed via constructor without calling `sl<T>()` inside domain/BLoC methods?
- [ ] **Raw Domain Numbers**: Do domain entities/use cases expose pure `double`/`int` values without `₹`, `$`, or `.toCurrency()` strings?
- [ ] **No Static Caches**: Are static caching structures (`static _cache`) avoided in favor of real-time BLoC/Firestore streams?
- [ ] **Single Source of Truth**: Are shared calculation/filtering tasks (like report aggregation) delegated to existing use cases (`GenerateReport`) rather than duplicated across files?
- [ ] **Null Safety**: Are all `!.` bang operators eliminated and replaced with safe null handling?
- [ ] **Immutability & Equatable**: Do all entities and BLoC states extend `Equatable` with complete `props` lists and `final` properties?
- [ ] **Stream Cleanup**: Are all `StreamSubscription` instances properly cancelled in `close()` / `dispose()`?
- [ ] **Error Propagation**: Are raw exceptions caught in `data/repositories/` and returned cleanly as `Either<Failure, T>`?
- [ ] **BLoC Widget Selection**: Are `BlocBuilder`, `BlocSelector`, `BlocListener`, and `BlocConsumer` chosen correctly without side-effects inside builders?
- [ ] **Widget Extraction**: Are all complex layout sections extracted into `StatelessWidget` classes rather than `Widget _build...()` helper methods?
- [ ] **Static Analysis & Tests**: Does `flutter analyze` report `0 issues found` and do all `flutter test` suites pass?
