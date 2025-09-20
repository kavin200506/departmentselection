import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all issues (from top-level collection)
  Future<void> fetchData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use collectionGroup if issues are subcollections under users
      final snapshot = await _firestore.collectionGroup('issues').get();

      if (snapshot.docs.isNotEmpty) {
        _data = snapshot.docs.map((doc) {
          final d = doc.data();
          d['id'] = doc.id; // keep document id
          return d;
        }).toList();
      } else {
        _data = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
