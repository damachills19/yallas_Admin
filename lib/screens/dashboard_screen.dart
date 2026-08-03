import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trainer_application.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';

class _DashboardData {
  final int pendingApplications;
  final int openComplaints;
  final int totalPackages;
  final int totalPrograms;
  final List<Map<String, int>> userGrowth;
  final Map<String, int> applicationStatusCounts;

  _DashboardData({
    required this.pendingApplications,
    required this.openComplaints,
    required this.totalPackages,
    required this.totalPrograms,
    required this.userGrowth,
    required this.applicationStatusCounts,
  });
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(adminRepositoryProvider);

    Future<_DashboardData> load() async {
      final applications = await repo.getApplications(filterStatus: VerificationStatus.pending);
      final complaints = await repo.getComplaints(filterStatus: 'open');
      final packages = await repo.getPackages();
      final programs = await repo.getPrograms();
      final userGrowth = await repo.getUserGrowthByMonth();
      final applicationStatusCounts = await repo.getApplicationStatusCounts();
      return _DashboardData(
        pendingApplications: applications.length,
        openComplaints: complaints.length,
        totalPackages: packages.length,
        totalPrograms: programs.length,
        userGrowth: userGrowth,
        applicationStatusCounts: applicationStatusCounts,
      );
    }

    return FutureBuilder<_DashboardData>(
      future: load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final d = snapshot.data!;
        final wide = MediaQuery.of(context).size.width >= 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(icon: Icons.assignment_ind_outlined, value: '${d.pendingApplications}', label: 'Pending Applications'),
                  _StatCard(icon: Icons.support_agent_outlined, value: '${d.openComplaints}', label: 'Open Complaints'),
                  _StatCard(icon: Icons.card_giftcard_outlined, value: '${d.totalPackages}', label: 'Total Packages'),
                  _StatCard(icon: Icons.fitness_center_outlined, value: '${d.totalPrograms}', label: 'Total Programs'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'User Growth (last 6 months)',
                height: 320,
                child: _UserGrowthChart(monthly: d.userGrowth),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Trainer Applications by Status',
                child: _ApplicationStatusPieChart(counts: d.applicationStatusCounts),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;
  const _ChartCard({required this.title, required this.child, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _UserGrowthChart extends StatelessWidget {
  /// One entry per month: {'month': 1-12, 'client': cumulative count, 'trainer': cumulative count}.
  final List<Map<String, int>> monthly;
  const _UserGrowthChart({required this.monthly});

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    if (monthly.isEmpty) {
      return const Center(child: Text('No signups yet', style: TextStyle(color: AppColors.onSurfaceMuted)));
    }
    final clientSpots = <FlSpot>[];
    final trainerSpots = <FlSpot>[];
    for (var i = 0; i < monthly.length; i++) {
      clientSpots.add(FlSpot(i.toDouble(), (monthly[i]['client'] ?? 0).toDouble()));
      trainerSpots.add(FlSpot(i.toDouble(), (monthly[i]['trainer'] ?? 0).toDouble()));
    }
    final maxY = [...clientSpots, ...trainerSpots, const FlSpot(0, 1)]
        .map((s) => s.y)
        .reduce((a, b) => a > b ? a : b) * 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            _LegendDot(color: Colors.blue, label: 'Users'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.primary, label: 'Trainers'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (monthly.length - 1).toDouble(),
              minY: 0,
              maxY: maxY == 0 ? 1 : maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 11)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= monthly.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_monthNames[monthly[i]['month'] ?? 0], style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(s.y.round().toString(), const TextStyle(color: Colors.white)))
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: clientSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: trainerSpots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplicationStatusPieChart extends StatelessWidget {
  final Map<String, int> counts;
  const _ApplicationStatusPieChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final pending = counts['pending'] ?? 0;
    final approved = counts['approved'] ?? 0;
    final rejected = counts['rejected'] ?? 0;
    final total = pending + approved + rejected;

    if (total == 0) {
      return const Center(child: Text('No trainer applications yet', style: TextStyle(color: AppColors.onSurfaceMuted)));
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: [
                if (pending > 0) PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: '$pending', radius: 50),
                if (approved > 0) PieChartSectionData(value: approved.toDouble(), color: Colors.green, title: '$approved', radius: 50),
                if (rejected > 0) PieChartSectionData(value: rejected.toDouble(), color: Colors.redAccent, title: '$rejected', radius: 50),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _LegendDot(color: Colors.orange, label: 'Pending'),
            SizedBox(height: 6),
            _LegendDot(color: Colors.green, label: 'Approved'),
            SizedBox(height: 6),
            _LegendDot(color: Colors.redAccent, label: 'Rejected'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
