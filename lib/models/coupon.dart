class Coupon {
  final String code;
  final double discountPercent;
  final bool isActive;

  const Coupon({required this.code, required this.discountPercent, this.isActive = true});

  factory Coupon.fromRow(Map<String, dynamic> row) => Coupon(
        code: row['code'] as String,
        discountPercent: (row['discount_percent'] as num?)?.toDouble() ?? 0,
        isActive: row['is_active'] as bool? ?? true,
      );

  Coupon copyWith({double? discountPercent, bool? isActive}) => Coupon(
        code: code,
        discountPercent: discountPercent ?? this.discountPercent,
        isActive: isActive ?? this.isActive,
      );
}
