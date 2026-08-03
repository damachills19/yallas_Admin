import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'trainer_applications_screen.dart';
import 'orders_screen.dart';
import 'packages_screen.dart';
import 'programs_screen.dart';
import 'categories_screen.dart';
import 'coupons_screen.dart';
import 'complaints_screen.dart';

const _wideBreakpoint = 800.0;

class _Section {
  final IconData icon;
  final String label;
  final Widget screen;
  const _Section({required this.icon, required this.label, required this.screen});
}

final _sections = [
  const _Section(icon: Icons.dashboard_outlined, label: 'Dashboard', screen: DashboardScreen()),
  const _Section(icon: Icons.assignment_ind_outlined, label: 'Trainer Applications', screen: TrainerApplicationsScreen()),
  const _Section(icon: Icons.receipt_long_outlined, label: 'Orders & Allocation', screen: OrdersScreen()),
  const _Section(icon: Icons.card_giftcard_outlined, label: 'Packages', screen: PackagesScreen()),
  const _Section(icon: Icons.fitness_center_outlined, label: 'Programs', screen: ProgramsScreen()),
  const _Section(icon: Icons.category_outlined, label: 'Categories', screen: CategoriesScreen()),
  const _Section(icon: Icons.local_offer_outlined, label: 'Coupons', screen: CouponsScreen()),
  const _Section(icon: Icons.support_agent_outlined, label: 'Complaints', screen: ComplaintsScreen()),
];

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _index = 0;

  void _logout() => ref.read(adminAuthProvider.notifier).logout();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= _wideBreakpoint;
    final title = _sections[_index].label;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              color: AppColors.surface,
              child: SafeArea(child: _NavContent(index: _index, onSelect: (i) => setState(() => _index = i), onLogout: _logout)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: _sections[_index].screen),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: SafeArea(
          child: _NavContent(
            index: _index,
            onSelect: (i) {
              setState(() => _index = i);
              Navigator.of(context).pop();
            },
            onLogout: _logout,
          ),
        ),
      ),
      body: _sections[_index].screen,
    );
  }
}

class _NavContent extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  const _NavContent({required this.index, required this.onSelect, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
              SizedBox(width: AppSpacing.sm),
              Text('Yalla Fit Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: _sections.length,
            itemBuilder: (context, i) {
              final selected = i == index;
              return ListTile(
                leading: Icon(_sections[i].icon, color: selected ? AppColors.primary : AppColors.onSurfaceMuted),
                title: Text(
                  _sections[i].label,
                  style: TextStyle(color: selected ? AppColors.primary : AppColors.onSurface, fontWeight: selected ? FontWeight.w700 : FontWeight.normal),
                ),
                selected: selected,
                selectedTileColor: AppColors.primaryLight.withValues(alpha: 0.4),
                onTap: () => onSelect(i),
              );
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Logout', style: TextStyle(color: AppColors.error)),
          onTap: onLogout,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
