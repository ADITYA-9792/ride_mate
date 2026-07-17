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
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _ridesCollection.add(
      ride.toMap(),
    );
  }

  Stream<List<RideModel>> getMyRides() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _ridesCollection
        .where(
      'userId',
      isEqualTo: user.uid,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (document) => RideModel.fromDocument(document),
        )
            .toList();
      },
    );
  }

  Future<void> updateRide(
      String rideId,
      Map<String, dynamic> updatedData,
      ) async {
    if (rideId.isEmpty) {
      throw Exception('Ride ID is missing.');
    }

    await _ridesCollection.doc(rideId).update({
      ...updatedData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelRide(String rideId) async {
    if (rideId.isEmpty) {
      throw Exception('Ride ID is missing.');
    }

    await _ridesCollection.doc(rideId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRide(String rideId) async {
    if (rideId.isEmpty) {
      throw Exception('Ride ID is missing.');
    }

    await _ridesCollection.doc(rideId).delete();
  }

  Future<RideModel?> getRideById(String rideId) async {
    if (rideId.isEmpty) {
      return null;
    }

    final document = await _ridesCollection.doc(rideId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return RideModel.fromDocument(document);
  }
}