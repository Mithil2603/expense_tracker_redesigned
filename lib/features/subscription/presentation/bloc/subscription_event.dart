import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadPackagesEvent extends SubscriptionEvent {}

class PurchasePackageEvent extends SubscriptionEvent {
  final Package package;

  const PurchasePackageEvent(this.package);

  @override
  List<Object> get props => [package];
}
