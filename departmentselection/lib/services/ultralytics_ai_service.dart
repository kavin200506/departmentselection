import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UltralyticsAIService {
  static const String _apiUrl = 'https://predict.ultralytics.com';
  static const String _apiKey = '62136b284fcca764aec069d7ddd705de453fdecce7'; // Your API key
  static const String _modelUrl = 'https://hub.ultralytics.com/models/A69qnBQ3qstjoQSiJtIs'; // Your model
  
  // Class mapping for your 3 classes
  static const Map<String, String> _classToIssueType = {
    'pothole': 'Pothole',
    'streetlight': 'Streetlight Broken',
    'garbage': 'Garbage Pile',
  };
  
  // Department mapping
  static const Map<String, String> _issueToDepartment = {
    'Pothole': 'Road Department',
    'Streetlight Broken': 'Electrical Department', 
    'Garbage Pile': 'Sanitation Department',
    'Water Leak': 'Water & Sewerage',
    'Drainage Overflow': 'Water & Sewerage',
    'Road Crack': 'Road Department',
  };

  /// ✅ MAIN API METHOD - Enhanced with better error handling
  static Future<Map<String, dynamic>> analyzeImage(String firebaseImageUrl) async {
    try {
      print('🤖 Starting Ultralytics API Analysis...');
      print('📎 Firebase Image URL: $firebaseImageUrl');
      print('🔗 API Endpoint: $_apiUrl');
      
      // Download image from Firebase Storage
      print('📥 Downloading image from Firebase Storage...');
      final imageBytes = await _downloadImageFromFirebase(firebaseImageUrl);
      print('✅ Image downloaded: ${imageBytes.length} bytes');
      
      // Send to Ultralytics API
      print('🚀 Sending to Ultralytics API...');
      final result = await _sendToUltralyticsAPI(imageBytes);
      
      print('✅ Ultralytics API Analysis Complete');
      return result;
      
    } catch (e) {
      print('❌ Ultralytics API analysis failed: $e');
      return {
        'success': false,
        'detected_issue': null,
        'ai_department': null,
        'confidence': 0.0,
        'message': 'Ultralytics API analysis failed: $e',
        'requires_manual_selection': true,
        'is_api_error': true,
      };
    }
  }

  /// Download image from Firebase Storage
  static Future<Uint8List> _downloadImageFromFirebase(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(
        const Duration(seconds: 30),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: HTTP ${response.statusCode}');
      }
      
      return response.bodyBytes;
      
    } catch (e) {
      throw Exception('Image download failed: $e');
    }
  }

  /// Send image to Ultralytics API
  static Future<Map<String, dynamic>> _sendToUltralyticsAPI(Uint8List imageBytes) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Add headers
      request.headers['x-api-key'] = _apiKey;
      
      // Add form fields
      request.fields['model'] = _modelUrl;
      request.fields['imgsz'] = '640';
      request.fields['conf'] = '0.25';
      request.fields['iou'] = '0.45';
      
      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'civic_image.jpg',
        ),
      );
      
      print('📤 Sending request to Ultralytics...');
      
      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      
      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📨 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return _processAPIResponse(jsonResponse);
      } else {
        throw Exception('API request failed: HTTP ${response.statusCode}\nBody: ${response.body}');
      }
      
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Process API response from Ultralytics
  static Map<String, dynamic> _processAPIResponse(Map<String, dynamic> apiResponse) {
    try {
      print('🔄 Processing API response...');
      print('📊 Raw response keys: ${apiResponse.keys.join(', ')}');
      
      // Check if response has images
      final images = apiResponse['images'] as List<dynamic>? ?? [];
      if (images.isEmpty) {
        return _createNoDetectionResult('No images in API response');
      }
      
      final firstImage = images[0] as Map<String, dynamic>;
      final results = firstImage['results'] as List<dynamic>? ?? [];
      
      print('📊 Found ${results.length} detections');
      
      if (results.isEmpty) {
        return _createNoDetectionResult('No detections found');
      }
      
      // Find best detection for civic issues
      Map<String, dynamic>? bestDetection;
      double highestConfidence = 0.0;
      String? detectedClass;
      
      for (var detection in results) {
        final className = (detection['name'] ?? '').toString().toLowerCase();
        final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;
        
        print('🔍 Detection: $className (${(confidence * 100).toStringAsFixed(1)}%)');
        
        // Check if it matches our civic issue classes
        if (_classToIssueType.containsKey(className) && confidence > highestConfidence) {
          highestConfidence = confidence;
          bestDetection = detection;
          detectedClass = className;
          
          print('✅ Best match so far: $className (${(confidence * 100).toStringAsFixed(1)}%)');
        }
      }
      
      if (bestDetection == null || highestConfidence < 0.25) {
        return _createNoDetectionResult('No civic issue detected above confidence threshold');
      }
      
      return _createSuccessResult(detectedClass!, highestConfidence, bestDetection, results);
      
    } catch (e) {
      print('❌ Error processing API response: $e');
      return _createNoDetectionResult('Failed to process API response: $e');
    }
  }

  /// Create successful detection result
  static Map<String, dynamic> _createSuccessResult(
    String detectedClass, 
    double confidence, 
    Map<String, dynamic> detection,
    List<dynamic> allResults,
  ) {
    final issueType = _classToIssueType[detectedClass]!;
    final department = _issueToDepartment[issueType]!;
    final isHighConfidence = confidence >= 0.6;
    
    print('🎯 ULTRALYTICS DETECTION: $issueType (${(confidence * 100).toStringAsFixed(1)}%)');
    print('🏢 Department: $department');
    print('📊 High Confidence: $isHighConfidence');
    
    return {
      'success': true,
      'detected_issue': issueType,
      'ai_department': department,
      'confidence': confidence,
      'message': isHighConfidence 
          ? '🎯 HIGH CONFIDENCE ULTRALYTICS DETECTION'
          : '📊 MEDIUM CONFIDENCE ULTRALYTICS - Please verify',
      'requires_manual_selection': !isHighConfidence,
      'is_ultralytics_api': true,
      'detection_metadata': {
        'model': 'Custom YOLO via Ultralytics API',
        'api_endpoint': _apiUrl,
        'detected_class': detectedClass,
        'raw_detection': detection,
        'total_detections': allResults.length,
        'processing': 'Cloud-based YOLO Inference',
      },
      'technical_details': {
        'confidence_threshold': '25%',
        'high_confidence_threshold': '60%',
        'image_size': '640x640',
        'model_type': 'YOLOv8 Custom Trained',
        'api_version': 'Ultralytics HUB',
        'all_detections': allResults,
      },
    };
  }

  /// Create no detection result
  static Map<String, dynamic> _createNoDetectionResult(String reason) {
    print('ℹ️ No detection: $reason');
    
    return {
      'success': false,
      'detected_issue': null,
      'ai_department': null,
      'confidence': 0.0,
      'message': 'Ultralytics API: $reason',
      'requires_manual_selection': true,
      'is_ultralytics_api': true,
    };
  }

  /// Get department for issue type
  static String getDepartmentForIssue(String issueType) {
    return _issueToDepartment[issueType] ?? 'Municipal Services Department';
  }

  /// Check if result is high confidence
  static bool isHighConfidence(Map<String, dynamic> result) {
    final confidence = result['confidence'] as double? ?? 0.0;
    return confidence >= 0.6 && result['success'] == true;
  }

  /// Test API connectivity
  static Future<bool> testAPIConnection() async {
    try {
      print('🔍 Testing Ultralytics API connectivity...');
      
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'x-api-key': _apiKey},
      ).timeout(const Duration(seconds: 10));
      
      print('✅ API connectivity test: ${response.statusCode}');
      return response.statusCode == 200;
      
    } catch (e) {
      print('❌ API connectivity test failed: $e');
      return false;
    }
  }
}
