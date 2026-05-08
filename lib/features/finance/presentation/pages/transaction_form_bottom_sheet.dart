import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/finance_category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/transaction_type_selector.dart';

class TransactionFormBottomSheet extends StatefulWidget {
  final TransactionEntity? initial;
  final DateTime defaultDate;
  final List<FinanceCategoryEntity> categories;

  const TransactionFormBottomSheet({
    super.key,
    this.initial,
    required this.defaultDate,
    required this.categories,
  });

  static Future<TransactionEntity?> show(
    BuildContext context, {
    TransactionEntity? initial,
    required DateTime defaultDate,
    required List<FinanceCategoryEntity> categories,
  }) {
    return showModalBottomSheet<TransactionEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionFormBottomSheet(
        initial: initial,
        defaultDate: defaultDate,
        categories: categories,
      ),
    );
  }

  @override
  State<TransactionFormBottomSheet> createState() =>
      _TransactionFormBottomSheetState();
}

class _TransactionFormBottomSheetState
    extends State<TransactionFormBottomSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late TransactionType _type;
  late DateTime _date;
  String? _categoryId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleCtrl = TextEditingController(text: initial?.title ?? '');
    _amountCtrl = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(0),
    );
    _noteCtrl = TextEditingController(text: initial?.note ?? '');
    _type = initial?.type ?? TransactionType.expense;
    _date = initial?.date ?? widget.defaultDate;
    _categoryId = initial?.categoryId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<FinanceCategoryEntity> get _filteredCategories =>
      widget.categories.where((c) => c.type == _type).toList();

  void _onChangeType(TransactionType type) {
    setState(() {
      _type = type;
      // Reset category if it doesn't belong to new type
      if (_categoryId != null) {
        final stillValid =
            _filteredCategories.any((c) => c.id == _categoryId);
        if (!stillValid) _categoryId = null;
      }
    });
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _date = DateTime(result.year, result.month, result.day));
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền phải lớn hơn 0')),
      );
      return;
    }

    final now = DateTime.now();
    final initial = widget.initial;
    final entity = TransactionEntity(
      id: initial?.id ?? _generateId(),
      type: _type,
      title: _titleCtrl.text.trim(),
      amount: amount,
      categoryId: _categoryId!,
      date: DateTime(_date.year, _date.month, _date.day),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: initial?.createdAt ?? now,
      updatedAt: initial == null ? null : now,
    );
    Navigator.of(context).pop(entity);
  }

  String _generateId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = Random().nextInt(0x7FFFFFFF);
    return '${ts}_$rand';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final mq = MediaQuery.of(context);
    final cats = _filteredCategories;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TransactionTypeSelector(
                  selected: _type,
                  onChanged: _onChangeType,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tiêu đề không được để trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (đ) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Số tiền không được để trống';
                    }
                    final n = double.tryParse(v.trim()) ?? 0;
                    if (n <= 0) return 'Số tiền phải lớn hơn 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _categoryId != null &&
                          cats.any((c) => c.id == _categoryId)
                      ? _categoryId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục *',
                    border: OutlineInputBorder(),
                  ),
                  items: cats
                      .map((c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) {
                    if (v == null) return 'Vui lòng chọn danh mục';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd/MM/yyyy').format(_date)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Cập nhật' : 'Lưu',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
