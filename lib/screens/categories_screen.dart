import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../providers/locale_provider.dart';
import '../l10n/admin_strings.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  List<TrainingCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ref.read(adminRepositoryProvider).getCategories();
    if (!mounted) return;
    setState(() {
      _categories = data;
      _loading = false;
    });
  }

  Future<void> _delete(TrainingCategory c) async {
    final locale = ref.read(adminLocaleProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t(locale, 'delete_category_title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t(locale, 'cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t(locale, 'confirm'))),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(adminRepositoryProvider).deleteCategory(c.id);
    _load();
  }

  Future<void> _openForm({TrainingCategory? existing}) async {
    final saved = await showDialog<bool>(context: context, builder: (ctx) => _CategoryFormDialog(existing: existing));
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
            child: ElevatedButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: Text(t(locale, 'add_category'))),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _categories.isEmpty
                  ? EmptyState(icon: Icons.category_outlined, message: t(locale, 'no_categories_yet'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _categories.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final c = _categories[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(c.name)),
                              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _openForm(existing: c)),
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

class _CategoryFormDialog extends ConsumerStatefulWidget {
  final TrainingCategory? existing;
  const _CategoryFormDialog({this.existing});

  @override
  ConsumerState<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _iconSeed = TextEditingController(text: widget.existing?.iconSeed ?? '');
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(adminRepositoryProvider);
    final category = TrainingCategory(id: widget.existing?.id ?? '', name: _name.text.trim(), iconSeed: _iconSeed.text.trim());
    try {
      if (widget.existing == null) {
        await repo.createCategory(category);
      } else {
        await repo.updateCategory(category);
      }
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
      title: Text(widget.existing == null ? t(locale, 'add_category') : t(locale, 'edit_category')),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: t(locale, 'field_name'), controller: _name, validator: (v) => (v == null || v.trim().isEmpty) ? t(locale, 'required_field') : null),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(label: t(locale, 'field_icon_seed'), controller: _iconSeed),
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
