import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';
import 'issue_detection_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Initialize camera controller with back camera
        _cameraController = CameraController(
          _cameras!.first, // Use first camera (usually back camera)
          ResolutionPreset.medium,
          enableAudio: false,
        );
        
        // Initialize the controller
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      // Handle camera initialization error
      _showCameraError();
    }
  }

  void _showCameraError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera not available. Please check permissions.'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Add a small delay to show capture feedback
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to issue detection screen (continuing existing flow)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IssueDetectionScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      // Get the next camera
      final currentIndex = _cameras!.indexOf(_cameraController!.description);
      final nextIndex = (currentIndex + 1) % _cameras!.length;
      
      // Dispose current controller
      await _cameraController?.dispose();
      
      // Initialize new camera
      _cameraController = CameraController(
        _cameras![nextIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Civic Issue'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cameras != null && _cameras!.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview or placeholder
          Positioned.fill(
            child: _isCameraInitialized && _cameraController != null
                ? CameraPreview(_cameraController!)
                : Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Initializing Camera...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          
          // Camera overlay with guide lines
          if (_isCameraInitialized)
            Positioned.fill(
              child: CustomPaint(
                painter: CameraOverlayPainter(),
              ),
            ),
          
          // Top instruction overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📷 Point camera at civic issue and tap capture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _captureImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCapturing 
                            ? AppColors.primaryOrange 
                            : AppColors.primaryBlue,
                        boxShadow: [
                          BoxShadow(
                            color: _isCapturing 
                                ? AppColors.primaryOrange.withOpacity(0.4)
                                : AppColors.primaryBlue.withOpacity(0.4),
                            spreadRadius: 4,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isCapturing
                          ? const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 35,
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _isCapturing ? 'Capturing...' : 'Tap to Capture',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Gallery button (optional)
          Positioned(
            bottom: 60,
            left: 30,
            child: GestureDetector(
              onTap: () {
                // Simulate gallery selection and go to detection
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IssueDetectionScreen(),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }
}

// Custom painter for camera overlay guide lines
class CameraOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw center rectangle guide
    const margin = 60.0;
    final rect = Rect.fromLTRB(
      margin,
      size.height * 0.3,
      size.width - margin,
      size.height * 0.7,
    );
    
    // Draw corner indicators
    const cornerLength = 30.0;
    
    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      paint,
    );
    
    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );
    
    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );
    
    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
