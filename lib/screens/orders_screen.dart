import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/paid_order.dart';
import '../theme/app_theme.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _onlyUnassigned = true;
  List<PaidOrder> _orders = [];
  List<TrainerRosterEntry> _roster = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final orders = await repo.getPaidOrders(onlyUnassigned: _onlyUnassigned);
      final roster = await repo.getTrainerRoster();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _roster = roster;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _assign(PaidOrder order, TrainerRosterEntry trainer) async {
    try {
      await ref.read(adminRepositoryProvider).assignTrainer(order.id, trainer.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Unassigned'),
                selected: _onlyUnassigned,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => setState(() {
                  _onlyUnassigned = true;
                  _load();
                }),
              ),
              const SizedBox(width: AppSpacing.sm),
              ChoiceChip(
                label: const Text('All Paid Orders'),
                selected: !_onlyUnassigned,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => setState(() {
                  _onlyUnassigned = false;
                  _load();
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? const EmptyState(icon: Icons.receipt_long_outlined, message: 'No paid orders found')
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _orders.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => _OrderCard(
                        order: _orders[i],
                        roster: _roster,
                        onAssign: (trainer) => _assign(_orders[i], trainer),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final PaidOrder order;
  final List<TrainerRosterEntry> roster;
  final ValueChanged<TrainerRosterEntry> onAssign;
  const _OrderCard({required this.order, required this.roster, required this.onAssign});

  @override
  Widget build(BuildContext context) {
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
              Expanded(child: Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Text('${order.total.toStringAsFixed(0)} SAR', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          if (order.packageName.isNotEmpty) Text(order.packageName, style: const TextStyle(color: AppColors.onSurfaceMuted)),
          if (order.city.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(order.city, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(DateFormat.yMMMd().add_jm().format(order.createdAt), style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (order.trainerName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text('Assigned to ${order.trainerName}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
            )
          else
            _AssignRow(roster: roster, onAssign: onAssign),
        ],
      ),
    );
  }
}

class _AssignRow extends StatefulWidget {
  final List<TrainerRosterEntry> roster;
  final ValueChanged<TrainerRosterEntry> onAssign;
  const _AssignRow({required this.roster, required this.onAssign});

  @override
  State<_AssignRow> createState() => _AssignRowState();
}

class _AssignRowState extends State<_AssignRow> {
  TrainerRosterEntry? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.roster.isEmpty) {
      return const Text('No trainers with a linked account yet', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12));
    }
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<TrainerRosterEntry>(
            initialValue: _selected,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
            ),
            hint: const Text('Select trainer'),
            items: widget.roster
                .map((t) => DropdownMenuItem(value: t, child: Text('${t.name} (${t.activeClientCount} clients)')))
                .toList(),
            onChanged: (t) => setState(() => _selected = t),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: 'Assign',
          onPressed: _selected == null ? null : () => widget.onAssign(_selected!),
        ),
      ],
    );
  }
}
