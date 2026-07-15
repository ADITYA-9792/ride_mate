import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String id;
  final String userId;
  final String pickup;
  final String destination;
  final String date;
  final String time;
  final String vehicle;
  final int seats;
  final int price;
  final String description;
  final String status;
  final DateTime createdAt;

  const RideModel({
    this.id = '',
    required this.userId,
    required this.pickup,
    required this.destination,
    required this.date,
    required this.time,
    required this.vehicle,
    required this.seats,
    required this.price,
    required this.description,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pickup': pickup,
      'destination': destination,
      'date': date,
      'time': time,
      'vehicle': vehicle,
      'seats': seats,
      'price': price,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RideModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data()!;

    return RideModel(
      id: document.id,
      userId: data['userId'] ?? '',
      pickup: data['pickup'] ?? '',
      destination: data['destination'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      vehicle: data['vehicle'] ?? '',
      seats: data['seats'] ?? 1,
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      status: data['status'] ?? 'active',
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}