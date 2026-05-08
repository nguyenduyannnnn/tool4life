import '../../domain/entities/finance_category_entity.dart';
import '../../domain/entities/transaction_entity.dart';

class FinanceCategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final String icon;
  final bool isDefault;

  const FinanceCategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.isDefault,
  });

  factory FinanceCategoryModel.fromEntity(FinanceCategoryEntity entity) {
    return FinanceCategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
      isDefault: entity.isDefault,
    );
  }

  FinanceCategoryEntity toEntity() {
    return FinanceCategoryEntity(
      id: id,
      name: name,
      type: type,
      icon: icon,
      isDefault: isDefault,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory FinanceCategoryModel.fromMap(Map<String, Object?> map) {
    return FinanceCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      icon: map['icon'] as String,
      isDefault: (map['is_default'] as int) == 1,
    );
  }
}
