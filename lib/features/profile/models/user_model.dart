import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String vehicle;
  final String licenseNumber;
  final String bio;
  final String photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicle,
    required this.licenseNumber,
    required this.bio,
    required this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.empty({
    required String uid,
    required String email,
  }) {
    return UserModel(
      uid: uid,
      name: '',
      email: email,
      phone: '',
      vehicle: '',
      licenseNumber: '',
      bio: '',
      photoUrl: '',
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      vehicle: map['vehicle']?.toString() ?? '',
      licenseNumber: map['licenseNumber']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  factory UserModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? <String, dynamic>{};

    return UserModel.fromMap({
      ...data,
      'uid': data['uid'] ?? document.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicle': vehicle,
      'licenseNumber': licenseNumber,
      'bio': bio,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? vehicle,
    String? licenseNumber,
    String? bio,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicle: vehicle ?? this.vehicle,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}