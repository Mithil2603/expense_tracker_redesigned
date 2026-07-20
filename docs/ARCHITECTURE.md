# Fingo Architecture Documentation

This document is the authoritative **source of truth** for the overall system architecture, design philosophy, layer boundaries, and structural rules of the Fingo Flutter application. Every developer, AI assistant, and automated code generation tool **must** strictly adhere to the principles outlined here.

---

## 1. Project Philosophy & Vision

Fingo is built to scale from its current footprint to **100+ screens, 50+ modular features, and multiple distributed engineering teams** while maintaining sub-second UI responsiveness, rock-solid stability, zero-regression feature additions, and full test coverage.

### Core Pillars
1. **Separation of Concerns & Single Responsibility**: Every class, file, and layer has exactly one well-defined reason to change. Business rules must never know about Flutter UI rendering, and UI widgets must never perform direct data queries or transformations.
2. **Predictable & Unidirectional Data Flow**: Data flows strictly downward from Data to Domain to Presentation. User events and state flow deterministically via BLoC streams.
3. **Modularity & Independence**: Features are designed as autonomous modules. Modifying or replacing a data source, UI screen, or external SDK in one feature must never cascade failures into unrelated features.
4. **Offline-First & Real-Time Sync**: Fingo treats offline usage and real-time cloud synchronization (via Firebase/Firestore) as first-class architectural requirements.
5. **AI-Assisted Development Readiness**: Clean boundaries, deterministic conventions, and standardized file structures ensure that automated agents (Antigravity, Gemini, Claude) can generate, analyze, and test code safely without human guessing or structural decay.

---

## 2. Architecture Style: Clean Architecture + Feature-First Modularity

Fingo employs **Clean Architecture** (inspired by Robert C. Martin) combined with a **Feature-First Folder Structure**. 

### Why Clean Architecture?
At scale, applications that organize code solely by technical layer (e.g., all controllers together, all views together) suffer from immense cognitive overhead and tight coupling. Clean Architecture enforces:
- **Testability**: Business logic (Use Cases and Entities) resides in pure Dart classes with zero framework dependencies, allowing ultra-fast, 100% covered unit tests.
- **Framework & SDK Independence**: If we migrate from Firebase to REST, GraphQL, or Supabase, or switch caching engines, ONLY the `data` layer changes. The `domain` and `presentation` layers remain untouched.
- **Maintainable Scale**: Multiple developers and AI agents can work simultaneously inside different feature domains without merge conflicts.

### Feature-First Organization
Instead of grouping files globally by type (`lib/controllers`, `lib/models`, `lib/views`), Fingo groups code primarily by **Domain Feature** (`lib/features/expenses`, `lib/features/analytics`, `lib/features/auth`). Each feature encapsulates its own 3-tier Clean Architecture layers (`data`, `domain`, `presentation`).

---

## 3. The Dependency Rule

```
+-----------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                                 |
|  Widgets, Screens, BLoCs, Controllers                                             |
+-----------------------------------------------------------------------------------+
                                        |
                                        | (depends only on Domain)
                                        v
+-----------------------------------------------------------------------------------+
|                                   DOMAIN LAYER                                    |
|  Entities, Use Cases, Repository Contracts (Interfaces)                           |
+-----------------------------------------------------------------------------------+
                                        ^
                                        | (implements Domain interfaces)
                                        |
+-----------------------------------------------------------------------------------+
|                                    DATA LAYER                                     |
|  Repository Implementations, Remote/Local Data Sources, API Clients, DTOs/Models  |
+-----------------------------------------------------------------------------------+
```

### Strict Rules of Dependency Flow
1. **Domain Layer is King**: The `domain` folder is the core of the feature. It has **ZERO dependencies** on `data`, `presentation`, Flutter SDK (`flutter/material.dart`), or external infrastructure libraries (`cloud_firestore`, `firebase_auth`, `http`). It depends strictly on pure Dart (`dart:async`, `dart:math`) and core domain primitives (`dartz` for `Either`).
2. **Data Layer Depends Downward on Domain**: The `data` folder imports `domain/repositories/` to implement abstract repository contracts, and `domain/entities/` to convert raw DTO models into clean domain entities.
3. **Presentation Layer Depends Downward on Domain**: BLoCs (`presentation/bloc/`) and Widgets (`presentation/pages/`, `widgets/`) import `domain/usecases/` and `domain/entities/`. They must **NEVER** import `data/datasources/`, `data/models/`, or `data/repositories/` directly.
4. **Core Must Never Depend on Features**: `lib/core/` houses global utilities, network abstractions, themes, shared design tokens, and infrastructure components. **No file inside `lib/core/` is permitted to import anything from `lib/features/`.**

