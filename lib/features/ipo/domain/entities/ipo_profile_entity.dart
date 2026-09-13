import 'package:equatable/equatable.dart';

enum ProfileType {
  self,
  proxyParent,
}

extension ProfileTypeExtension on ProfileType {
  String get nameString {
    switch (this) {
      case ProfileType.self:
        return 'SELF';
      case ProfileType.proxyParent:
        return 'PROXY_PARENT';
    }
  }

  static ProfileType fromString(String val) {
    if (val.toUpperCase() == 'SELF') return ProfileType.self;
    return ProfileType.proxyParent;
  }
}

class IpoProfileEntity extends Equatable {
  final String id;
  final String name; // e.g. "Self", "Father", "Mother"
  final ProfileType type;
  final String? panNumber;
  final String? dmatAccount;
  final DateTime createdAt;

  const IpoProfileEntity({
    required this.id,
    required this.name,
    required this.type,
    this.panNumber,
    this.dmatAccount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, type, panNumber, dmatAccount, createdAt];
}
