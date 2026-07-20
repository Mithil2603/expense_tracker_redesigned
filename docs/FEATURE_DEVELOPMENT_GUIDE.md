# Fingo Feature Development Guide

This guide describes the standard, step-by-step lifecycle required to implement any new feature or module inside the Fingo application. Every developer and AI coding agent must follow this exact sequence from inception to delivery to ensure architectural integrity and zero regression.

---

## The Feature Development Lifecycle

```
[Phase 1: Requirements & Architecture Review]
                         ↓
[Phase 2: Domain Layer (Entities & Use Cases)]
                         ↓
[Phase 3: Data Layer (Models, Data Sources & Repositories)]
                         ↓
[Phase 4: Presentation Layer (BLoC / Cubit Orchestration)]
                         ↓
[Phase 5: Presentation Layer (Screens & Atomic Widgets)]
                         ↓
[Phase 6: Testing (Unit, BLoC, & Widget Verification)]
                         ↓
[Phase 7: Optimization & Static Analysis Check]
                         ↓
[Phase 8: Documentation & DI Registration]
```

---

## Phase 1: Requirements & Architecture Review

Before writing a single line of code, clearly define the feature's boundary, data contracts, and structural dependencies:
1. **Identify the Feature Domain**: Name the feature using clean `snake_case` (`budgeting`, `goals`, `recurring_bills`).
2. **Determine Data Sources**: Decide if the feature requires remote Firestore collections (`/users/{uid}/budgets`), local Isar/SecureStorage persistence, or third-party API integration.
3. **Map Domain Contracts**: List exact entities, usecases, and repository methods required.
4. **Inspect Existing Shared Components**: Check `lib/core/widgets/` and `lib/core/utils/` to identify reusable cards, buttons, or formatters you can leverage instead of building from scratch.

---

## Phase 2: Domain Layer (The Pure Business Core)

Always build the `domain/` layer first. This layer has **ZERO dependencies** on Flutter UI or data serialization.

### Step 2.1: Define Entities (`domain/entities/`)
Create immutable, clean business classes extending `Equatable`:
```dart
// lib/features/budgeting/domain/entities/budget_entity.dart
import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double spent;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.spent,
  });

  @override
  List<Object?> get props => [id, userId, category, amount, spent];
}
```

### Step 2.2: Define Repository Contracts (`domain/repositories/`)
Create pure abstract interface classes returning `Either<Failure, T>`:
```dart
// lib/features/budgeting/domain/repositories/budget_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Stream<Either<Failure, List<BudgetEntity>>> watchBudgets(String userId);
  Future<Either<Failure, void>> setBudget(BudgetEntity budget);
}
```

### Step 2.3: Implement Use Cases (`domain/usecases/`)
Create single-action orchestrators accepting constructor-injected repositories:
```dart
// lib/features/budgeting/domain/usecases/watch_budgets.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class WatchBudgets {
  final BudgetRepository repository;

  WatchBudgets(this.repository);

  Stream<Either<Failure, List<BudgetEntity>>> call(String userId) {
    return repository.watchBudgets(userId);
  }
}
```

---

## Phase 3: Data Layer (Infrastructure & Serialization)

Build the infrastructure layer implementing the domain repository contracts.

### Step 3.1: Define Models (`data/models/`)
Create independent DTO models with explicit `toEntity()` / `fromEntity()` mappers and Firestore serialization:
```dart
// lib/features/budgeting/data/models/budget_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double spent;

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.spent,
  });

  BudgetEntity toEntity() => BudgetEntity(
    id: id,
    userId: userId,
    category: category,
    amount: amount,
    spent: spent,
  );

  factory BudgetModel.fromEntity(BudgetEntity entity) => BudgetModel(
    id: entity.id,
    userId: entity.userId,
    category: entity.category,
    amount: entity.amount,
    spent: entity.spent,
  );

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'category': category,
    'amount': amount,
    'spent': spent,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
```

### Step 3.2: Implement Data Sources (`data/datasources/`)
Create raw data accessors communicating directly with Firestore or SQLite:
```dart
// lib/features/budgeting/data/datasources/budget_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Stream<List<BudgetModel>> watchBudgets(String userId);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseFirestore firestore;

  BudgetRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<BudgetModel>> watchBudgets(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList());
  }
}
```

