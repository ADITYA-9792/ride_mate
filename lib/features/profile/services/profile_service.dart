import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

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

  Future<void> createProfile(UserModel userModel) async {
    final document = _usersCollection.doc(userModel.uid);

    final snapshot = await document.get();

    if (!snapshot.exists) {
      await document.set(userModel.toMap());
    }
  }

  Future<UserModel?> getProfile() async {
    final snapshot =
    await _usersCollection.doc(currentUserId).get();

    if (!snapshot.exists) {
      return null;
    }

    return UserModel.fromDocument(snapshot);
  }

  Future<void> updateProfile(UserModel userModel) async {
    await _usersCollection
        .doc(userModel.uid)
        .update(userModel.toMap());
  }

  // -----------------------------
  // Profile Photo Upload
  // -----------------------------

  Future<String?> uploadProfilePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return null;
    }

    final File file = File(image.path);

    final Reference reference = _storage
        .ref()
        .child('profile_images')
        .child('$currentUserId.jpg');

    await reference.putFile(file);

    final String downloadUrl =
    await reference.getDownloadURL();

    await _usersCollection.doc(currentUserId).update({
      'photoUrl': downloadUrl,
    });

    return downloadUrl;
  }
}