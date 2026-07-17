import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ride_model.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ridesCollection {
    return _firestore.collection('rides');
  }

  Future<void> publishRide(RideModel ride) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('Please login before publishing a ride.');
    }

    final Map<String, dynamic> rideData = ride.toMap();

    rideData['driverId'] = currentUser.uid;
    rideData['status'] = 'active';
    rideData['createdAt'] = FieldValue.serverTimestamp();
    rideData['updatedAt'] = FieldValue.serverTimestamp();

    await _ridesCollection.add(rideData);
  }

  Stream<List<RideModel>> getMyRides() {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Stream<List<RideModel>>.value([]);
    }

    return _ridesCollection
        .where(
      'driverId',
      isEqualTo: currentUser.uid,
    )
        .snapshots()
        .map((snapshot) {
      final List<RideModel> rides = snapshot.docs.map((document) {
        return RideModel.fromMap(
          document.data(),
          document.id,
        );
      }).toList();

      rides.sort((firstRide, secondRide) {
        final DateTime firstDate =
            firstRide.createdAt ?? DateTime(2000);
        final DateTime secondDate =
            secondRide.createdAt ?? DateTime(2000);

        return secondDate.compareTo(firstDate);
      });

      return rides;
    });
  }

  Future<void> updateRide({
    required String rideId,
    required RideModel ride,
  }) async {
    if (rideId.trim().isEmpty) {
      throw Exception("Ride ID is missing.");
    }

    await _ridesCollection.doc(rideId).update({
      'pickup': ride.pickup,
      'destination': ride.destination,
      'date': ride.date,
      'time': ride.time,
      'vehicle': ride.vehicle,
      'seats': ride.seats,
      'price': ride.price,
      'description': ride.description,
      'status': ride.status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelRide(String rideId) async {
    if (rideId.trim().isEmpty) {
      throw Exception('Ride ID is missing.');
    }

    await _ridesCollection.doc(rideId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRide(String rideId) async {
    if (rideId.trim().isEmpty) {
      throw Exception('Ride ID is missing.');
    }

    await _ridesCollection.doc(rideId).delete();
  }
}