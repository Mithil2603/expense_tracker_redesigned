# Fingo Folder Structure & File Placement Guide

This document defines the exact, definitive folder structure for the Fingo application. When adding any new class, widget, service, use case, or feature, every developer and AI prompt **must** check this guide to place the file in its exact structural home. **No future prompt or developer should ever guess where files belong.**

---

## 1. High-Level Project Overview

```
expense_tracker_redesigned/
├── android/                   # Native Android OS configurations & Gradle scripts
├── ios/                       # Native iOS OS configurations & Xcode project
├── assets/                    # Static media files (images, icons, fonts, json)
├── docs/                      # Authoritative architecture & standards documentation
├── lib/                       # Primary application source code
│   ├── core/                  # Shared domain-agnostic infrastructure & design tokens
│   ├── di/                    # Dependency injection module & locator setup
│   ├── features/              # Autonomous domain modules (Clean Architecture)
│   ├── app.dart               # Root MaterialApp & root provider wrapper
│   ├── fingo.dart             # Root export barrel file
│   └── main.dart              # Application entry point & SDK initialization
├── test/                      # Unit, widget, and integration test suites
├── pubspec.yaml               # Project dependencies & asset declarations
└── analysis_options.yaml      # Static analysis & linter configurations
```

---

## 2. The `lib/features/` Directory (Feature-First Clean Architecture)

Every business domain inside Fingo lives as an independent module inside `lib/features/`. When creating a new feature (e.g., `budgeting`), you must generate the exact 3-tier structure below:

```
lib/features/[feature_name]/
├── data/                               # Infrastructure & serialization layer
│   ├── datasources/                    # Raw external/local data accessors
│   │   ├── [feature]_remote_data_source.dart # Firebase/REST API access
│   │   └── [feature]_local_data_source.dart  # SQLite/Isar/SecureStorage access
│   ├── models/                         # DTOs & database mapping models
│   │   └── [entity]_model.dart         # Extends Entity; handles fromJson/toFirestore
│   └── repositories/                   # Repository interface implementations
│       └── [feature]_repository_impl.dart    # Implements domain repository contract
│
├── domain/                             # Pure business logic core (ZERO UI/data imports)
│   ├── entities/                       # Core immutable business models
│   │   └── [entity]_entity.dart        # Pure Dart classes with Equatable
│   ├── repositories/                   # Abstract repository contracts
│   │   └── [feature]_repository.dart   # Interfaces returning Either<Failure, T>
│   └── usecases/                       # Single-action business orchestrators
│       ├── get_[entity].dart           # e.g., get_budget.dart
│       ├── add_[entity].dart           # e.g., add_budget.dart
│       └── watch_[entities].dart       # e.g., watch_budgets.dart
│
└── presentation/                       # UI & reactive state management layer
    ├── bloc/ (or controllers/)         # BLoCs / Cubits managing UI state
    │   ├── [feature]_bloc.dart         # Main BLoC class
    │   ├── [feature]_event.dart        # BLoC user triggers/events
    │   └── [feature]_state.dart        # BLoC reactive state definitions
    ├── pages/                          # Top-level route scaffold screens
    │   └── [feature]_screen.dart       # e.g., budgeting_screen.dart
    └── widgets/                        # Modular feature-specific components
        ├── [feature]_header.dart       # e.g., budgeting_header.dart
        ├── [feature]_card.dart         # e.g., budget_summary_card.dart
        └── [feature]_list_item.dart    # e.g., budget_category_item.dart
```

### Exact File Placement Rules for Features:
- **Where does `GenerateReport` go?** -> `lib/features/analytics/domain/usecases/generate_report.dart`
- **Where does `TransactionModel` go?** -> `lib/features/expenses/data/models/transaction_model.dart`
- **Where does `HealthScoreCard` go?** -> `lib/features/analytics/presentation/widgets/health_score_card.dart`
- **Where does `WatchTransactions` go?** -> `lib/features/expenses/domain/usecases/watch_transactions.dart`

---

## 3. The `lib/core/` Directory (Shared Infrastructure & Design System)

The `lib/core/` folder contains universal, feature-agnostic tools, extensions, and design tokens shared across the entire application. **Files inside `lib/core/` must never import anything from `lib/features/`.**

