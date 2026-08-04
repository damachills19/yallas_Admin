import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../providers/locale_provider.dart';
import '../l10n/admin_strings.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  List<Coupon> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ref.read(adminRepositoryProvider).getCoupons();
    if (!mounted) return;
    setState(() {
      _coupons = data;
      _loading = false;
    });
  }

  Future<void> _toggleActive(Coupon c) async {
    await ref.read(adminRepositoryProvider).updateCoupon(c.copyWith(isActive: !c.isActive));
    _load();
  }

  Future<void> _delete(Coupon c) async {
    final locale = ref.read(adminLocaleProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t(locale, 'delete_coupon_title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t(locale, 'cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t(locale, 'confirm'))),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(adminRepositoryProvider).deleteCoupon(c.code);
    _load();
  }

  Future<void> _openForm() async {
    final saved = await showDialog<bool>(context: context, builder: (ctx) => const _CouponFormDialog());
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(adminLocaleProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(onPressed: _openForm, icon: const Icon(Icons.add), label: Text(t(locale, 'add_coupon'))),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _coupons.isEmpty
                  ? EmptyState(icon: Icons.local_offer_outlined, message: t(locale, 'no_coupons_yet'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _coupons.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final c = _coupons[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${(c.discountPercent * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.onSurfaceMuted)),
                                  ],
                                ),
                              ),
                              Switch(value: c.isActive, activeThumbColor: AppColors.primary, onChanged: (_) => _toggleActive(c)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => _delete(c)),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _CouponFormDialog extends ConsumerStatefulWidget {
  const _CouponFormDialog();

  @override
  ConsumerState<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends ConsumerState<_CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _discountPercent = TextEditingController();
  bool _isActive = true;
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final percentValue = (double.tryParse(_discountPercent.text) ?? 0) / 100;
    try {
      await ref.read(adminRepositoryProvider).createCoupon(
            Coupon(code: _code.text.trim().toUpperCase(), discountPercent: percentValue, isActive: _isActive),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(adminLocaleProvider);
    return AlertDialog(
      title: Text(t(locale, 'add_coupon')),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: t(locale, 'field_code'), controller: _code, validator: (v) => (v == null || v.trim().isEmpty) ? t(locale, 'required_field') : null),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(label: t(locale, 'field_discount_percent'), controller: _discountPercent, keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? t(locale, 'required_field') : null),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t(locale, 'field_active')),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t(locale, 'cancel'))),
        AppButton(label: t(locale, 'save'), onPressed: _save, isLoading: _saving),
      ],
    );
  }
}
