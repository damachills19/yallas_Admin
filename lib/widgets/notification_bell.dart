import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import '../repositories/admin_repository.dart';
import '../theme/app_theme.dart';

/// Persistent-chrome bell icon showing a badge with the total count of
/// items awaiting admin review (pending trainer applications + pending
/// bank-transfer orders). Tapping refreshes the count and shows a small
/// breakdown dialog with shortcuts to the relevant sections.
class NotificationBell extends ConsumerStatefulWidget {
  /// Called with the nav section index to jump to (1 = Trainer
  /// Applications, 2 = Orders & Allocation) when the admin picks a
  /// category from the breakdown dialog.
  final ValueChanged<int> onNavigate;

  const NotificationBell({super.key, required this.onNavigate});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  late Future<PendingActionCounts> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(adminRepositoryProvider).getPendingActionCounts();
  }

  Future<void> _onPressed() async {
    final freshCounts = await ref.read(adminRepositoryProvider).getPendingActionCounts();
    if (!mounted) return;
    setState(() => _future = Future.value(freshCounts));
    _showBreakdown(freshCounts);
  }

  void _showBreakdown(PendingActionCounts counts) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pending Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (counts.trainerApplications > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.assignment_ind_outlined, color: AppColors.primary),
                title: Text('${counts.trainerApplications} trainer application(s) pending'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  widget.onNavigate(1);
                },
              ),
            if (counts.bankTransfers > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                title: Text('${counts.bankTransfers} bank transfer(s) pending review'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  widget.onNavigate(2);
                },
              ),
            if (counts.total == 0) const Text('Nothing pending. All caught up!'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PendingActionCounts>(
      future: _future,
      builder: (context, snapshot) {
        final total = snapshot.data?.total ?? 0;
        return IconButton(
          tooltip: 'Pending actions',
          onPressed: _onPressed,
          icon: Badge(
            label: Text('$total'),
            isLabelVisible: total > 0,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
          ),
        );
      },
    );
  }
}