---

## 4. Layer Responsibilities & Granular Breakdown

### 4.1. Domain Layer (`lib/features/[feature]/domain/`)
The pure business core of the feature.
- **Entities (`domain/entities/`)**: Immutable, core domain objects (`TransactionEntity`, `FinancialReport`). They contain only essential domain data and pure business validation methods. They do NOT contain `fromJson`/`toJson` (which belong to Data models) or UI formatting helpers (`toCurrency()`).
- **Use Cases (`domain/usecases/`)**: Single-action orchestrators representing exact user interactions or system capabilities (`AddTransaction`, `GenerateReport`, `WatchTransactions`). Every use case executes a single unit of business logic and returns a typed `Future<Either<Failure, T>>` or `Stream<Either<Failure, T>>`.
- **Repository Contracts (`domain/repositories/`)**: Pure abstract classes (`abstract class TransactionRepository`) defining what data operations the domain requires without detailing how data is retrieved.

### 4.2. Data Layer (`lib/features/[feature]/data/`)
The infrastructure and serialization backbone.
- **Models / DTOs (`data/models/`)**: Independent Data Transfer Objects (`TransactionModel`) that represent external API schemas or database structures. **Models should use Composition and Explicit Mappers (`toEntity()` / `fromEntity()`) rather than inheriting from (`extends`) Domain Entities.** While `extends Entity` is suitable for simple prototypes, at enterprise scale (`100+ screens`, complex Firestore mappings, nested JSON), inheritance couples clean domain entities to database serialization annotations (`@JsonSerializable`, `FieldValue`), nullable database fields, and mutability. By keeping `TransactionModel` independent and providing explicit `.toEntity()` and `.fromEntity(entity)` transformation methods, the domain remains 100% insulated against backend schema migrations.
- **Data Sources (`data/datasources/`)**: Direct communicators with external APIs, local SQLite/Isar/Hive databases, secure storage, or Firestore streams (`TransactionRemoteDataSource`, `TransactionLocalDataSource`). Data sources throw explicit `ServerException` or `CacheException` on errors.
- **Repository Implementations (`data/repositories/`)**: Classes implementing the `domain/repositories` interfaces (`TransactionRepositoryImpl`). They coordinate between Remote and Local Data Sources, handle caching logic, catch `Exception` instances from data sources, convert DTO models to domain entities (`model.toEntity()`), and return pure domain `Failure` objects via `dartz`.

### 4.3. Presentation Layer (`lib/features/[feature]/presentation/`)
The visual interface and state management layer.
- **BLoCs / Cubits (`presentation/bloc/` or `presentation/controllers/`)**: State containers receiving UI Events from widgets, executing one or more Use Cases, processing `Either<Failure, T>` results, and emitting immutable, reactive UI States (`TransactionLoading`, `TransactionLoaded`, `TransactionError`).
- **Pages / Screens (`presentation/pages/`)**: Top-level scaffold views mapped directly to application routes (`AnalyticsScreen`, `ExpensesScreen`). Screens compose modular widgets and inject feature BLoCs via `BlocProvider`.
- **Widgets (`presentation/widgets/`)**: Reusable, feature-specific UI components (`HealthScoreCard`, `MoneyLeaksCard`). They receive pure entities, state values, or callback handlers via constructor parameters and render the interface according to our Design System.

---

## 5. Allowed vs. Forbidden Dependencies Matrix

| Layer | Can Import | MUST NEVER Import |
| :--- | :--- | :--- |
| **Domain (`features/*/domain/`)** | Pure Dart, `dartz` (`Either`), `equatable`, other `domain/entities` | `flutter/material.dart`, `features/*/data/`, `features/*/presentation/`, `core/widgets/`, `cloud_firestore`, `firebase_auth` |
| **Data (`features/*/data/`)** | `features/*/domain/`, `core/network/`, `core/errors/`, `cloud_firestore`, serialization libraries | `features/*/presentation/`, `flutter/material.dart` (except basic diagnostics/logging) |
| **Presentation (`features/*/presentation/`)** | `features/*/domain/`, `core/`, `flutter_bloc`, `go_router`, `flutter/material.dart` | `features/*/data/` (models, datasources, repository implementations) |
| **Core (`lib/core/`)** | External SDKs, `dart:*`, `flutter/material.dart` | **ANYTHING inside `lib/features/`** |

