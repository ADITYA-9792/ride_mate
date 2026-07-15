import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ride_model.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> publishRide(RideModel ride) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _firestore.collection('rides').add(ride.toMap());
  }

  Stream<List<RideModel>> getMyRides() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('rides')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(RideModel.fromDocument)
          .toList(),
    );
  }

  Future<void> cancelRide(String rideId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
    });
  }
}