class TrainingPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final int sessionsCount;
  final String categoryId;
  final String imageSeed;
  final bool isAvailable;
  final double? originalPrice;
  final List<String> includedItems;
  final bool isCustomizable;

  const TrainingPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sessionsCount,
    required this.categoryId,
    required this.imageSeed,
    this.isAvailable = true,
    this.originalPrice,
    this.includedItems = const [],
    this.isCustomizable = false,
  });

  factory TrainingPackage.fromRow(Map<String, dynamic> row) => TrainingPackage(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        description: row['description'] as String? ?? '',
        price: (row['price'] as num?)?.toDouble() ?? 0,
        sessionsCount: (row['sessions_count'] as num?)?.toInt() ?? 0,
        categoryId: row['category_id'] as String? ?? '',
        imageSeed: row['image_seed'] as String? ?? '',
        isAvailable: row['is_available'] as bool? ?? true,
        originalPrice: (row['original_price'] as num?)?.toDouble(),
        includedItems: (row['included_items'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        isCustomizable: row['is_customizable'] as bool? ?? false,
      );

  Map<String, dynamic> toRow() => {
        'name': name,
        'description': description,
        'price': price,
        'original_price': originalPrice,
        'sessions_count': sessionsCount,
        'category_id': categoryId.isEmpty ? null : categoryId,
        'image_seed': imageSeed,
        'is_available': isAvailable,
        'included_items': includedItems,
        'is_customizable': isCustomizable,
      };
}
