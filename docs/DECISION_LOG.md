# Fingo Architecture Decision Log (ADR)

This document records the major architectural and technical decisions (`Architectural Decision Records` / ADRs) made across the lifecycle of the Fingo application. Every significant structural choice, framework adoption, and layer boundary standard is documented here with its context, rationale, and consequences to provide clear historical clarity for future engineering teams and AI coding agents.

---

## ADR-001: Adoption of Clean Architecture

### Status
Accepted & Enforced across all feature modules.

### Context
As Fingo evolves from a prototype into a enterprise-grade, multi-feature personal finance platform (`100+ screens`, `50+ features`), organizing code strictly by technical concerns (`lib/controllers`, `lib/views`, `lib/models`) creates severe coupling, spaghetti dependencies, and untestable codebases where changing a UI widget risks breaking core calculation logic.

### Decision
We adopt **Clean Architecture** with strict downward dependency rules (`Presentation -> BLoC -> Domain -> Data`) where the `domain` layer is completely decoupled from UI, framework libraries, and external database SDKs (`cloud_firestore`).

### Rationale & Benefits
1. **100% Testable Business Core**: Because `domain/usecases/` and `domain/entities/` depend strictly on pure Dart without Flutter SDK bindings (`flutter/material.dart`), our core financial algorithms (`GenerateReport`, `GenerateInsights`) execute inside microsecond unit tests with zero UI mocks.
2. **Database & API Agnosticism**: If Fingo migrates from Firebase to a custom REST backend or GraphQL service in the future, only the `data/datasources/` and `data/repositories/` layers change. Domain logic and presentation screens remain entirely untouched.
3. **Multi-Developer Isolation**: Autonomous teams can work on different layers without stepping on each other's toes.

### Consequences
- Requires boilerplate separation (Entities vs. Models, Repository Interfaces vs. Repository Implementations).
- Strict linting and review checks must be enforced to prevent developers or AI assistants from importing UI extensions (`app_extensions.dart`) or data models (`TransactionModel`) inside domain use cases.

---

## ADR-002: Adoption of Feature-First Folder Structure

### Status
Accepted & Enforced (`lib/features/[feature]/`).

### Context
Grouping files globally by type (`lib/usecases/`, `lib/repositories/`, `lib/screens/`) forces developers to jump across dozens of unrelated folders to understand or modify a single feature like `expenses` or `analytics`.

### Decision
We structure the codebase by autonomous feature domains (`lib/features/expenses/`, `lib/features/analytics/`, `lib/features/auth/`), where each feature contains its own self-contained Clean Architecture layers (`data/`, `domain/`, `presentation/`).

### Rationale & Benefits
1. **High Cohesion**: All code related to budgeting or analytics lives inside a single directory, making onboarding and feature comprehension instantaneous.
2. **Modular Extraction Readiness**: As the codebase scales toward multi-package architectures (`melos`), feature folders can be extracted into isolated local packages (`packages/features/analytics`) with explicit `pubspec.yaml` dependency boundaries.

### Consequences
- Universal utilities and truly shared widgets must be consciously identified and placed inside `lib/core/` to prevent accidental feature-to-feature cross-imports.

---

## ADR-003: Standardization of BLoC (`flutter_bloc`) for State Management

### Status
Accepted & Enforced for all domain and feature-level state flows.

### Context
Managing asynchronous data transitions, real-time Firestore streams, form validation, and error states using basic `ChangeNotifier` singletons (`FingoState`) or unstructured `setState` calls results in unmanageable race conditions, memory leaks, and untestable UI states.

### Decision
We mandate **BLoC (Business Logic Component)** via `flutter_bloc` (`Bloc` and `Cubit`) as the single, authoritative state management pattern for feature presentation layers.

### Rationale & Benefits
1. **Unidirectional & Predictable**: User events enter via `add(Event())`, async use cases process the payload, and distinct, immutable states (`Loading`, `Loaded`, `Error`) are emitted.
2. **Traceability & Time-Travel Debugging**: Because every state transition is triggered by an explicit event object, logs (`AppLogger`) capture exactly what user actions caused every screen change.
3. **Stream Management**: `flutter_bloc` provides robust, built-in stream handling (`emit.forEach`) and predictable disposal lifecycles (`close()`).

### Consequences
- Ephemeral, single-widget UI states (`AnimationController`, local toggle buttons) should still use `StatefulWidget` to avoid unnecessary BLoC boilerplate.
- Legacy `ChangeNotifier` singletons (`FingoState`) must be systematically deprecated and migrated into feature-scoped BLoCs as the architecture scales.

---

## ADR-004: Firebase as Cloud Backend & Real-Time Sync Engine