```
lib/core/
├── constants/                 # Universal application constants & keys
│   ├── app_colors.dart        # Core raw color hex tokens
│   ├── app_text_styles.dart   # Core typography styles & weights
│   ├── app_dimensions.dart    # Standard spacing, paddings, and radii
│   └── constants.dart         # Barrel export file
│
├── errors/                    # Standardized error contracts & hierarchy
│   ├── exceptions.dart        # Infrastructure exceptions (ServerException)
│   ├── failures.dart          # Clean business failures (ServerFailure)
│   └── errors.dart            # Barrel export file
│
├── network/                   # Network connectivity & HTTP/Firebase helpers
│   ├── network_info.dart      # Network connectivity checker interface & impl
│   └── network.dart           # Barrel export file
│
├── router/                    # Application routing & navigation rules
│   ├── app_router.dart        # GoRouter configuration & route tree
│   ├── app_routes.dart        # Route path string constants ('/analytics')
│   ├── auth_notifier.dart     # Router redirect listener for auth changes
│   └── router.dart            # Barrel export file
│
├── services/                  # Global infrastructure & third-party integrations
│   ├── billing/               # In-app purchase / RevenueCat services
│   ├── entitlement/           # User tier & feature unlocking services
│   ├── remote_config_service.dart # Firebase Remote Config synchronizer
│   └── notification_sync_service.dart # Local/push notification orchestrator
│
├── theme/                     # App styling, dark mode, and ThemeData engines
│   ├── app_theme.dart         # Light/Dark ThemeData configurations
│   ├── theme_provider.dart    # Theme mode switcher & state manager
│   └── theme.dart             # Barrel export file
│
├── utils/                     # Pure domain-agnostic utility helpers
│   ├── debouncer.dart         # Input/search action debouncing utility
│   ├── formatters.dart        # Date and numeric utility helpers
│   ├── logger.dart            # AppLogger diagnostics and console wrapper
│   ├── sms_parser.dart        # On-device SMS transaction regex parser
│   └── utils.dart             # Barrel export file
│
└── widgets/                   # Universal atomic shared UI components
    ├── buttons/               # AppPrimaryButton, AppSecondaryButton, AppIconButton
    ├── cards/                 # AppSurfaceCard, AppGlassCard
    ├── inputs/                # AppTextField, AppDatePicker, AppDropdown
    ├── feedback/              # AppLoadingIndicator, AppErrorBanner, AppEmptyState
    ├── app_custom_app_bar.dart# Shared navigation header bar
    └── widgets.dart           # Barrel export file
```

### Exact File Placement Rules for Core & Shared Files:
- **Where does `AppLogger` go?** -> `lib/core/utils/logger.dart`
- **Where does `AppRouter` go?** -> `lib/core/router/app_router.dart`
- **Where does `ServerFailure` go?** -> `lib/core/errors/failures.dart`
- **Where does a primary action button used on 10 different screens go?** -> `lib/core/widgets/buttons/app_primary_button.dart`
- **Where does a card widget used ONLY inside the Analytics screen go?** -> `lib/features/analytics/presentation/widgets/` (Do not dump single-use widgets into `core/widgets/`!).

---

## 4. Dependency Injection (`lib/di/`)

As Fingo scales, dependency injection must be partitioned into modular feature registrars rather than a single monolithic function.

```
lib/di/
├── injection_container.dart   # Main entry point calling all modular registrars
└── modules/                   # Feature-scoped DI registration modules
    ├── core_module.dart       # Registers Firebase, NetworkInfo, SecureStorage
    ├── auth_module.dart       # Registers AuthRepository, SignInWithEmail, AuthBloc
    ├── expenses_module.dart   # Registers TransactionRepository, WatchTransactions
    └── analytics_module.dart  # Registers GenerateReport, GenerateInsights, ReportBloc
```

---

## 5. Assets Directory (`assets/`)

```
assets/
├── icons/                     # Custom vector SVG / PNG application icons
├── images/                    # Static illustration & character assets
│   ├── finny/                 # Finny mascot character expressions & poses
│   └── onboarding/            # Welcome and onboarding screen graphics
└── json/                      # Static local mock datasets or config files
```

---

## 6. Decision Tree for Creating a New Feature

When starting work on a new requirement, use this decision tree to determine whether to create a brand-new feature directory (`lib/features/[feature_name]/`) or extend an existing module:

