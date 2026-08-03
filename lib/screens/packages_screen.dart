import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/training_package.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  List<TrainingPackage> _packages = [];
  List<TrainingCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    final packages = await repo.getPackages();
    final categories = await repo.getCategories();
    if (!mounted) return;
    setState(() {
      _packages = packages;
      _categories = categories;
      _loading = false;
    });
  }

  Future<void> _delete(TrainingPackage p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this package?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(adminRepositoryProvider).deletePackage(p.id);
    _load();
  }

  Future<void> _openForm({TrainingPackage? existing}) async {
    final saved = await showDialog<bool>(context: context, builder: (ctx) => _PackageFormDialog(existing: existing, categories: _categories));
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Add Package')),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _packages.isEmpty
                  ? const EmptyState(icon: Icons.card_giftcard_outlined, message: 'No packages yet')
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _packages.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final p = _packages[i];
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
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
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('${p.price.toStringAsFixed(0)} SAR · ${p.sessionsCount} sessions', style: const TextStyle(color: AppColors.onSurfaceMuted)),
                                  ],
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _openForm(existing: p)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => _delete(p)),
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

class _PackageFormDialog extends ConsumerStatefulWidget {
  final TrainingPackage? existing;
  final List<TrainingCategory> categories;
  const _PackageFormDialog({this.existing, required this.categories});

  @override
  ConsumerState<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends ConsumerState<_PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _price = TextEditingController(text: widget.existing?.price.toString() ?? '');
  late final _originalPrice = TextEditingController(text: widget.existing?.originalPrice?.toString() ?? '');
  late final _sessionsCount = TextEditingController(text: widget.existing?.sessionsCount.toString() ?? '');
  late final _includedItemInput = TextEditingController();
  late List<String> _includedItems = List.of(widget.existing?.includedItems ?? const []);
  String? _categoryId;
  late bool _isCustomizable = widget.existing?.isCustomizable ?? false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.categoryId;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(adminRepositoryProvider);
    final pkg = TrainingPackage(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text) ?? 0,
      originalPrice: _originalPrice.text.trim().isEmpty ? null : double.tryParse(_originalPrice.text),
      sessionsCount: int.tryParse(_sessionsCount.text) ?? 0,
      categoryId: _categoryId ?? '',
      imageSeed: widget.existing?.imageSeed ?? _name.text.trim(),
      includedItems: _includedItems,
      isCustomizable: _isCustomizable,
    );
    try {
      if (widget.existing == null) {
        await repo.createPackage(pkg);
      } else {
        await repo.updatePackage(pkg);
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
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Package' : 'Edit Package'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(label: 'Name', controller: _name, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Description', controller: _description),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Price', controller: _price, keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'Required' : null),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Original Price (optional)', controller: _originalPrice, keyboardType: TextInputType.number),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Sessions Count', controller: _sessionsCount, keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? 'Required' : null),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Customizable'),
                  value: _isCustomizable,
                  onChanged: (v) => setState(() => _isCustomizable = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: 'Included item', controller: _includedItemInput)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () {
                        final text = _includedItemInput.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          _includedItems = [..._includedItems, text];
                          _includedItemInput.clear();
                        });
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _includedItems.map((item) => Chip(label: Text(item), onDeleted: () => setState(() => _includedItems = _includedItems.where((i) => i != item).toList()))).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        AppButton(label: 'Save', onPressed: _save, isLoading: _saving),
      ],
    );
  }
}