### Status
Accepted (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_remote_config`).

### Context
Fingo requires real-time transaction updates across user devices, seamless social authentication, cloud entitlement checking, and zero-maintenance serverless infrastructure.

### Decision
We adopt **Google Firebase** (`Cloud Firestore` for data storage and `Firebase Auth` for identity) accessed exclusively through data-layer data sources (`TransactionRemoteDataSourceImpl`).

### Rationale & Benefits
1. **Real-Time Stream Ingestion**: Firestore's `snapshots()` stream capabilities map perfectly to our `WatchTransactions` domain use case, enabling instant UI updates across dashboard and analytics screens when transactions are modified.
2. **Built-in Offline Persistence**: Firestore's mobile SDK provides out-of-the-box local cache persistence when devices lose internet connectivity, aligning with our offline-first core strategy.

### Consequences
- All Firebase imports (`cloud_firestore`, `firebase_auth`) are strictly confined to `data/datasources/` and `core/services/`. **No file in `domain/` or `presentation/` is permitted to import Firebase SDKs directly.**

---

## ADR-005: Use of Repository Pattern & Explicit Failure Handling (`Either<Failure, T>`)

### Status
Accepted (`dartz` library for `Either` monad).

### Context
Uncaught network exceptions (`SocketException`, `FirebaseException`) bubbling up directly into UI widgets cause unexpected app crashes and inconsistent error message banners.

### Decision
We enforce the **Repository Pattern** where `domain/repositories/` defines abstract interfaces, and `data/repositories/` implements them by wrapping all data source calls in `try/catch` blocks and returning functional `Either<Failure, T>` results.

### Rationale & Benefits
1. **Compile-Time Error Checking**: BLoCs calling use cases are forced by the compiler (`result.fold((failure) => ..., (success) => ...)`) to handle both success and error branches explicitly.
2. **Clean Error Propagation**: Infrastructure exceptions are mapped to human-readable domain failures (`ServerFailure`, `NetworkFailure`, `AuthFailure`) with actionable retry messages.

### Consequences
- Repositories must never allow raw `Exception` instances to escape unhandled into the `domain` or `presentation` layers.

---

## ADR-006: Single Source of Truth Use Case Architecture (`GenerateReport` Reuse)

### Status
Accepted (Demonstrated during Reports Module Refactoring).

### Context
In complex analytical workflows (`GenerateInsights`), multiple domain methods previously performed manual, duplicated filtering (`allTransactions.where(...)`) and category aggregation loops across raw transaction lists for previous-period reports and weekly reviews.

### Decision
We enforce that core calculation use cases (`GenerateReport`) serve as the **Single Source of Truth**. Higher-level intelligence engines (`GenerateInsights`) must inject and reuse `GenerateReport` via constructor injection to produce all comparative time-period reports (`previousReport`, `weeklyReport`).

### Rationale & Benefits
1. **Zero Duplication**: Sorting, filtering, and mathematical aggregation logic (`totalIncome`, `netSavings`, `savingsRate`) exists in exactly one place (`GenerateReport`).
2. **Performance & Consistency**: Any performance optimization or bug fix applied to `GenerateReport` immediately benefits all downstream analytical engines and UI cards across the app.

### Consequences
- All use cases must remain pure (`currentDate` passed via parameter) and constructor-injected (`GetIt` registration: `sl.registerLazySingleton(() => GenerateInsights(generateReport: sl()))`).

---

## ADR-007: Adoption of DTO Composition & Explicit Mappers over Model Inheritance (`toEntity` / `fromEntity`)

### Status
Accepted (Mandatory for enterprise scaling across 100+ screens and multi-API schemas).

### Context
In early prototypes, Data Transfer Objects (`data/models/TransactionModel.dart`) directly inherited from Domain Entities (`class TransactionModel extends TransactionEntity`). While concise initially, as the application scales across multiple backend providers, Firestore metadata annotations (`@JsonSerializable`, `FieldValue.serverTimestamp()`), nullable API fields, and database field mapping differences, subclassing couples pure domain entities directly to infrastructure serialization rules.

### Decision
We mandate **Composition and Explicit Mappers (`toEntity()` / `fromEntity()`)** over inheritance (`extends Entity`) for all Data Layer models. DTOs are independent data holders that provide `.toEntity()` to produce immutable domain objects and `.fromEntity(entity)` to construct serialization payloads.

### Rationale & Benefits
1. **Total Domain Insulation**: If Firestore changes schema, introduces nullable types, or splits a document across collections, only `TransactionModel` changes; `TransactionEntity` remains 100% untouched.
2. **Immutability Protection**: Database models often require mutable constructors or nullable fields during serialization parsing, whereas domain entities must remain strictly non-nullable and `final`.

### Consequences
- Every repository implementation must explicitly map `models.map((m) => m.toEntity()).toList()` when returning domain lists.

---

## ADR-008: Strict Feature Isolation & Forbidden Cross-Feature Direct Imports

### Status
Accepted (Mandatory for multi-team and multi-package scalability).

### Context
As an application grows to 50+ features and 100+ screens, direct imports across feature folders (`lib/features/analytics/` directly importing `lib/features/expenses/presentation/widgets/...`) create spaghetti dependency graphs, circular build errors, and make extracting features into independent Dart packages (`melos` / `packages/`) impossible.

### Decision
We enforce the **Zero Direct Cross-Feature Import Rule**: No file inside `lib/features/[feature_A]/` may directly import any file inside `lib/features/[feature_B]/`.

### Approved Communication Channels Across Features
1. **Navigation (UI to UI)**: Route via GoRouter path strings with primitive arguments (`context.push('/expenses/detail/$id')`).
2. **Domain Composition (BLoC to Domain)**: Inject domain usecases (`WatchTransactions`) from another feature via DI constructor parameters.
3. **Global Core Infrastructure**: Share system-wide state via `lib/core/services/` or `lib/core/contracts/`.

### Consequences
- Any shared UI widget used by more than one feature must be promoted to `lib/core/widgets/[atomic_category]/` following the Rule of Two and refactored to accept primitive parameters rather than domain entities.
