import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/registration/domain/entities/business.dart';

class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String? registrationNumber;
  final String biasharaCode;
  final GeoPoint location;
  final String addressLine;
  final String category;
  final DateTime createdAt;
  final String? phoneNumber;
  final String? description;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.registrationNumber,
    required this.biasharaCode,
    required this.location,
    required this.addressLine,
    required this.category,
    required this.createdAt,
    this.phoneNumber,
    this.description,
  });

  factory BusinessModel.fromDomain(Business business) {
    return BusinessModel(
      id: business.id,
      ownerId: business.ownerId,
      name: business.name,
      registrationNumber: business.registrationNumber,
      biasharaCode: business.biasharaCode,
      location: business.location,
      addressLine: business.addressLine,
      category: business.category,
      createdAt: business.createdAt,
      phoneNumber: business.phoneNumber,
      description: business.description,
    );
  }

  factory BusinessModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return BusinessModel(
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

  Business toDomain() {
    return Business(
      id: id,
      ownerId: ownerId,
      name: name,
      registrationNumber: registrationNumber,
      biasharaCode: biasharaCode,
      location: location,
      addressLine: addressLine,
      category: category,
      createdAt: createdAt,
      phoneNumber: phoneNumber,
      description: description,
    );
  }
}