---

## 6. End-to-End Data Flow Diagram

### 6.1. Standard Action Flow (e.g., Adding a Transaction)
```
[User Taps "Add Transaction" Button in UI Widget]
                         |
                         v
[Screen/Widget dispatches AddTransactionEvent to TransactionBloc]
                         |
                         v
[TransactionBloc calls AddTransaction UseCase passing TransactionEntity]
                         |
                         v
[AddTransaction UseCase calls TransactionRepository.addTransaction(entity)]
                         |
                         v
[TransactionRepositoryImpl checks network, converts Entity -> TransactionModel]
                         |
                         v
[TransactionRepositoryImpl invokes TransactionRemoteDataSource.addTransaction(model)]
                         |
                         v
[RemoteDataSource writes document to Firebase Firestore]
                         |
                         +---> (Success: Returns void / Document ID)
                         |---> (Failure: Throws ServerException)
                         |
                         v
[RepositoryImpl catches Exception, returns Right(void) or Left(ServerFailure)]
                         |
                         v
[TransactionBloc receives Either<Failure, void>, emits TransactionSuccessState / ErrorState]
                         |
                         v
[UI Listenable / BlocListener reacts to state, closes modal or shows Error SnackBar]
```

---

## 7. Core Strategies

### 7.1. Dependency Injection Strategy
- **Framework**: `GetIt` (`sl`) located in `lib/di/injection_container.dart` (transitioning to modular `init[Feature]Module()` structure for scalability).
- **Registration Rules**:
  - **External Infrastructure / Core Services**: Registered as `LazySingleton` (`FirebaseAuth`, `FirebaseFirestore`, `NetworkInfo`, `AppRouter`).
  - **Repositories & Data Sources**: Registered as `LazySingleton`.
  - **Use Cases**: Registered as `LazySingleton`.
  - **BLoCs / Cubits**: **Always registered as `Factory`** (`sl.registerFactory(() => TransactionBloc(...))`). A BLoC must never be a global singleton unless explicitly designed as an application-wide lifecycle manager (e.g., `AuthBloc`).

### 7.2. Error Handling Strategy
- **Exceptions vs. Failures**:
  - `Exception` (`ServerException`, `CacheException`, `AuthException`) is an infrastructure-level error thrown only inside `data/datasources/` or `core/network/`.
  - `Failure` (`ServerFailure`, `NetworkFailure`, `ValidationFailure`) is a clean business error returned strictly inside `Either<Failure, T>` from Repositories to Use Cases and BLoCs.
- **Rule of No Uncaught Exceptions**: Repositories must wrap every data source invocation in a `try/catch` block. Use Cases and BLoCs must never crash from raw unhandled exceptions.

### 7.3. Logging & Diagnostics Strategy
- **Framework**: Standardized via `AppLogger` (`lib/core/utils/logger.dart`).
- **Levels**:
  - `AppLogger.i(...)` — Informational events (BLoC transitions, screen visits, lifecycle changes).
  - `AppLogger.w(...)` — Warnings (retrying network requests, missing non-critical configs).
  - `AppLogger.e(...)` — Errors with explicit stack trace logging (`AppLogger.e('Failed to fetch transactions', error, stackTrace)`).
- **No `print()` or `debugPrint()`**: Direct standard output printing is forbidden in production code.

### 7.4. Firebase & Real-Time Stream Strategy
- **Clean Stream Ingestion**: Real-time updates (e.g., Firestore transaction listeners) must enter the domain layer through clean stream use cases (`WatchTransactions` returning `Stream<Either<Failure, List<TransactionEntity>>>`).
- **BLoC Stream Subscriptions**: BLoCs subscribe to domain streams inside `on<WatchTransactionsStarted>` events using `emit.forEach(...)` or managed `StreamSubscription` lifecycle handlers cancelled cleanly in `close()`.
- **Decoupled Caching**: Firestore's offline persistence SDK is leveraged at the data source layer (`TransactionRemoteDataSourceImpl`). Domain use cases do not implement manual in-memory static caches (`static List<T> _cache`) to bypass stream reactivity.

