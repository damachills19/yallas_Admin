class PaidOrder {
  final String id;
  final String clientName;
  final String packageName;
  final String city;
  final double total;
  final String? trainerId;
  final String? trainerName;
  final DateTime createdAt;

  const PaidOrder({
    required this.id,
    required this.clientName,
    required this.packageName,
    required this.city,
    required this.total,
    this.trainerId,
    this.trainerName,
    required this.createdAt,
  });

  factory PaidOrder.fromRow(Map<String, dynamic> row, {String clientName = ''}) {
    final items = (row['order_items'] as List?) ?? const [];
    String packageName = '';
    if (items.isNotEmpty) {
      final pkg = (items.first as Map)['training_packages'] as Map?;
      packageName = (pkg?['name'] as String?) ?? '';
    }
    final trainer = row['trainers'] as Map<String, dynamic>?;
    return PaidOrder(
      id: row['id'] as String,
      clientName: clientName.isEmpty ? 'Client' : clientName,
      packageName: packageName,
      city: (row['addresses'] as Map?)?['city'] as String? ?? '',
      total: (row['total'] as num?)?.toDouble() ?? 0,
      trainerId: row['trainer_id'] as String?,
      trainerName: trainer?['name'] as String?,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class TrainerRosterEntry {
  final String id;
  final String name;
  final int activeClientCount;

  const TrainerRosterEntry({required this.id, required this.name, required this.activeClientCount});
}
