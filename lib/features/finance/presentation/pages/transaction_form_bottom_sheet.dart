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
  final Map<TransactionType, List<String>> titlesByType;

  const TransactionFormBottomSheet({
    super.key,
    this.initial,
    required this.defaultDate,
    required this.categories,
    this.titlesByType = const {},
  });

  static Future<TransactionEntity?> show(
    BuildContext context, {
    TransactionEntity? initial,
    required DateTime defaultDate,
    required List<FinanceCategoryEntity> categories,
    Map<TransactionType, List<String>> titlesByType = const {},
  }) {
    return showModalBottomSheet<TransactionEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionFormBottomSheet(
        initial: initial,
        defaultDate: defaultDate,
        categories: categories,
        titlesByType: titlesByType,
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
  final FocusNode _titleFocus = FocusNode();
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
      text: initial == null
          ? ''
          : _ThousandsTextInputFormatter.formatDigits(
              initial.amount.round().toString(),
            ),
    );
    _noteCtrl = TextEditingController(text: initial?.note ?? '');
    _type = initial?.type ?? TransactionType.expense;
    final today = DateTime.now();
    _date = initial?.date ?? DateTime(today.year, today.month, today.day);
    _categoryId = initial?.categoryId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _titleFocus.dispose();
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
    final rawAmount = _amountCtrl.text.replaceAll('.', '').trim();
    final amount = double.tryParse(rawAmount) ?? 0;
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

  List<String> get _suggestionsForType {
    final list = widget.titlesByType[_type] ?? const <String>[];
    final seen = <String>{};
    final out = <String>[];
    for (final t in list) {
      final v = t.trim();
      if (v.isEmpty) continue;
      final key = v.toLowerCase();
      if (seen.add(key)) out.add(v);
    }
    return out;
  }

  String? _validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Tiêu đề không được để trống';
    }
    return null;
  }

  Widget _buildTitleField() {
    final suggestions = _suggestionsForType;
    final hint = suggestions.isEmpty
        ? 'Ví dụ: Ăn trưa, Xăng xe...'
        : 'Gợi ý: ${suggestions.take(3).join(', ')}';

    return RawAutocomplete<String>(
      textEditingController: _titleCtrl,
      focusNode: _titleFocus,
      optionsBuilder: (TextEditingValue value) {
        if (suggestions.isEmpty) return const Iterable<String>.empty();
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return suggestions.take(8);
        return suggestions
            .where((s) => s.toLowerCase().contains(query))
            .take(8);
      },
      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Tiêu đề *',
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          validator: _validateTitle,
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(option),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
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
                _buildTitleField(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền *',
                    suffixText: 'VNĐ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsTextInputFormatter(),
                  ],
                  validator: (v) {
                    final raw = (v ?? '').replaceAll('.', '').trim();
                    if (raw.isEmpty) {
                      return 'Số tiền không được để trống';
                    }
                    final n = double.tryParse(raw) ?? 0;
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

class _ThousandsTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final formatted = formatDigits(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatDigits(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return '';
    final buf = StringBuffer();
    for (var i = 0; i < cleaned.length; i++) {
      if (i > 0 && (cleaned.length - i) % 3 == 0) buf.write('.');
      buf.write(cleaned[i]);
    }
    return buf.toString();
  }
}
