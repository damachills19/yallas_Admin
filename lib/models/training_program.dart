enum ProgramLevel { beginner, intermediate, advanced }

ProgramLevel programLevelFromString(String? s) {
  switch (s) {
    case 'intermediate':
      return ProgramLevel.intermediate;
    case 'advanced':
      return ProgramLevel.advanced;
    default:
      return ProgramLevel.beginner;
  }
}

class TrainingProgram {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final double priceFrom;
  final int durationWeeks;
  final int sessionsCount;
  final ProgramLevel level;
  final String imageSeed;

  const TrainingProgram({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.priceFrom,
    required this.durationWeeks,
    required this.sessionsCount,
    required this.level,
    required this.imageSeed,
  });

  factory TrainingProgram.fromRow(Map<String, dynamic> row) => TrainingProgram(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        subtitle: row['subtitle'] as String? ?? '',
        description: row['description'] as String? ?? '',
        priceFrom: (row['price_from'] as num?)?.toDouble() ?? 0,
        durationWeeks: (row['duration_weeks'] as num?)?.toInt() ?? 0,
        sessionsCount: (row['sessions_count'] as num?)?.toInt() ?? 0,
        level: programLevelFromString(row['level'] as String?),
        imageSeed: row['image_seed'] as String? ?? '',
      );

  Map<String, dynamic> toRow() => {
        'name': name,
        'subtitle': subtitle,
        'description': description,
        'price_from': priceFrom,
        'duration_weeks': durationWeeks,
        'sessions_count': sessionsCount,
        'level': level.name,
        'image_seed': imageSeed,
      };
}
