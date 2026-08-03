import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_program.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  List<TrainingProgram> _programs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ref.read(adminRepositoryProvider).getPrograms();
    if (!mounted) return;
    setState(() {
      _programs = data;
      _loading = false;
    });
  }

  Future<void> _delete(TrainingProgram p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this program?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(adminRepositoryProvider).deleteProgram(p.id);
    _load();
  }

  Future<void> _openForm({TrainingProgram? existing}) async {
    final saved = await showDialog<bool>(context: context, builder: (ctx) => _ProgramFormDialog(existing: existing));
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
            child: ElevatedButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Add Program')),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _programs.isEmpty
                  ? const EmptyState(icon: Icons.fitness_center_outlined, message: 'No programs yet')
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _programs.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final p = _programs[i];
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
                                    Text('${p.durationWeeks}w · ${p.sessionsCount} sessions · ${p.level.name}', style: const TextStyle(color: AppColors.onSurfaceMuted)),
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

class _ProgramFormDialog extends ConsumerStatefulWidget {
  final TrainingProgram? existing;
  const _ProgramFormDialog({this.existing});

  @override
  ConsumerState<_ProgramFormDialog> createState() => _ProgramFormDialogState();
}

class _ProgramFormDialogState extends ConsumerState<_ProgramFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _subtitle = TextEditingController(text: widget.existing?.subtitle ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _priceFrom = TextEditingController(text: widget.existing?.priceFrom.toString() ?? '');
  late final _durationWeeks = TextEditingController(text: widget.existing?.durationWeeks.toString() ?? '');
  late final _sessionsCount = TextEditingController(text: widget.existing?.sessionsCount.toString() ?? '');
  late ProgramLevel _level = widget.existing?.level ?? ProgramLevel.beginner;
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(adminRepositoryProvider);
    final program = TrainingProgram(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      subtitle: _subtitle.text.trim(),
      description: _description.text.trim(),
      priceFrom: double.tryParse(_priceFrom.text) ?? 0,
      durationWeeks: int.tryParse(_durationWeeks.text) ?? 0,
      sessionsCount: int.tryParse(_sessionsCount.text) ?? 0,
      level: _level,
      imageSeed: widget.existing?.imageSeed ?? _name.text.trim(),
    );
    try {
      if (widget.existing == null) {
        await repo.createProgram(program);
      } else {
        await repo.updateProgram(program);
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
      title: Text(widget.existing == null ? 'Add Program' : 'Edit Program'),
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
                AppTextField(label: 'Subtitle', controller: _subtitle),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Description', controller: _description),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Price From', controller: _priceFrom, keyboardType: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'Required' : null),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Duration (weeks)', controller: _durationWeeks, keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? 'Required' : null),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Sessions Count', controller: _sessionsCount, keyboardType: TextInputType.number, validator: (v) => int.tryParse(v ?? '') == null ? 'Required' : null),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<ProgramLevel>(
                  initialValue: _level,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: ProgramLevel.values.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                  onChanged: (v) => setState(() => _level = v ?? ProgramLevel.beginner),
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
