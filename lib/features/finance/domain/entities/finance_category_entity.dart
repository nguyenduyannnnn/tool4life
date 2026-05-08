import 'package:equatable/equatable.dart';

import 'transaction_entity.dart';

class FinanceCategoryEntity extends Equatable {
  final String id;
  final String name;
  final TransactionType type;
  final String icon;
  final bool isDefault;

  const FinanceCategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [id, name, type, icon, isDefault];
}
