import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/common/utils/currency_formatter.dart';
import '../../domain/entities/finance_category_entity.dart';

class CategoryChart extends StatelessWidget {
  final String title;
  final Map<String, double> dataByCategoryId;
  final List<FinanceCategoryEntity> categories;

  const CategoryChart({
    super.key,
    required this.title,
    required this.dataByCategoryId,
    required this.categories,
  });

  static const _palette = <Color>[
    Color(0xFF1890FF),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFF6D4C41),
    Color(0xFFC0CA33),
  ];

  @override
  Widget build(BuildContext context) {
    if (dataByCategoryId.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Icon(Icons.pie_chart_outline, size: 48, color: AppColors.hint),
            const SizedBox(height: 8),
            Text('Chưa có dữ liệu',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
          ],
        ),
      );
    }

    final entries = dataByCategoryId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    final sections = <PieChartSectionData>[];
    final legend = <Widget>[];

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final color = _palette[i % _palette.length];
      final percent = total == 0 ? 0.0 : (e.value / total * 100);
      final cat = _findCategory(e.key);
      final name = cat?.name ?? 'Khác';

      sections.add(PieChartSectionData(
        color: color,
        value: e.value,
        radius: 50,
        title: '${percent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ));

      legend.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              CurrencyFormatter.format(e.value),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...legend,
        ],
      ),
    );
  }

  FinanceCategoryEntity? _findCategory(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
