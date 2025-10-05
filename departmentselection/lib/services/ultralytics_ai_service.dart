import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UltralyticsAIService {
  // ✅ NEW MODEL CONFIGURATION
  static const String _apiUrl = 'https://predict.ultralytics.com';
  static const String _apiKey = '62136b284fcca764aec069d7ddd705de453fdecce7';
  static const String _modelUrl = 'https://hub.ultralytics.com/models/VxsrWl4kOqQJHLMzd2wv'; // ✅ NEW MODEL
  
  // ✅ NEW MODEL CLASSES: 5 classes (drainage, garbage, pothole, streetlight, waterleak)
  static const Map<String, String> _classToIssueType = {
    'drainage': 'Drainage Overflow',
    'garbage': 'Garbage Pile',
    'pothole': 'Pothole',
    'streetlight': 'Streetlight Broken',
    'waterleak': 'Water Leak',
    // Note: 'Road Crack' is NOT in the model - will be handled manually
  };
  
  // Department mapping (including Road Crack for manual selection)
  static const Map<String, String> _issueToDepartment = {
    'Pothole': 'Road Department',
    'Streetlight Broken': 'Electrical Department', 
    'Garbage Pile': 'Sanitation Department',
    'Water Leak': 'Water & Sewerage',
    'Drainage Overflow': 'Water & Sewerage',
    'Road Crack': 'Road Department', // Manual selection only
  };

  /// ✅ MAIN API METHOD - Updated with 75% confidence threshold
  static Future<Map<String, dynamic>> analyzeImage(String firebaseImageUrl) async {
    try {
      print('🏆 CIVICHERO IGNITEX AI ANALYSIS - New 5-Class Model');
      print('🤖 Starting IgniteX AI Analysis...');
      print('📎 Firebase Image URL: $firebaseImageUrl');
      print('🔗 IgniteX API Endpoint: $_apiUrl');
      
      // Download image from Firebase Storage
      print('📥 IgniteX: Downloading image from Firebase Storage...');
      final imageBytes = await _downloadImageFromFirebase(firebaseImageUrl);
      print('✅ IgniteX: Image downloaded: ${imageBytes.length} bytes');
      
      // Send to Ultralytics API (backend)
      print('🚀 IgniteX: Sending to NEW 5-class AI model...');
      final result = await _sendToIgniteXAPI(imageBytes);
      
      print('✅ IgniteX AI Analysis Complete');
      return result;
      
    } catch (e) {
      print('❌ IgniteX AI analysis failed: $e');
      return {
        'success': false,
        'detected_issue': null,
        'ai_department': null,
        'confidence': 0.0,
        'message': 'IgniteX AI analysis failed: $e',
        'requires_manual_selection': true,
        'is_ignitex_api_error': true,
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

  /// ✅ Send image to NEW IgniteX AI Model
  static Future<Map<String, dynamic>> _sendToIgniteXAPI(Uint8List imageBytes) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Add headers
      request.headers['x-api-key'] = _apiKey;
      
      // ✅ NEW MODEL PARAMETERS
      request.fields['model'] = _modelUrl;
      request.fields['imgsz'] = '640';
      request.fields['conf'] = '0.25'; // Ultralytics will detect at 25%, we filter at 75% later
      request.fields['iou'] = '0.45';
      
      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'ignitex_civic_image.jpg',
        ),
      );
      
      print('📤 IgniteX: Sending request to NEW 5-class model...');
      
      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      
      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📨 IgniteX API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return _processIgniteXAPIResponse(jsonResponse);
      } else {
        throw Exception('IgniteX API request failed: HTTP ${response.statusCode}\nBody: ${response.body}');
      }
      
    } catch (e) {
      throw Exception('IgniteX API request failed: $e');
    }
  }

  /// ✅ Process API response with 75% confidence threshold
  static Map<String, dynamic> _processIgniteXAPIResponse(Map<String, dynamic> apiResponse) {
    try {
      print('🔄 IgniteX: Processing NEW model AI response...');
      print('📊 IgniteX Raw response keys: ${apiResponse.keys.join(', ')}');
      
      // Check if response has images
      final images = apiResponse['images'] as List<dynamic>? ?? [];
      if (images.isEmpty) {
        return _createNoDetectionResult('No images in IgniteX AI response');
      }
      
      final firstImage = images[0] as Map<String, dynamic>;
      final results = firstImage['results'] as List<dynamic>? ?? [];
      
      print('📊 IgniteX: Found ${results.length} detections from NEW model');
      
      if (results.isEmpty) {
        return _createNoDetectionResult('No civic issues detected by IgniteX AI');
      }
      
      // ✅ Find best detection with 75% confidence threshold
      Map<String, dynamic>? bestDetection;
      double highestConfidence = 0.0;
      String? detectedClass;
      
      for (var detection in results) {
        final className = (detection['name'] ?? '').toString().toLowerCase();
        final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;
        
        print('🔍 IgniteX Detection: $className (${(confidence * 100).toStringAsFixed(1)}%)');
        
        // Check if it matches our 5 civic issue classes
        if (_classToIssueType.containsKey(className) && confidence > highestConfidence) {
          highestConfidence = confidence;
          bestDetection = detection;
          detectedClass = className;
          
          print('✅ IgniteX Best match so far: $className (${(confidence * 100).toStringAsFixed(1)}%)');
        }
      }
      
      // ✅ CRITICAL: 75% confidence threshold check
      const double MIN_CONFIDENCE = 0.75; // 75% threshold
      
      if (bestDetection == null) {
        return _createNoDetectionResult('No civic issue detected above IgniteX confidence threshold');
      }
      
      if (highestConfidence < MIN_CONFIDENCE) {
        print('⚠️ IgniteX: Confidence ${(highestConfidence * 100).toStringAsFixed(1)}% is below 75% threshold');
        return _createLowConfidenceResult(detectedClass!, highestConfidence, bestDetection);
      }
      
      return _createIgniteXSuccessResult(detectedClass!, highestConfidence, bestDetection, results);
      
    } catch (e) {
      print('❌ Error processing IgniteX AI response: $e');
      return _createNoDetectionResult('Failed to process IgniteX AI response: $e');
    }
  }

  /// ✅ Create successful detection result (>=75% confidence)
  static Map<String, dynamic> _createIgniteXSuccessResult(
    String detectedClass, 
    double confidence, 
    Map<String, dynamic> detection,
    List<dynamic> allResults,
  ) {
    final issueType = _classToIssueType[detectedClass]!;
    final department = _issueToDepartment[issueType]!;
    
    print('🎯 IGNITEX AI HIGH CONFIDENCE DETECTION: $issueType (${(confidence * 100).toStringAsFixed(1)}%)');
    print('🏢 IgniteX Department Assignment: $department');
    print('✅ IgniteX: Confidence meets 75% threshold - Auto-selecting');
    
    return {
      'success': true,
      'detected_issue': issueType,
      'ai_department': department,
      'confidence': confidence,
      'message': '🎯 HIGH CONFIDENCE IGNITEX AI DETECTION (≥75%)',
      'requires_manual_selection': false, // ✅ Auto-select because >=75%
      'is_ignitex_ai': true,
      'detection_metadata': {
        'model': 'IgniteX Custom 5-Class YOLO Model',
        'api_endpoint': _apiUrl,
        'detected_class': detectedClass,
        'raw_detection': detection,
        'total_detections': allResults.length,
        'processing': 'IgniteX Cloud-based YOLO Inference',
        'ai_engine': 'IgniteX Computer Vision Platform',
        'model_version': 'v2.0-5class',
      },
      'technical_details': {
        'confidence_threshold': '75%',
        'detection_confidence': '${(confidence * 100).toStringAsFixed(1)}%',
        'image_size': '640x640',
        'model_type': 'IgniteX YOLOv8 Custom 5-Class',
        'api_version': 'IgniteX AI Platform v2.0',
        'processing_engine': 'Advanced Computer Vision by IgniteX',
        'all_detections': allResults,
        'classes_trained': ['drainage', 'garbage', 'pothole', 'streetlight', 'waterleak'],
      },
    };
  }

  /// ✅ Create low confidence result (<75%) - requires manual selection
  static Map<String, dynamic> _createLowConfidenceResult(
    String detectedClass,
    double confidence,
    Map<String, dynamic> detection,
  ) {
    final issueType = _classToIssueType[detectedClass]!;
    final department = _issueToDepartment[issueType]!;
    
    print('📊 IGNITEX AI LOW CONFIDENCE: $issueType (${(confidence * 100).toStringAsFixed(1)}%)');
    print('⚠️ IgniteX: Below 75% threshold - Requires manual selection');
    
    return {
      'success': true, // Detection was made, but low confidence
      'detected_issue': issueType, // Show suggestion
      'ai_department': department, // Show suggested department
      'confidence': confidence,
      'message': '⚠️ LOW CONFIDENCE (${(confidence * 100).toStringAsFixed(1)}%) - Please verify and select manually',
      'requires_manual_selection': true, // ✅ Must select manually because <75%
      'is_ignitex_ai': true,
      'low_confidence_warning': true,
      'detection_metadata': {
        'model': 'IgniteX Custom 5-Class YOLO Model',
        'detected_class': detectedClass,
        'raw_detection': detection,
        'reason': 'Confidence below 75% threshold',
        'suggested_issue': issueType,
        'model_version': 'v2.0-5class',
      },
    };
  }

  /// Create no detection result with IgniteX branding
  static Map<String, dynamic> _createNoDetectionResult(String reason) {
    print('ℹ️ IgniteX: No detection - $reason');
    
    return {
      'success': false,
      'detected_issue': null,
      'ai_department': null,
      'confidence': 0.0,
      'message': 'IgniteX AI: $reason - Please select manually',
      'requires_manual_selection': true,
      'is_ignitex_ai': true,
      'detection_metadata': {
        'reason': reason,
        'model_version': 'v2.0-5class',
      },
    };
  }

  /// Get department for issue type (including Road Crack)
  static String getDepartmentForIssue(String issueType) {
    return _issueToDepartment[issueType] ?? 'Municipal Services Department';
  }

  /// ✅ Check if result has HIGH confidence (>=75%)
  static bool isHighConfidence(Map<String, dynamic> result) {
    final confidence = result['confidence'] as double? ?? 0.0;
    return confidence >= 0.75 && result['success'] == true; // ✅ 75% threshold
  }

  /// Test IgniteX AI connectivity
  static Future<bool> testAPIConnection() async {
    try {
      print('🔍 Testing IgniteX AI connectivity (NEW 5-class model)...');
      
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'x-api-key': _apiKey},
      ).timeout(const Duration(seconds: 10));
      
      print('✅ IgniteX AI connectivity test: ${response.statusCode}');
      return response.statusCode == 200;
      
    } catch (e) {
      print('❌ IgniteX AI connectivity test failed: $e');
      return false;
    }
  }

  /// ✅ Get list of all available issue types (including manual Road Crack)
  static List<String> getAllIssueTypes() {
    return [
      'Pothole',
      'Streetlight Broken',
      'Garbage Pile',
      'Water Leak',
      'Drainage Overflow',
      'Road Crack', // Manual selection only - not in AI model
    ];
  }

  /// ✅ Check if an issue type is AI-detectable
  static bool isAIDetectable(String issueType) {
    return _classToIssueType.values.contains(issueType);
  }
}
