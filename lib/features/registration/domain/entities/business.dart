import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'business.freezed.dart';

@freezed
class Business with _$Business {
  const factory Business({
    required String id,
    required String ownerId,
    required String name,
    String? registrationNumber,
    required String biasharaCode,
    required GeoPoint location,
    required String addressLine,
    required String category,
    required DateTime createdAt,
    String? phoneNumber,
    String? description,
  }) = _Business;
}
