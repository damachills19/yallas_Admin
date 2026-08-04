import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import '../providers/locale_provider.dart';
import '../l10n/admin_strings.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  String? _filter;
  List<Complaint> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ref.read(adminRepositoryProvider).getComplaints(filterStatus: _filter);
    if (!mounted) return;
    setState(() {
      _complaints = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(adminLocaleProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            children: [
              _FilterChip(label: t(locale, 'filter_all'), selected: _filter == null, onTap: () => setState(() { _filter = null; _load(); })),
              _FilterChip(label: t(locale, 'filter_open'), selected: _filter == 'open', onTap: () => setState(() { _filter = 'open'; _load(); })),
              _FilterChip(label: t(locale, 'filter_in_progress'), selected: _filter == 'in_progress', onTap: () => setState(() { _filter = 'in_progress'; _load(); })),
              _FilterChip(label: t(locale, 'filter_resolved'), selected: _filter == 'resolved', onTap: () => setState(() { _filter = 'resolved'; _load(); })),
              _FilterChip(label: t(locale, 'filter_closed'), selected: _filter == 'closed', onTap: () => setState(() { _filter = 'closed'; _load(); })),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _complaints.isEmpty
                  ? EmptyState(icon: Icons.support_agent_outlined, message: t(locale, 'no_complaints_found'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _complaints.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => _ComplaintCard(complaint: _complaints[i], locale: locale, onChanged: _load),
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

class _ComplaintCard extends ConsumerStatefulWidget {
  final Complaint complaint;
  final AppLocale locale;
  final VoidCallback onChanged;
  const _ComplaintCard({required this.complaint, required this.locale, required this.onChanged});

  @override
  ConsumerState<_ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends ConsumerState<_ComplaintCard> {
  late final _response = TextEditingController(text: widget.complaint.adminResponse ?? '');
  bool _expanded = false;
  bool _saving = false;

  Future<void> _updateStatus(ComplaintStatus status) async {
    setState(() => _saving = true);
    await ref.read(adminRepositoryProvider).respondToComplaint(widget.complaint.id, status: status);
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onChanged();
  }

  Future<void> _sendResponse() async {
    setState(() => _saving = true);
    await ref.read(adminRepositoryProvider).respondToComplaint(widget.complaint.id, adminResponse: _response.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
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
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(child: Text(c.subject.isEmpty ? t(widget.locale, 'no_subject') : c.subject, style: const TextStyle(fontWeight: FontWeight.bold))),
                _StatusBadge(status: c.status, locale: widget.locale),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          Text(DateFormat.yMMMd().format(c.createdAt), style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(c.message),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _response, maxLines: 3, decoration: InputDecoration(labelText: t(widget.locale, 'admin_response'))),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: t(widget.locale, 'send_response'), onPressed: _sendResponse, isLoading: _saving),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                OutlinedButton(onPressed: () => _updateStatus(ComplaintStatus.inProgress), child: Text(t(widget.locale, 'filter_in_progress'))),
                OutlinedButton(onPressed: () => _updateStatus(ComplaintStatus.resolved), child: Text(t(widget.locale, 'filter_resolved'))),
                OutlinedButton(onPressed: () => _updateStatus(ComplaintStatus.closed), child: Text(t(widget.locale, 'filter_closed'))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  final AppLocale locale;
  const _StatusBadge({required this.status, required this.locale});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case ComplaintStatus.open:
        color = AppColors.primary;
        label = t(locale, 'complaint_status_open');
        break;
      case ComplaintStatus.inProgress:
        color = AppColors.warning;
        label = t(locale, 'complaint_status_in_progress');
        break;
      case ComplaintStatus.resolved:
        color = AppColors.success;
        label = t(locale, 'complaint_status_resolved');
        break;
      case ComplaintStatus.closed:
        color = AppColors.onSurfaceMuted;
        label = t(locale, 'complaint_status_closed');
        break;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
