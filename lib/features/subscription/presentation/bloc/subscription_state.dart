import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<Package> packages;
  final bool isPremium;

  const SubscriptionLoaded({required this.packages, this.isPremium = false});

  @override
  List<Object> get props => [packages, isPremium];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

class SubscriptionPurchaseSuccess extends SubscriptionState {}
