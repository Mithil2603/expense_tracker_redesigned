# Fingo State Management & Data Flow Architecture

This document dictates the architectural rules and responsibilities for managing state, streams, and data transitions across Fingo using the **BLoC (Business Logic Component)** pattern (`flutter_bloc`).

---

## 1. When to Create a BLoC vs. When NOT to Create a BLoC

### Create a BLoC / Cubit when:
1. **Managing Feature-Level Business State**: When a screen or flow requires asynchronous data fetching, user form submissions, pagination, or multi-step workflows (`TransactionBloc`, `AuthBloc`, `ReportBloc`, `SubscriptionBloc`).
2. **Subscribing to Real-Time Data Streams**: When listening to Firestore database streams (`watchTransactions`) or global notification/auth streams requiring reactive UI rebuilds.
3. **Coordinating Multiple Use Cases**: When an interaction triggers multiple domain actions (e.g., validating a budget threshold, recalculating health scores, and logging analytics).

### Do NOT Create a BLoC when:
1. **Managing Ephemeral UI-Only State**:
   - Single-screen animation controllers (`AnimationController`, `TabController`).
   - Temporary form input controllers (`TextEditingController`, `FocusNode`).
   - Local widget expansion toggles or hover/focus states (`bool _isExpanded`).
   - **Solution**: Use standard `StatefulWidget` or local hooks for purely ephemeral UI state.
2. **Universal Static Configuration**:
   - Device theme switching (`ThemeProvider`) or one-time app bootstrap initialization.
   - **Solution**: Use lean `ChangeNotifier` or `ListenableBuilder` if no async domain orchestration or complex state transitions are required.

---

## 2. Granular Layer Responsibilities

```
+-----------------------------------------------------------------------------------+
| WIDGET / SCREEN RESPONSIBILITIES                                                  |
| - Dispatches Events (`context.read<Bloc>().add(Event())`)                          |
| - Renders UI strictly based on State (`BlocBuilder`, `BlocConsumer`)              |
| - Handles navigation, dialogs, & snackbars (`BlocListener`)                       |
| - NEVER calls Repositories or Use Cases directly                                  |
+-----------------------------------------------------------------------------------+
                                        |
                                        v
+-----------------------------------------------------------------------------------+
| BLOC / CUBIT RESPONSIBILITIES                                                     |
| - Receives UI Events (`on<Event>((event, emit) => ...)`)                          |
| - Invokes pure Domain Use Cases (`final result = await _useCase(params)`)         |
| - Maps `Either<Failure, T>` results into immutable UI States                      |
| - Manages StreamSubscriptions and emits states safely (`!isClosed`)               |
+-----------------------------------------------------------------------------------+
                                        |
                                        v
+-----------------------------------------------------------------------------------+
| USE CASE RESPONSIBILITIES                                                         |
| - Executes exact, single-purpose business rules (`GenerateInsights`)              |
| - Combines data from one or more Repositories                                     |
| - Remains 100% UI and Flutter-agnostic (returns raw numbers/entities)             |
+-----------------------------------------------------------------------------------+
                                        |
                                        v
+-----------------------------------------------------------------------------------+
| REPOSITORY RESPONSIBILITIES                                                       |
| - Coordinates Remote and Local Data Sources                                       |
| - Catches raw Exceptions (`ServerException`) & returns `Either<Failure, T>`       |
| - Manages local caching fallbacks during network outages                          |
+-----------------------------------------------------------------------------------+
```

---

## 3. Event & State Design Guidelines

### 3.1. Event Design
- **Past-Tense Naming**: Events must describe what *happened* from the user's or system's perspective (`TransactionAdded`, `DateRangeFilterChanged`, `WatchTransactionsStarted`), never what the BLoC should do (`DoNotUseAddTransactionCommand`).
- **Immutable & Equatable**: All events must extend `Equatable` (`List<Object?> get props => [...]`) and declare properties as `final`.
- **Payload Specificity**: Include only the exact data required to execute the action (`TransactionAdded(required this.transaction)`).

