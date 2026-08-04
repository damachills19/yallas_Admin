import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/admin_strings.dart';
import 'dashboard_screen.dart';
import 'trainer_applications_screen.dart';
import 'orders_screen.dart';
import 'packages_screen.dart';
import 'programs_screen.dart';
import 'categories_screen.dart';
import 'coupons_screen.dart';
import 'complaints_screen.dart';
import '../widgets/notification_bell.dart';
import '../widgets/locale_toggle.dart';

const _wideBreakpoint = 800.0;

class _Section {
  final IconData icon;
  final String labelKey;
  final Widget screen;
  const _Section({required this.icon, required this.labelKey, required this.screen});
}

final _sections = [
  const _Section(icon: Icons.dashboard_outlined, labelKey: 'nav_dashboard', screen: DashboardScreen()),
  const _Section(icon: Icons.assignment_ind_outlined, labelKey: 'nav_trainer_applications', screen: TrainerApplicationsScreen()),
  const _Section(icon: Icons.receipt_long_outlined, labelKey: 'nav_orders', screen: OrdersScreen()),
  const _Section(icon: Icons.card_giftcard_outlined, labelKey: 'nav_packages', screen: PackagesScreen()),
  const _Section(icon: Icons.fitness_center_outlined, labelKey: 'nav_programs', screen: ProgramsScreen()),
  const _Section(icon: Icons.category_outlined, labelKey: 'nav_categories', screen: CategoriesScreen()),
  const _Section(icon: Icons.local_offer_outlined, labelKey: 'nav_coupons', screen: CouponsScreen()),
  const _Section(icon: Icons.support_agent_outlined, labelKey: 'nav_complaints', screen: ComplaintsScreen()),
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
    final locale = ref.watch(adminLocaleProvider);
    final title = t(locale, _sections[_index].labelKey);

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
                    child: Row(
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        const LocaleToggle(),
                        const SizedBox(width: AppSpacing.sm),
                        NotificationBell(onNavigate: (i) => setState(() => _index = i)),
                      ],
                    ),
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
      appBar: AppBar(
        title: Text(title),
        actions: [
          const Padding(padding: EdgeInsets.only(right: AppSpacing.sm), child: LocaleToggle()),
          NotificationBell(onNavigate: (i) => setState(() => _index = i)),
        ],
      ),
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

class _NavContent extends ConsumerWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  const _NavContent({required this.index, required this.onSelect, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(adminLocaleProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(t(locale, 'app_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  t(locale, _sections[i].labelKey),
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
          title: Text(t(locale, 'logout'), style: const TextStyle(color: AppColors.error)),
          onTap: onLogout,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