### 7.5. Performance & Offline Considerations
- **Immutable State Changes**: All entities, models, and BLoC states extend `Equatable` (`List<Object?> get props => [...]`) to prevent redundant widget rebuilds.
- **Heavy Computation Isolation**: Resource-intensive aggregation loops (such as multi-year analytics calculations in `GenerateReport`) must run inside pure, UI-decoupled use cases and leverage `Isolate.run()` or compute functions when dataset sizes exceed 1,000+ items.
- **Lazy Loading & Pagination**: Data queries fetching history logs, transactions, or leaderboard rankings must enforce pagination (`limit`, `startAfterDocument`) at the data source level rather than loading entire collections into memory.

### 7.6. Reusable Component Strategy
- **Atomic Design Breakdown**: Shared UI components live strictly inside `lib/core/widgets/` categorized by structural hierarchy:
  - `core/widgets/buttons/` (Primary, Secondary, Icon buttons)
  - `core/widgets/cards/` (Surface containers, elevation wrappers)
  - `core/widgets/inputs/` (Text fields, date pickers, dropdowns)
  - `core/widgets/feedback/` (Loading indicators, error banners, empty states)
- **Feature vs. Shared**: A widget used only inside Analytics belongs in `lib/features/analytics/presentation/widgets/`. Only when a widget is used across two or more distinct features does it get promoted and refactored into `lib/core/widgets/`.

## 8. Maximum Recommended File Sizes

To preserve scannability and prevent monolithic coupling (`40KB+` dumping grounds), strictly enforce the following lines-of-code (LOC) thresholds across architectural artifacts:

| Code Artifact | Hard Limit (Lines) | Recommended Target (Lines) | Splitting Strategy When Exceeded |
| :--- | :--- | :--- | :--- |
| **Pages / Screens (`presentation/pages/`)** | `250 lines` | `100 - 150 lines` | Extract visual sections (`Header`, `SummaryCards`, `ListSection`) into distinct files inside `presentation/widgets/`. |
| **Widgets (`presentation/widgets/`, `core/widgets/`)** | `150 lines` | `60 - 100 lines` | Break complex nested layouts into sub-widgets or atomic subcomponents (`_CardHeader`, `_CardBody`). |
| **BLoCs / Cubits (`presentation/bloc/`)** | `300 lines` | `120 - 200 lines` | Split distinct sub-flows into separate BLoCs (`ReportFilterBloc` vs `ReportDataBloc`) or delegate complex data transformations to domain usecases. |
| **Use Cases (`domain/usecases/`)** | `100 lines` | `30 - 60 lines` | A usecase should do one thing. If exceeding 100 lines, extract helper domain calculation methods or split into smaller granular usecases. |
| **Entities (`domain/entities/`)** | `100 lines` | `30 - 50 lines` | Extract value objects (e.g., `MoneyAmount`, `DateRange`) if an entity has too many nested structures. |
| **Repositories (Interface & Impl)** | `200 lines` | `80 - 120 lines` | If a repository exceeds 200 lines, the feature boundary is too broad (`TransactionRepository` vs `RecurringTransactionRepository`). Split into focused domain repositories. |

---

## 9. Decision Tree for Where New Code Belongs

```
START: I need to add or modify code in Fingo.
│
├── Is this code universally shared across multiple distinct features?
│   ├── YES (It is domain-agnostic or multi-feature):
│   │   ├── Is it an atomic UI component (Button, Card, Input)? -> `lib/core/widgets/[category]/`
│   │   ├── Is it a global service (Firebase RemoteConfig, RevenueCat)? -> `lib/core/services/`
│   │   ├── Is it a global routing configuration? -> `lib/core/router/`
│   │   ├── Is it a global error/failure definition? -> `lib/core/errors/`
│   │   ├── Is it a utility helper (debouncer, logger, date formatter)? -> `lib/core/utils/`
│   │   └── Is it a global design token or theme engine? -> `lib/core/constants/` or `lib/core/theme/`
│   │
│   └── NO (It belongs to a specific business feature):
│       ├── Does this feature folder exist in `lib/features/`?
│       │   ├── NO -> Create `lib/features/[feature_name]/` following the exact 3-tier structure (`data`, `domain`, `presentation`).
│       │   └── YES -> Navigate inside `lib/features/[feature_name]/`
│       │
│       └── What type of feature code is this?
│           ├── Is it a top-level route screen scaffold? -> `presentation/pages/[feature]_screen.dart`
│           ├── Is it a feature-exclusive UI widget/card? -> `presentation/widgets/[feature]_[widget].dart`
│           ├── Is it BLoC state orchestration? -> `presentation/bloc/[feature]_bloc.dart`
│           ├── Is it pure business orchestration (`call()`)? -> `domain/usecases/[verb]_[noun].dart`
│           ├── Is it an immutable domain business object? -> `domain/entities/[entity]_entity.dart`
│           ├── Is it an abstract repository interface? -> `domain/repositories/[feature]_repository.dart`
│           ├── Is it a repository implementation with `dartz`? -> `data/repositories/[feature]_repository_impl.dart`
│           ├── Is it a DTO model (`fromJson`/`toFirestore`)? -> `data/models/[entity]_model.dart`
│           └── Is it raw database/API interaction? -> `data/datasources/[feature]_[remote/local]_data_source.dart`
```

