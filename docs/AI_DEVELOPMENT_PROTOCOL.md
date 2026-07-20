# Fingo AI Development Protocol

This document establishes the mandatory, non-negotiable operational protocol for any Artificial Intelligence coding assistant (including Antigravity, Google Gemini, Anthropic Claude, OpenAI ChatGPT, and automated CI agents) working within the Fingo codebase. 

**Every AI model interacting with this repository MUST strictly follow the rules, reading sequences, and verification protocols below before generating, modifying, refactoring, or moving any code.**

---

## 1. Required Reading Order of Documentation

Before executing any prompt that modifies source code or architecture, an AI agent **must** read and verify compliance against the project documentation in the following exact sequence:

```
Step 1: docs/AI_DEVELOPMENT_PROTOCOL.md (This document - rules of engagement)
  ↓
Step 2: docs/ARCHITECTURE.md (Source of truth for clean layers & dependencies)
  ↓
Step 3: docs/FOLDER_STRUCTURE.md (Exact file placement rules & decision trees)
  ↓
Step 4: docs/CODING_STANDARDS.md (Naming, BLoC usage, linting, and formatting)
  ↓
Step 5: docs/STATE_MANAGEMENT.md (BLoC vs Cubit vs Ephemeral state rules)
  ↓
Step 6: docs/UI_GUIDELINES.md (Design system, spacing, and state UI tokens)
  ↓
Step 7: docs/FEATURE_DEVELOPMENT_GUIDE.md (Lifecycle & step-by-step order of operations)
```

---

## 2. Mandatory Rules Before Changing Code

1. **No Assumptions Without Inspection**: Never assume where a file exists or what methods a class contains based on generic assumptions. Always use targeted read tools (`view_file`, `grep_search`, `list_dir`) to inspect the exact current state of the code before proposing edits.
2. **Never Violate Clean Architecture Boundaries**: Under no circumstances is an AI permitted to import `flutter/material.dart`, `features/*/data/`, `features/*/presentation/`, `app_extensions.dart`, or database SDKs (`cloud_firestore`, `firebase_auth`) into any file inside a `domain/` directory.
3. **Zero Direct Cross-Feature Imports & Forbidden Filenames**: Never import `lib/features/[feature_A]/` directly inside `lib/features/[feature_B]/` (use GoRouter paths, usecase composition, or core contracts). Never create generic dumping grounds (`helper.dart`, `utils.dart`, `common.dart`, `manager.dart`); always qualify filenames (`date_formatters.dart`, `theme_controller.dart`).
4. **Check Existing Implementations First**: Before creating a new helper, utility, or UI card, search `lib/core/utils/`, `lib/core/widgets/`, and existing features to ensure you are not duplicating existing domain logic or UI structures.
5. **Preserve Unrelated Comments & Documentation**: Preserve all existing docstrings (`///`) and inline comments that are unrelated to your immediate code edits. Never strip or truncate existing documentation.

---

## 3. Rules for Feature Implementation

1. **Follow the Standard Feature Lifecycle**: Implement layers strictly from the inside out: `Domain -> Data -> Presentation (BLoC) -> Presentation (Widgets) -> Tests -> Documentation`. See `docs/FEATURE_DEVELOPMENT_GUIDE.md`.
2. **Single Responsibility per Usecase**: Every usecase inside `domain/usecases/` must perform exactly one business capability (`AddTransaction`, `WatchTransactions`) and return `Future<Either<Failure, T>>` or `Stream<Either<Failure, T>>`.
3. **No UI String Formatting in Domain**: Never format currency (`₹`, `$`, `.toCurrency()`), percentages, or date strings inside entities or usecases. Return raw numeric primitives (`double`, `int`, `DateTime`) and let presentation widgets format them using `formatters.dart` or design system extensions.
4. **Use `const` and `final` Everywhere**: Declare all entity fields, state properties, and widget parameters as `final`. Use `const` constructors on every widget, event, and state instance.

---

## 4. Rules for Refactoring Code

1. **Zero Functionality Degradation**: When refactoring code for architectural improvement, **never change business logic, break existing real-time Firestore streams, or alter UI pixel layouts unless explicitly instructed by the user.**
2. **No Unsafe Caching Wrappers**: Never introduce static in-memory caches (`static List<T> _cache`) or global state traps inside usecases or repositories to bypass reactive BLoC/Firestore streams.
3. **Incremental & Safe Modifications**: Use precise file replacement tools (`replace_file_content` for contiguous edits, `multi_replace_file_content` for non-contiguous edits). Avoid overwriting entire files unless rewriting an entire module from scratch.
4. **Eliminate Legacy Anti-Patterns**: When modifying code that touches legacy global state (`FingoState.instance`, `sl<FingoState>()`), actively decouple the feature by migrating state dependencies to clean BLoCs (`TransactionBloc`, `ReportBloc`).

---

## 5. Rules for Architecture Changes

1. **Strict User Approval Required**: Any change that modifies the Core Architecture (`ARCHITECTURE.md`), introduces a new top-level directory outside `lib/features/` or `lib/core/`, or alters the Clean Architecture dependency graph requires prior planning mode documentation and explicit user sign-off.
2. **Log Every Architectural Decision**: If an architectural change is approved and implemented, the AI agent **must** append a formal Architectural Decision Record (`ADR-XXX`) to `docs/DECISION_LOG.md` documenting the context, decision, rationale, and consequences.