```
START: I need to build a new capability or screen.
│
├── Does this capability operate on an existing business entity or share state with an existing feature?
│   ├── YES (`transactions`, `expenses`, `receipt scanning`):
│   │   └── Do not create a new top-level feature. Extend `lib/features/expenses/` by adding the new usecases (`ScanReceipt`), data sources, and presentation widgets.
│   │
│   └── NO (It represents an autonomous domain, e.g., `budgeting`, `goals`, `recurring_bills`):
│       ├── Will it have its own dedicated data models, repository contract, and screens?
│       │   ├── YES -> Create a new top-level feature module: `lib/features/[snake_case_name]/`
│       │   │          Generate exact 3-tier subdirectories (`data`, `domain`, `presentation`).
│       │   │
│       │   └── NO (It is just a global setting or cross-cutting utility popup) -> Place inside `lib/core/` or `lib/features/profile/`.
```

---

## 7. Decision Tree for Placing a New File

```
START: I am creating a new file. Where does it belong?
│
├── Is the file specific to a single business domain (`budgeting`, `analytics`, `auth`)?
│   ├── YES -> Place inside `lib/features/[feature_name]/`
│   │   ├── Is it a top-level route screen scaffold? -> `presentation/pages/[feature]_screen.dart`
│   │   ├── Is it a feature-exclusive UI card or component? -> `presentation/widgets/[feature]_[widget].dart`
│   │   ├── Is it BLoC state management? -> `presentation/bloc/[feature]_[bloc/event/state].dart`
│   │   ├── Is it a single-action business execution class? -> `domain/usecases/[verb]_[noun].dart`
│   │   ├── Is it an immutable domain entity class? -> `domain/entities/[entity]_entity.dart`
│   │   ├── Is it an abstract repository interface? -> `domain/repositories/[feature]_repository.dart`
│   │   ├── Is it a repository implementation with `dartz`? -> `data/repositories/[feature]_repository_impl.dart`
│   │   ├── Is it a DTO model (`fromJson`/`toFirestore`)? -> `data/models/[entity]_model.dart`
│   │   └── Is it a database/API data source? -> `data/datasources/[feature]_[remote/local]_data_source.dart`
│   │
│   └── NO -> Place inside `lib/core/` (Must be universal across the entire application)
│       ├── Is it an atomic UI component (Button, Card, Input)? -> `core/widgets/[atomic_category]/`
│       ├── Is it a global service (RemoteConfig, Billing/RevenueCat)? -> `core/services/`
│       ├── Is it routing tree or auth redirect configuration? -> `core/router/`
│       ├── Is it a global failure or exception contract? -> `core/errors/`
│       ├── Is it a pure utility helper (debouncer, logger, formatters)? -> `core/utils/`
│       └── Is it a global color token or typography scale? -> `core/constants/` or `core/theme/`
```

---

## 8. Rules for Reusable Widgets

1. **Strict Placement by Reuse Count**: A widget created for a specific feature screen (`HealthScoreCard` inside Analytics) must reside in `lib/features/analytics/presentation/widgets/`. Only when a second feature requires that exact visual structure is it promoted to `lib/core/widgets/[atomic_category]/`.
2. **Domain-Agnostic Core Widgets**: Any widget living in `lib/core/widgets/` must have **zero imports from `lib/features/`**. Its constructor must accept primitive parameters (`final String title`, `final double amount`, `final VoidCallback onTap`) rather than domain entities (`TransactionEntity`).
3. **Atomic Categorization**: Never drop widgets directly into `lib/core/widgets/`. Categorize them strictly into:
   - `core/widgets/buttons/`
   - `core/widgets/cards/`
   - `core/widgets/inputs/`
   - `core/widgets/feedback/`

---

## 9. Rules for Creating Shared Services

1. **Definition of a Shared Service**: A service in `lib/core/services/` (`RemoteConfigService`, `EntitlementService`, `NotificationSyncService`) manages external third-party SDK lifecycles, background synchronization, or device-level hardware APIs that are completely decoupled from individual feature business rules.
2. **No Feature Repository Imports**: A shared service inside `lib/core/services/` must **never import feature repositories or domain entities**. If a service needs to inform the domain layer of a state change (e.g., entitlement unlocked), it must emit a clean stream or callback that feature BLoCs subscribe to via constructor injection.
3. **Singleton Lifecycle**: Shared services are registered in `injection_container.dart` (or `core_module.dart`) strictly as `LazySingleton` or `Singleton` initialized during application bootstrap.