---

## 10. Rules for Splitting Large Files

When any file approaches or surpasses the maximum recommended file size limits defined in Section 8, apply these structural splitting rules immediately:

1. **Extract by Responsibilities, Not Arbitrary Parts**: Never split a class into `part 'widget_part1.dart';` just to reduce line counts. Split cleanly by extracting distinct classes (`StatelessWidget`, `UseCase`, or `Repository`) into independent files.
2. **Screen De-cluttering Rule**: A top-level screen (`AnalyticsScreen`) must only contain the `Scaffold`, `AppBar`, `BlocBuilder`/`BlocConsumer` wrappers, and top-level layout structure (`CustomScrollView` / `SliverList`). Every visual section (`HeaderSection`, `FilterSection`, `SummarySection`, `ChartSection`) must reside inside its own separate file inside `presentation/widgets/`.
3. **BLoC Event/State Separation**: Never keep `Event` and `State` classes inside the main `[feature]_bloc.dart` file. Keep `[feature]_event.dart`, `[feature]_state.dart`, and `[feature]_bloc.dart` strictly isolated.
4. **Data Source Method Grouping**: If a `RemoteDataSource` exceeds 200 lines due to handling complex batch operations, queries, and mutations, extract specific query groups into helper classes or distinct data source contracts (`TransactionQueryDataSource` vs `TransactionMutationDataSource`).

---

## 11. Rules for Promoting Reusable Widgets into Core

To prevent `lib/core/widgets/` from becoming a bloated dumping ground while ensuring true reusability across teams, adhere to the **Promotion Protocol**:

1. **The Rule of Two (Private First)**: Whenever a custom widget, card, or visual component is built for a specific screen (`AnalyticsScreen`), place it inside `lib/features/analytics/presentation/widgets/`. Do NOT place single-use widgets inside `lib/core/widgets/`.
2. **Promotion Trigger**: As soon as a second, independent feature (`lib/features/budgeting/`) requires the exact same visual structure or component, that component is officially eligible for promotion to `lib/core/widgets/`.
3. **Refactoring Checklist for Promotion**:
   - Strip out all feature-specific domain entities (`TransactionEntity`) from the widget's constructor parameters.
   - Replace entity arguments with generic primitives or callbacks (`final String title`, `final double amount`, `final VoidCallback onTap`).
   - Move the file to `lib/core/widgets/[atomic_category]/` (`buttons/`, `cards/`, `inputs/`, `feedback/`).
   - Update both feature modules to import and use the new shared component from `core/widgets/`.

## 12. Feature Boundary Rules & Cross-Feature Communication

To guarantee true modularity where features can be developed by independent teams or extracted into standalone Dart packages (`packages/features/analytics`), Fingo enforces strict feature isolation:

### 12.1. The Zero Direct Cross-Feature Import Rule
**No file inside `lib/features/[feature_A]/` is permitted to directly import anything from `lib/features/[feature_B]/`.**
- **FORBIDDEN**: `lib/features/analytics/presentation/bloc/report_bloc.dart` importing `lib/features/expenses/data/models/transaction_model.dart`.
- **FORBIDDEN**: `lib/features/budgeting/presentation/pages/budget_screen.dart` importing `lib/features/expenses/presentation/widgets/transaction_card.dart`.