---

## 6. Rules for File Movement & Renaming

1. **No Arbitrary Moving or Renaming**: Do not move, rename, or reorganize files across directories unless specifically instructed by the user as part of an explicit refactoring or folder cleanup task.
2. **Fix All Imports and References**: If instructed to move or rename a file, you must immediately run `grep_search` across the entire repository to locate and update every single import, part declaration, DI registration, and test reference pointing to that file.
3. **Verify Clean Boundaries Post-Move**: After moving a file into a new layer (`data` vs `domain` vs `presentation`), immediately check its imports to ensure it does not violate the allowed dependency matrix of its new home.

---

## 7. Rules for Dependency Injection

1. **Constructor Injection Only**: Every class in `domain/`, `data/`, and `presentation/bloc/` must accept dependencies strictly through named constructor parameters (`GenerateInsights({required this.generateReport})`).
2. **No Direct Service Locator (`sl<T>()`) Calls Inside Business Logic**: Never call `sl<T>()` directly inside usecase methods, repository implementations, or BLoC event handlers. `sl` should only be accessed inside `injection_container.dart`, top-level route definitions (`app.dart`), and top-level `BlocProvider(create: (_) => sl<MyBloc>())` widget wrappers.
3. **Register BLoCs as `Factory`**: In `injection_container.dart` (or feature DI modules), always register BLoCs and Cubits via `sl.registerFactory(() => MyBloc(...))`. Never register a BLoC as a `LazySingleton` unless it manages app-wide lifecycle state (`AuthBloc`).

---

## 8. Rules for State Management

1. **Mandatory BLoC (`flutter_bloc`) Usage**: All feature screens must use `flutter_bloc` (`Bloc` or `Cubit`) for state orchestration. Never introduce new `ChangeNotifier` classes for feature state or domain data flows.
2. **Stream Safety & Cleanup**: Whenever a BLoC subscribes to a domain stream (`WatchTransactions`), store the `StreamSubscription?` in a private field (`_subscription`) and explicitly cancel it (`await _subscription?.cancel()`) both inside event handlers when restarting and inside `close()`.
3. **No Asynchronous Emits Inside `.listen()`**: When listening to streams, do not invoke `emit()` asynchronously inside the `.listen(...)` callback. Dispatch an internal event (`add(TransactionsUpdated(data))`) or use `emit.forEach(...)` to guarantee safe state emission.
4. **Extend `Equatable`**: All `BlocEvent`, `BlocState`, `Entity`, and `Model` classes must extend `Equatable` and list all fields inside `get props`.

---

## 9. Rules for Code Generation (`build_runner`)

1. **Verify Annotation Syntax**: If modifying files that rely on code generation (`@freezed`, `@JsonSerializable()`, `@injectable`), ensure that syntax, part declarations (`part 'my_model.g.dart';`), and constructor formatting are 100% compliant before running generators.
2. **Run Commands Safely**: When required to regenerate code, propose `dart run build_runner build --delete-conflicting-outputs` via terminal execution (`run_command`) and wait for verification. Never manually edit `.g.dart` or `.freezed.dart` generated files.

---

## 10. Required Verification Steps

After completing any code modification, feature implementation, or refactor, an AI agent **must proactively execute** the following verification steps:

1. **Static Analysis Check**: Run `flutter analyze` via `run_command` and ensure the output is exactly:
   ```
   Analyzing expense_tracker_redesigned...
   No issues found!
   ```
   If any linter warnings, errors, or deprecation notices occur, the AI **must immediately fix them** before concluding the task.
3. **Zero New Warnings**: Confirm that your code introduced zero new analyzer warnings (`unused_element`, `missing_required_param`, `deprecated_member_use`).
4. **Architecture Health Checklist Audit**: Review and explicitly verify every item on the **Architecture Health Checklist (`ARCHITECTURE.md` Section 13)** (`Domain Purity`, `No Core-to-Feature Imports`, `Zero Cross-Feature Imports`, `DTO Composition`, `Stream Cleanup`, `No Static Caches`, `No Forbidden Generic Filenames`).

---

## 11. Deliverables Expected After Every Implementation

Whenever an AI assistant completes a user task, it must present a clean, structured summary containing exact deliverables:

1. **Summary of Files Created / Modified**: A bulleted or tabular list of every file touched (`[MODIFY]`, `[NEW]`, `[DELETE]`) with clickable `file://` links and a 1-sentence explanation of what changed in that file.
2. **Architecture Compliance Check**: Explicit item-by-item confirmation that the **Architecture Health Checklist (`ARCHITECTURE.md` Section 13)** was satisfied:
   - Clean Architecture boundaries & zero cross-feature imports respected.
   - DTO composition and explicit mappers (`toEntity()`) utilized.
   - Constructor injection was used (`generateReport: sl()`).
   - Domain layer returns raw numeric primitives without `₹` or currency formatting.
   - BLoC stream subscriptions are cancelled cleanly in `close()`.
   - File size limits and qualified filenames maintained.
3. **Verification & Test Results**: The exact terminal output confirmation of `flutter analyze` (`No issues found!`) and `flutter test` (`All tests passed!`).
4. **Walkthrough / Task Artifact Update**: If operating in Planning Mode, update `task.md` with completed `[x]` items and create/update `walkthrough.md` documenting the technical accomplishments.
