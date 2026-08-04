import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class LocaleToggle extends ConsumerWidget {
  const LocaleToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(adminLocaleProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: () {
        ref.read(adminLocaleProvider.notifier).state = locale == AppLocale.en ? AppLocale.ar : AppLocale.en;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: AppColors.onSurfaceMuted),
            const SizedBox(width: 6),
            Text(
              'EN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: locale == AppLocale.en ? AppColors.primary : AppColors.onSurfaceMuted,
              ),
            ),
            const Text(' / ', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
            Text(
              'AR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: locale == AppLocale.ar ? AppColors.primary : AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
