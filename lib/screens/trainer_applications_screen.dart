import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/trainer_application.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import '../providers/locale_provider.dart';
import '../l10n/admin_strings.dart';

class TrainerApplicationsScreen extends ConsumerStatefulWidget {
  const TrainerApplicationsScreen({super.key});

  @override
  ConsumerState<TrainerApplicationsScreen> createState() => _TrainerApplicationsScreenState();
}

class _TrainerApplicationsScreenState extends ConsumerState<TrainerApplicationsScreen> {
  VerificationStatus? _filter = VerificationStatus.pending;
  List<TrainerApplication> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(adminRepositoryProvider).getApplications(filterStatus: _filter);
      if (!mounted) return;
      setState(() {
        _applications = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _respond(TrainerApplication app, {required bool approve}) async {
    if (!approve) {
      final locale = ref.read(adminLocaleProvider);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t(locale, 'reject_application_title')),
          content: Text(t(locale, 'reject_application_body')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t(locale, 'cancel'))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t(locale, 'confirm'))),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      await ref.read(adminRepositoryProvider).respondToApplication(app.trainerId, approve: approve);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(adminLocaleProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _FilterChip(label: t(locale, 'filter_pending'), selected: _filter == VerificationStatus.pending, onTap: () => setState(() { _filter = VerificationStatus.pending; _load(); })),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(label: t(locale, 'filter_approved'), selected: _filter == VerificationStatus.approved, onTap: () => setState(() { _filter = VerificationStatus.approved; _load(); })),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(label: t(locale, 'filter_rejected'), selected: _filter == VerificationStatus.rejected, onTap: () => setState(() { _filter = VerificationStatus.rejected; _load(); })),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _applications.isEmpty
                  ? EmptyState(icon: Icons.assignment_ind_outlined, message: t(locale, 'no_applications_found'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _applications.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => _ApplicationCard(
                        application: _applications[i],
                        locale: locale,
                        onApprove: () => _respond(_applications[i], approve: true),
                        onReject: () => _respond(_applications[i], approve: false),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, selectedColor: AppColors.primaryLight, onSelected: (_) => onTap());
  }
}

class _ApplicationCard extends ConsumerWidget {
  final TrainerApplication application;
  final AppLocale locale;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ApplicationCard({required this.application, required this.locale, required this.onApprove, required this.onReject});

  Future<void> _openDocument(BuildContext context, WidgetRef ref, String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final url = await ref.read(adminRepositoryProvider).getDocumentUrl(path);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t(locale, 'document_link')),
          content: SelectableText(url),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t(locale, 'close')))],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = application.verificationStatus == VerificationStatus.pending;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  application.trainerName.isNotEmpty ? application.trainerName : application.trainerId,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(status: application.verificationStatus, locale: locale),
            ],
          ),
          if (application.trainerEmail.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(application.trainerEmail, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(DateFormat.yMMMd().add_jm().format(application.submittedAt), style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
          const SizedBox(height: AppSpacing.sm),
          if (application.qualifications.isNotEmpty) Text(application.qualifications),
          if (application.experienceBio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(application.experienceBio, style: const TextStyle(color: AppColors.onSurfaceMuted)),
          ],
          const SizedBox(height: 4),
          Text('${application.experienceYears} ${t(locale, 'years_experience')}', style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
          if (application.certifications.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: application.certifications.map((c) => Chip(label: Text(c), visualDensity: VisualDensity.compact)).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (application.idCardFrontPath != null)
                OutlinedButton.icon(icon: const Icon(Icons.badge_outlined, size: 16), label: Text(t(locale, 'id_front')), onPressed: () => _openDocument(context, ref, application.idCardFrontPath)),
              if (application.idCardBackPath != null)
                OutlinedButton.icon(icon: const Icon(Icons.badge_outlined, size: 16), label: Text(t(locale, 'id_back')), onPressed: () => _openDocument(context, ref, application.idCardBackPath)),
              for (var i = 0; i < application.certificatePaths.length; i++)
                OutlinedButton.icon(icon: const Icon(Icons.description_outlined, size: 16), label: Text('${t(locale, 'certificate_n')} ${i + 1}'), onPressed: () => _openDocument(context, ref, application.certificatePaths[i])),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: AppButton(label: t(locale, 'approve'), onPressed: onApprove)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: AppButton(label: t(locale, 'reject'), outlined: true, onPressed: onReject)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VerificationStatus status;
  final AppLocale locale;
  const _StatusBadge({required this.status, required this.locale});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case VerificationStatus.pending:
        color = AppColors.primary;
        label = t(locale, 'status_pending');
        break;
      case VerificationStatus.approved:
        color = AppColors.success;
        label = t(locale, 'status_approved');
        break;
      case VerificationStatus.rejected:
        color = AppColors.error;
        label = t(locale, 'status_rejected');
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
