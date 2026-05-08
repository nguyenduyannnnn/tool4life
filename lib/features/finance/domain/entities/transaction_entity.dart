import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Thu nhập';
      case TransactionType.expense:
        return 'Chi phí';
    }
  }
}

enum TransactionFilter {
  all,
  income,
  expense;

  String get label {
    switch (this) {
      case TransactionFilter.all:
        return 'Tất cả';
      case TransactionFilter.income:
        return 'Thu nhập';
      case TransactionFilter.expense:
        return 'Chi phí';
    }
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionEntity({
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

  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        amount,
        categoryId,
        date,
        note,
        createdAt,
        updatedAt,
      ];
}