### 3.2. State Design
- **Explicit Status Subclasses vs. Single State Class**:
  - For complex screens with multi-dimensional filters (e.g., `ReportBloc`), prefer a rich state class (`ReportLoaded`) containing explicit properties (`List<FinancialInsight> insights`, `HealthScore healthScore`, `DateTime startDate`) accompanied by `ReportLoading` and `ReportError`.
  - For transactional operations (e.g., `AuthBloc`, `TransactionBloc`), prefer explicit state hierarchies:
    - `[Feature]Initial` — Baseline starting state.
    - `[Feature]Loading` — Async operation in progress.
    - `[Feature]Loaded` / `[Feature]Success` — Operation complete with payload.
    - `[Feature]Error` — Operation failed (`required final String message`).
- **Always Extend Equatable**: States **must** extend `Equatable` and include every state field inside `get props`. If `props` is incomplete, the BLoC will fail to detect state differences or emit redundant duplicate states.
- **`copyWith` Pattern**: For loaded states holding multi-variable filters, implement a clean `copyWith` method to update isolated properties without mutating the existing state object.

---

## 4. Real-Time Stream & Subscription Strategy

Because Fingo relies on real-time Firestore synchronization (`watchTransactions`), BLoCs handling streams must follow strict subscription safety rules:

```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final WatchTransactions watchTransactions;
  StreamSubscription<Either<Failure, List<TransactionEntity>>>? _subscription;

  TransactionBloc({required this.watchTransactions}) : super(TransactionInitial()) {
    on<WatchTransactionsStarted>(_onWatchStarted);
    on<TransactionsUpdated>(_onTransactionsUpdated);
  }

  Future<void> _onWatchStarted(
    WatchTransactionsStarted event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    await _subscription?.cancel();
    
    _subscription = watchTransactions(event.userId).listen((result) {
      add(TransactionsUpdated(result));
    });
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
  ) {
    event.result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### Stream Rules:
1. **Never Emit inside `.listen(...)` Directly**: When listening to an external `StreamSubscription` inside a BLoC, do not call `emit()` asynchronously inside the listener callback, as `emit()` is only valid while the event handler executes. Instead, dispatch an internal event (`add(TransactionsUpdated(result))`) and let that handler emit the state safely. Or use `emit.forEach(...)`.
2. **Explicit Subscription Cancellation**: Always cancel `_subscription?.cancel()` inside `close()` before calling `super.close()`.

---

## 5. Caching Rules & Offline State

1. **Repository-Level Caching**: All data caching strategies must be encapsulated inside `data/repositories/` coordinating between `RemoteDataSource` and `LocalDataSource`.
2. **No Static Caches inside Use Cases**: Domain Use Cases (`GenerateInsights`) must never maintain static in-memory caches (`static InsightsCache? _cache`). Static caching bypasses BLoC stream reactivity, causes memory leaks across user session changes, and couples domain logic to stateful lifecycles.
3. **Offline Graceful Degradation**: If a remote query fails due to network outage (`SocketException`), the repository must attempt to fetch the last-known state from `LocalDataSource`. Only if local data is also missing should it return `Left(NetworkFailure())`.

---

## 6. When to Emit States & Performance Guidelines

### When to Emit:
- **Immediate Feedback**: Emit `LoadingState` immediately upon starting async operations (`addTransaction`, `generateReport`) so the UI can show progress indicators or disable submit buttons.
- **Optimistic Updates**: For high-frequency user actions (e.g., liking a social post or checking off a daily quest), emit the updated state optimistically in the BLoC before awaiting confirmation from Firestore, reverting to the previous state if the network call returns `Left(Failure)`.

### Performance & Anti-Patterns:
- **Avoid Over-Emitting**: Check if the data has actually changed before emitting. `Equatable` automatically filters out identical consecutive states, but avoid building heavy state objects inside high-frequency loops.
- **Use `buildWhen` and `listenWhen`**: In presentation screens, always wrap `BlocBuilder` and `BlocListener` with explicit `buildWhen` filters to prevent rebuilding expensive chart widgets when only unrelated properties (like a selected tab index) change:
  ```dart
  BlocBuilder<ReportBloc, ReportState>(
    buildWhen: (previous, current) => previous.healthScore != current.healthScore,
    builder: (context, state) { ... },
  )
  ```
- **Context Safety**: Never access `context.read<Bloc>()` inside asynchronous operations after an `await` gap unless checking `if (!context.mounted) return;`.