### 12.2. Approved Cross-Feature Communication Patterns
When two distinct domain features must interact, use one of the three enterprise-approved communication patterns:
1. **Navigation & Deep-Linking (UI to UI)**: If `AnalyticsScreen` needs to navigate to `TransactionDetailsScreen`, do not import the target screen class. Navigate strictly via GoRouter path strings passing primitive IDs (`context.push('${AppRoutes.expenses}/detail/$transactionId')`).
2. **Domain Use Case Composition (BLoC to Domain)**: If `ReportBloc` (Analytics) needs to observe transactions (Expenses), it must accept the pure domain usecase `WatchTransactions` (`lib/features/expenses/domain/usecases/watch_transactions.dart`) via constructor injection. Usecases and Entities are the ONLY contracts allowed across feature boundaries when explicitly composed at the DI/usecase layer, but must never be bypassed by accessing data sources or models directly.
3. **Core Shared Contracts (Global Infrastructure)**: If two features must share reactive state that spans the entire application lifecycle (e.g., active user tier, current auth state), communicate via shared core services (`lib/core/services/`) or core interfaces.

---

## 13. Architecture Health Checklist (Mandatory Pre-Merge Audit)

Every feature pull request, refactor, or AI-assisted implementation **must pass 100% of the items on this Health Checklist before merge**:

### Layer Separation & Clean Architecture
- [ ] **Domain Purity**: Does `domain/` contain zero imports from `flutter/material.dart`, `data/`, `presentation/`, `app_extensions.dart`, or database SDKs?
- [ ] **No Core-to-Feature Imports**: Is `lib/core/` completely free of references to classes, entities, or models inside `lib/features/`?
- [ ] **Zero Cross-Feature Data Imports**: Does `lib/features/[feature_A]/` avoid direct imports of `data/` or `presentation/` files from `lib/features/[feature_B]/`?
- [ ] **Composition & Mappers**: Do Data Models (`data/models/`) use composition (`toEntity()` / `fromEntity()`) rather than `extends Entity`?

### State Management & BLoC
- [ ] **Constructor Injection**: Are all dependencies passed through constructors (`MyBloc({required this.useCase})`) without direct `sl<T>()` service locator calls inside business/BLoC methods?
- [ ] **BLoC Factory Registration**: Is every feature BLoC registered via `sl.registerFactory(...)` rather than `LazySingleton`?
- [ ] **Stream Subscription Cleanup**: Are all `StreamSubscription` instances stored inside `_subscription` and explicitly cancelled inside `close()`?
- [ ] **No Static Caches**: Are domain usecases and repositories free of static caching structures (`static _cache`)?
- [ ] **Immutability & Equatable**: Do all entities, events, states, and models declare `final` fields, `const` constructors, and extend `Equatable` with complete `props` overrides?

### Code Quality & Sizing
- [ ] **File Size Thresholds**: Do all touched files respect maximum limits (`Pages <= 250 LOC`, `Widgets <= 150 LOC`, `BLoCs <= 300 LOC`)?
- [ ] **No Forbidden Generic Filenames**: Are generic dumping grounds (`helper.dart`, `utils.dart`, `common.dart`, `manager.dart`) avoided in favor of qualified names?
- [ ] **Zero Bang Operators (`!`)**: Are all null-assertion operators eliminated and replaced with safe null-coalescing (`??`) or early returns?
- [ ] **Raw Domain Numbers**: Do domain entities and use cases return pure primitives (`double`, `int`) without `.toCurrency()` formatting strings?
- [ ] **Static Analysis & Tests**: Does `flutter analyze` output `No issues found!` and do all automated suites (`flutter test`) pass?

---

## 14. Architectural Evolution Roadmap (100+ Screens Scale)

To maintain pristine boundaries as Fingo scales toward 50+ features and multiple engineering teams, the architecture will systematically evolve along the following trajectory:

1. **Feature Module Split (`di/modules/`)**: Break the single `injection_container.dart` file into domain-scoped registration modules (`initAuthModule()`, `initExpensesModule()`, `initAnalyticsModule()`).
2. **Global State De-monolithization (`FingoState` Migration)**: Dismantle `core/utils/fingo_state.dart`. Migrate user profile stats to `ProfileBloc`/`ProfileRepository`, rewards/quests to `GamificationBloc`/`GamificationRepository`, and eliminate direct feature imports inside `core`.
3. **Local Database Synchronization Layer**: Introduce `Isar` or `Hive` local data sources across all repositories with formal sync queues (`TransactionLocalDataSource`), ensuring true zero-latency offline performance independent of Firebase connection states.
4. **Strict Package/Workspace Modularization (`melos`)**: Transition feature directories into distinct Dart internal packages (`packages/features/analytics`, `packages/core/design_system`) enforced by build-time boundary lint rules.
