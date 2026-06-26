import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/billing/subscription_repository.dart';
import '../../../../core/services/entitlement/entitlement_service.dart';
import '../../../../core/services/entitlement/models/subscription_plan.dart';
import '../../../../core/services/entitlement/models/subscription_entity.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;
  final EntitlementService entitlementService;
  final String userId;

  SubscriptionBloc({
    required this.repository,
    required this.entitlementService,
    required this.userId,
  }) : super(SubscriptionInitial()) {
    on<LoadPackagesEvent>(_onLoadPackages);
    on<PurchasePackageEvent>(_onPurchasePackage);
  }

  Future<void> _onLoadPackages(LoadPackagesEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    final result = await repository.getAvailablePackages();
    final status = await repository.getSubscriptionStatus();
    
    // Sync status with our EntitlementService if it changed
    if (status == SubscriptionStatus.active) {
      await entitlementService.updateSubscription(
        userId, 
        SubscriptionEntity(plan: SubscriptionPlan.premium, status: SubscriptionStatus.active, expiryDate: DateTime.now().add(const Duration(days: 30))),
      );
    }
    
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (packages) => emit(SubscriptionLoaded(packages: packages, isPremium: status == SubscriptionStatus.active)),
    );
  }

  Future<void> _onPurchasePackage(PurchasePackageEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    final result = await repository.purchasePackage(event.package);
    
    await result.fold(
      (failure) async {
        emit(SubscriptionError(failure.message));
        // Reload packages after error so UI doesn't get stuck loading
        add(LoadPackagesEvent());
      },
      (customerInfo) async {
        if (customerInfo.entitlements.all['premium']?.isActive == true) {
          await entitlementService.updateSubscription(
            userId, 
            SubscriptionEntity(plan: SubscriptionPlan.premium, status: SubscriptionStatus.active, expiryDate: DateTime.now().add(const Duration(days: 30))),
          );
          emit(SubscriptionPurchaseSuccess());
        } else {
          emit(const SubscriptionError('Purchase completed but entitlement not active.'));
          add(LoadPackagesEvent());
        }
      },
    );
  }
}