---

## 10. Rules for Introducing New Dependencies (`pubspec.yaml`)

Before adding any new third-party package or SDK to `pubspec.yaml`, developers and AI agents must comply with the **Dependency Adoption Protocol**:

1. **No Redundant Packages**: Check if existing dependencies can accomplish the task. Never add a new state management package (`provider`, `riverpod`, `getx`) when `flutter_bloc` is our mandated standard. Never add utility packages for tasks solvable with 10 lines of clean Dart (`intl` date formatting vs ad-hoc date packages).
2. **Platform & Null-Safety Verification**: Any candidate package must support 100% sound null safety, target iOS and Android cleanly, and show active community maintenance (no abandoned packages).
3. **Explicit User Approval Required for AI Prompt Additions**: If an AI prompt determines that a task requires a new `pubspec.yaml` dependency, the AI must explicitly document the package name, justification, and version constraint, and request user review before running `flutter pub add`.

---

## 11. Rules for Feature Module Registration in Dependency Injection

As Fingo scales toward 50+ features, all dependency injection registrations must follow clean, modular grouping rules inside `lib/di/`:

1. **Transition to Feature Registrars (`lib/di/modules/`)**: When creating a new feature (`lib/features/budgeting/`), do not dump all registrations directly into the top-level function in `injection_container.dart`. Create a dedicated feature module (`lib/di/modules/budgeting_module.dart`) with an `initBudgetingModule()` function:
   ```dart
   // lib/di/modules/budgeting_module.dart
   import 'package:get_it/get_it.dart';
   import '../../features/budgeting/data/datasources/budget_remote_data_source.dart';
   import '../../features/budgeting/data/repositories/budget_repository_impl.dart';
   import '../../features/budgeting/domain/repositories/budget_repository.dart';
   import '../../features/budgeting/domain/usecases/watch_budgets.dart';
   import '../../features/budgeting/presentation/bloc/budget_bloc.dart';

   void initBudgetingModule(GetIt sl) {
     // Data sources & Repositories
     sl.registerLazySingleton<BudgetRemoteDataSource>(() => BudgetRemoteDataSourceImpl(firestore: sl()));
     sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(remoteDataSource: sl()));

     // Use cases
     sl.registerLazySingleton(() => WatchBudgets(sl()));

     // BLoC (Always Factory)
     sl.registerFactory(() => BudgetBloc(watchBudgets: sl()));
   }
   ```
2. **Top-Level Orchestration**: `injection_container.dart` calls each module registrar in explicit dependency order (`initCoreModule(sl)` -> `initAuthModule(sl)` -> `initExpensesModule(sl)` -> `initBudgetingModule(sl)`).
3. **Strict Factory Rule for BLoCs**: In every registration module, feature BLoCs (`BudgetBloc`, `ReportBloc`) **must always be registered via `sl.registerFactory(...)`**. Never register feature BLoCs as `LazySingleton` or `Singleton`.

```
Is the code specific to a business feature (e.g., expenses, analytics, auth)?
├── YES: Place inside `lib/features/[feature]/`
│   ├── Is it a UI Screen or Widget? -> `presentation/pages/` or `presentation/widgets/`
│   ├── Is it BLoC state management? -> `presentation/bloc/`
│   ├── Is it a pure business entity or usecase? -> `domain/entities/` or `domain/usecases/`
│   ├── Is it a repository contract? -> `domain/repositories/`
│   └── Is it database/Firebase access or DTO mapping? -> `data/datasources/`, `data/models/`, `data/repositories/`
│
└── NO: Place inside `lib/core/` (Must be universal across the entire app)
    ├── Is it a shared UI button, input, or card? -> `core/widgets/[atomic_category]/`
    ├── Is it application navigation or route definition? -> `core/router/`
    ├── Is it a global service (Firebase RemoteConfig, RevenueCat)? -> `core/services/`
    ├── Is it a global exception or failure contract? -> `core/errors/`
    ├── Is it a pure utility (logger, debouncer, date formatter)? -> `core/utils/`
    └── Is it a global color token or theme engine? -> `core/constants/` or `core/theme/`
```
