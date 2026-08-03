import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, this.icon = Icons.inbox_outlined, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.onSurfaceMuted),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: const TextStyle(color: AppColors.onSurfaceMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
