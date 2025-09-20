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

      final snapshot = await _firestore.collectionGroup('issues').get();

      // Temporary grouping map
      final Map<String, Map<String, dynamic>> grouped = {};

      for (var doc in snapshot.docs) {
        final d = doc.data();
        final issueType = d['issue_type'] ?? 'Unknown';
        final lat = d['latitude']?.toString() ?? '0.0';
        final lng = d['longitude']?.toString() ?? '0.0';

        // Unique key for grouping based on issue + location
        final key = "$issueType-$lat-$lng";

        if (grouped.containsKey(key)) {
          grouped[key]!['count'] += 1;
          grouped[key]!['ids'].add(doc.id);
        } else {
          grouped[key] = {
            'issue_type': issueType,
            'latitude': lat,
            'longitude': lng,
            'description': d['description'] ?? '',
            'status': d['status'] ?? 'Pending',
            'urgency': d['urgency'] ?? 'Medium',
            'count': 1,
            'ids': [doc.id],
          };
        }
      }

      _data = grouped.values.toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
