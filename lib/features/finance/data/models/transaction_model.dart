import '../../domain/entities/transaction_entity.dart';

class TransactionModel {
  final String id;
  final TransactionType type;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      amount: entity.amount,
      categoryId: entity.categoryId,
      date: entity.date,
      note: entity.note,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      type: type,
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
