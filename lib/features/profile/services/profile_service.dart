import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Returns the currently logged-in user's UID.
  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user is currently signed in.',
      );
    }

    return user.uid;
  }

  /// Creates a new profile if one doesn't already exist.
  Future<void> createProfile(UserModel userModel) async {
    final document = _usersCollection.doc(userModel.uid);

    final snapshot = await document.get();

    if (!snapshot.exists) {
      await document.set(userModel.toMap());
    }
  }

  /// Fetches the current user's profile.
  Future<UserModel?> getProfile() async {
    final snapshot =
    await _usersCollection.doc(currentUserId).get();

    if (!snapshot.exists) {
      return null;
    }

    return UserModel.fromDocument(snapshot);
  }

  /// Updates profile details.
  Future<void> updateProfile(UserModel userModel) async {
    await _usersCollection
        .doc(userModel.uid)
        .update(userModel.toMap());
  }
}