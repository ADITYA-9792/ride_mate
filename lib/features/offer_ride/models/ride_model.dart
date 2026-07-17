import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String id;
  final String driverId;
  final String pickup;
  final String destination;
  final String date;
  final String time;
  final String vehicle;
  final int seats;
  final int price;
  final String description;
  final bool ac;
  final bool smoking;
  final String status;
  final DateTime? createdAt;

  const RideModel({
    this.id = '',
    required this.driverId,
    required this.pickup,
    required this.destination,
    required this.date,
    required this.time,
    required this.vehicle,
    required this.seats,
    required this.price,
    this.description = '',
    this.ac = false,
    this.smoking = false,
    this.status = 'active',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'pickup': pickup,
      'destination': destination,
      'date': date,
      'time': time,
      'vehicle': vehicle,
      'seats': seats,
      'price': price,
      'description': description,
      'ac': ac,
      'smoking': smoking,
      'status': status,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  factory RideModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    return RideModel(
      id: documentId,
      driverId: map['driverId']?.toString() ?? '',
      pickup: map['pickup']?.toString() ?? '',
      destination: map['destination']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      vehicle: map['vehicle']?.toString() ?? '',
      seats: _toInt(map['seats']),
      price: _toInt(map['price']),
      description: map['description']?.toString() ?? '',

      // Supports both old and new Firestore field names.
      ac: map['ac'] == true || map['hasAc'] == true,
      smoking:
      map['smoking'] == true || map['smokingAllowed'] == true,

      status: map['status']?.toString() ?? 'active',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  RideModel copyWith({
    String? id,
    String? driverId,
    String? pickup,
    String? destination,
    String? date,
    String? time,
    String? vehicle,
    int? seats,
    int? price,
    String? description,
    bool? ac,
    bool? smoking,
    String? status,
    DateTime? createdAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      time: time ?? this.time,
      vehicle: vehicle ?? this.vehicle,
      seats: seats ?? this.seats,
      price: price ?? this.price,
      description: description ?? this.description,
      ac: ac ?? this.ac,
      smoking: smoking ?? this.smoking,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}