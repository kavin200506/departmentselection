import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current user's profile data as a Map, or null if not found.
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Checks whether the current user's profile is complete.
  /// (Complete = all required fields are non-empty/non-null)
  static Future<bool> isProfileComplete() async {
    final data = await fetchProfile();
    if (data == null) return false;

    final requiredKeys = ['name', 'email', 'mobile', 'age']; // you can add more
    for (final key in requiredKeys) {
      final value = data[key];
      if (value == null || value.toString().trim().isEmpty || value == '0') {
        return false;
      }
    }
    return true;
  }

  /// Creates or updates the user profile in Firestore.
  /// Accepts any map of fields to write/merge.
  static Future<void> upsertProfile(Map<String, dynamic> newData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No user signed in!');
    await _firestore.collection('users').doc(uid).set(
      newData, SetOptions(merge: true),
    );
  }
}
