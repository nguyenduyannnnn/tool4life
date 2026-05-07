import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 2; // 2: 90 Days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Stats Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildStatsCard(
                    title: 'Tổng Token',
                    value: '702,326',
                    subtitle: 'Tổng token đã tiêu thụ',
                    trend: '+679.1%',
                    icon: Icons.flash_on,
                    iconColor: Colors.orange,
                  ),
                  _buildStatsCard(
                    title: 'Tổng chi phí',
                    value: '5,618.74 VND',
                    subtitle: 'Chi phí ước tính',
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                  ),
                  _buildStatsCard(
                    title: 'TB chi phí/hoạt động',
                    value: '148 VND',
                    subtitle: 'Chi phí trung bình mỗi hoạt động',
                    icon: Icons.trending_up,
                    iconColor: Colors.blue,
                  ),
                  _buildStatsCard(
                    title: 'Tổng hoạt động',
                    value: '38',
                    subtitle: 'Tổng số hoạt động đã thực hiện',
                    icon: Icons.groups,
                    iconColor: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Analytics Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with time selector
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Phân tích sử dụng Token',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                _buildPeriodTab('90 Days', 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bar Chart Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sử dụng theo loại hoạt động',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Chart Legend
                          Row(
                            children: [
                              _buildLegendItem('Token đầu vào', Colors.blue),
                              const SizedBox(width: 16),
                              _buildLegendItem('Token đầu ra', Colors.red),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                  'Token ngợi cảnh', Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Mock Bar Chart
                          Container(
                            height: 200,
                            child: _buildBarChart(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pie Chart Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phân bổ Token',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mock Pie Chart
                          Center(
                            child: Container(
                              height: 250,
                              child: _buildPieChart(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    String? trend,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String text, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    // Mock bar chart data based on the image
    final data = [
      {'date': 'Aug 15', 'input': 50000, 'output': 0, 'context': 0},
      {'date': 'Aug 19', 'input': 60000, 'output': 0, 'context': 0},
      {'date': 'Aug 27', 'input': 60000, 'output': 0, 'context': 0},
      {'date': 'Aug 28', 'input': 340000, 'output': 20000, 'context': 10000},
      {'date': 'Aug 29', 'input': 180000, 'output': 0, 'context': 0},
      {'date': 'Sep 3', 'input': 0, 'output': 0, 'context': 0},
      {'date': 'Sep 4', 'input': 0, 'output': 0, 'context': 0},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final maxValue = 350000;
        final inputHeight =
            ((item['input']! as int) / maxValue * 150).toDouble();
        final outputHeight =
            ((item['output']! as int) / maxValue * 150).toDouble();
        final contextHeight =
            ((item['context']! as int) / maxValue * 150).toDouble();

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (contextHeight > 0)
                        Container(
                          width: 20,
                          height: contextHeight,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      if (outputHeight > 0)
                        Container(
                          width: 20,
                          height: outputHeight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      if (inputHeight > 0)
                        Container(
                          width: 20,
                          height: inputHeight,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['date']!.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Outer ring - Token đầu vào (dominant blue)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
          // Middle ring - Token đầu ra (small red)
          Positioned(
            top: 10,
            right: 20,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
          ),
          // Inner circle - Token ngợi cảnh (small orange)
          Positioned(
            bottom: 15,
            right: 30,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
            ),
          ),
          // Center white circle
          Positioned(
            top: 50,
            left: 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
