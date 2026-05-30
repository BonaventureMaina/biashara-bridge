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

  factory Business.fromFirestore(Map<String, dynamic> data, String docId) {
    return Business(
      id: docId,
      ownerId: data['ownerId'] as String,
      name: data['name'] as String,
      registrationNumber: data['registrationNumber'] as String?,
      biasharaCode: data['biasharaCode'] as String,
      location: data['location'] as GeoPoint,
      addressLine: data['addressLine'] as String,
      category: data['category'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      phoneNumber: data['phoneNumber'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'registrationNumber': registrationNumber,
      'biasharaCode': biasharaCode,
      'location': location,
      'addressLine': addressLine,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'phoneNumber': phoneNumber,
      'description': description,
    };
  }
}