### Step 3.3: Implement Repository (`data/repositories/`)
Implement the domain contract, converting DTOs to entities (`model.toEntity()`) and returning `Either<Failure, T>`:
```dart
// lib/features/budgeting/data/repositories/budget_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<BudgetEntity>>> watchBudgets(String userId) {
    return remoteDataSource.watchBudgets(userId).map((models) {
      final entities = models.map((m) => m.toEntity()).toList();
      return Right<Failure, List<BudgetEntity>>(entities);
    }).handleError((error, stackTrace) {
      AppLogger.e('Error watching budgets', error, stackTrace);
      return Left<Failure, List<BudgetEntity>>(ServerFailure(error.toString()));
    });
  }
  
  @override
  Future<Either<Failure, void>> setBudget(BudgetEntity budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      // Call remoteDataSource.setBudget(model)...
      return const Right(null);
    } catch (e, st) {
      AppLogger.e('Error setting budget', e, st);
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

## Phase 4: Presentation Layer — BLoC Orchestration

Create `presentation/bloc/` containing reactive events, immutable states, and the BLoC orchestrator.

### Step 4.1: Define Events & States (`[feature]_event.dart`, `[feature]_state.dart`)
```dart
// lib/features/budgeting/presentation/bloc/budget_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}
class BudgetLoading extends BudgetState {}
class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  const BudgetLoaded(this.budgets);
  @override
  List<Object?> get props => [budgets];
}
class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);
  @override
  List<Object?> get props => [message];
}
```

### Step 4.2: Implement BLoC (`[feature]_bloc.dart`)
Inject domain use cases and handle stream subscriptions safely:
```dart
// lib/features/budgeting/presentation/bloc/budget_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/watch_budgets.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final WatchBudgets watchBudgets;
  StreamSubscription? _subscription;

  BudgetBloc({required this.watchBudgets}) : super(BudgetInitial()) {
    on<WatchBudgetsStarted>(_onWatchStarted);
    on<BudgetsUpdated>(_onBudgetsUpdated);
  }

  Future<void> _onWatchStarted(WatchBudgetsStarted event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    await _subscription?.cancel();
    _subscription = watchBudgets(event.userId).listen((result) {
      add(BudgetsUpdated(result));
    });
  }

  void _onBudgetsUpdated(BudgetsUpdated event, Emitter<BudgetState> emit) {
    event.result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) => emit(BudgetLoaded(budgets)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

---

## Phase 5: Presentation Layer — Screens & Atomic Widgets

Compose clean, modular UI screens inside `presentation/pages/` and `presentation/widgets/`.

### Step 5.1: Build Feature Widgets (`presentation/widgets/`)
Extract distinct card sections, charts, and list items into separate `StatelessWidget` files (`budget_progress_card.dart`, `budget_category_item.dart`). Format raw numbers (`toCurrency()`) right here inside the presentation widgets.

### Step 5.2: Build Top-Level Screen (`presentation/pages/`)
Wrap the screen in a `BlocProvider` (if not provided at the route level) and use `BlocBuilder` with explicit `buildWhen` parameters:
```dart
// lib/features/budgeting/presentation/pages/budgeting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../bloc/budget_bloc.dart';
import '../widgets/budget_progress_card.dart';

class BudgetingScreen extends StatelessWidget {
  const BudgetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppCustomAppBar(title: 'Budgets'),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BudgetError) {
            return AppErrorBanner(message: state.message, onRetry: () { ... });
          }
          if (state is BudgetLoaded) {
            if (state.budgets.isEmpty) {
              return const AppEmptyState(message: 'No budgets set for this month.');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              itemCount: state.budgets.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.spacing12),
              itemBuilder: (context, index) => BudgetProgressCard(budget: state.budgets[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

---

## Phase 6: Testing & Verification

1. **Write Unit Tests (`test/features/[feature]/`)**:
   - Test domain use cases with mock repository responses (`mockito` / `mocktail`).
   - Test `BudgetBloc` state transitions using `blocTest<BudgetBloc, BudgetState>()`.
2. **Execute Static Analysis**:
   ```bash
   flutter analyze
   ```
   Ensure zero warnings or issues exist.
3. **Execute Test Suite**:
   ```bash
   flutter test
   ```

---

## Phase 7: Optimization & Code Cleanup

1. **Check Build Complexity**: Ensure widget `build()` methods are lean and free of heavy synchronous calculations.
2. **Verify `const` Correctness**: Add `const` modifiers to every static widget and spacing container.
3. **Check `buildWhen` / `listenWhen`**: Add explicit filtering predicates to BLoC builders if the state object contains multiple independent variables.

---

## Phase 8: Documentation & DI Registration

1. **Register Dependencies (`lib/di/injection_container.dart` or module)**:
   ```dart
   // Data sources & Repositories
   sl.registerLazySingleton<BudgetRemoteDataSource>(() => BudgetRemoteDataSourceImpl(firestore: sl()));
   sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(remoteDataSource: sl()));
   
   // Use cases
   sl.registerLazySingleton(() => WatchBudgets(sl()));
   
   // BLoCs (ALWAYS register as Factory)
   sl.registerFactory(() => BudgetBloc(watchBudgets: sl()));
   ```
2. **Register Route (`lib/core/router/app_router.dart`)**:
   Add the new screen route cleanly to GoRouter (`AppRoutes.budgeting`).
3. **Update Documentation**:
   If the feature introduced a major architectural pattern or shared component, update `walkthrough.md` and append any architectural decisions to `docs/DECISION_LOG.md`.
