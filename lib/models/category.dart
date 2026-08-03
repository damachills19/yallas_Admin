class TrainingCategory {
  final String id;
  final String name;
  final String iconSeed;

  const TrainingCategory({required this.id, required this.name, required this.iconSeed});

  factory TrainingCategory.fromRow(Map<String, dynamic> row) => TrainingCategory(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        iconSeed: row['icon_seed'] as String? ?? '',
      );
}
