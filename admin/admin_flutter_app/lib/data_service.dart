import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class DataService extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _database.child('issues').get();
      if (snapshot.exists) {
        final dataMap = Map<String, dynamic>.from(snapshot.value as Map);
        _data = dataMap.entries.map((entry) {
          return {
            'id': entry.key,
            ...Map<String, dynamic>.from(entry.value as Map),
          };
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

  Future<void> addData(Map<String, dynamic> newData) async {
    try {
      await _database.child('issues').push().set(newData);
      await fetchData(); // Refresh the data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateData(String id, Map<String, dynamic> updatedData) async {
    try {
      await _database.child('issues').child(id).update(updatedData);
      await fetchData(); // Refresh the data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await _database.child('issues').child(id).remove();
      await fetchData(); // Refresh the data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
