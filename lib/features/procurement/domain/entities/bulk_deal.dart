import 'package:freezed_annotation/freezed_annotation.dart';

part 'bulk_deal.freezed.dart';

@freezed
class BulkDeal with _$BulkDeal {
  const factory BulkDeal({
    required String id,
    required String title,
    required String description,
    required String supplierId,
    required double pricePerUnit,
    required int minOrderQuantity,
    required int availableQuantity,
    required DateTime createdAt,
    required DateTime expiresAt,
    required List<String> claimedBy,
  }) = _BulkDeal;
}
