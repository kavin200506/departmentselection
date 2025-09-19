import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';
import '../services/report_service.dart';
import 'confirm_report_screen.dart'; // <-- NEW, you'll add this file

// ... (all imports remain the same)

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  XFile? _capturedImage;
  String _issueType = '';
  String _department = '';
  String _urgency = '';
  String _description = '';

  // For location
  bool _isFetchingLocation = false;
  String? _address;
  double? _latitude;
  double? _longitude;
  String? _locationError;

  final _formKey = GlobalKey<FormState>();
  AnimationController? _fadeInController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fadeInController =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeInController?.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          _fadeInController?.forward(from: 0);
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
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
    setState(() => _isCapturing = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
        _isCapturing = false;
      });
      await _fetchLocation();
    } catch (e) {
      print('Error capturing image: $e');
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _address = null;
      _locationError = null;
      _latitude = null;
      _longitude = null;
    });
    try {
      final loc = await ReportService.getCurrentLocation();
      setState(() {
        _address = loc["address"];
        _latitude = loc["latitude"];
        _longitude = loc["longitude"];
        _isFetchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to fetch location';
        _isFetchingLocation = false;
      });
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    try {
      final currentIndex = _cameras!.indexOf(_cameraController!.description);
      final nextIndex = (currentIndex + 1) % _cameras!.length;
      await _cameraController?.dispose();
      _cameraController = CameraController(
        _cameras![nextIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _fadeInController?.dispose();
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
      body: _capturedImage == null
          ? _coolCameraUI()
          : _modernReportFormUI(),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _coolCameraUI() {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeInController!,
          child: _isCameraInitialized && _cameraController != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CameraPreview(_cameraController!),
                )
              : Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                        SizedBox(height: 16),
                        Text(
                          'Initializing Camera...',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16, letterSpacing: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isCapturing ? 78 : 100,
                height: _isCapturing ? 78 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _isCapturing
                        ? [AppColors.primaryOrange, Colors.orange.withOpacity(0.2)]
                        : [AppColors.primaryBlue, Colors.blueAccent.withOpacity(0.12)],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: _isCapturing
                            ? AppColors.primaryOrange.withOpacity(0.5)
                            : AppColors.primaryBlue.withOpacity(0.32),
                        blurRadius: 16)
                  ],
                ),
                child: _isCapturing
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 4)
                    : Icon(Icons.camera_alt,
                        color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modernReportFormUI() {
    return Container(
      alignment: Alignment.center,
      color: Colors.black.withOpacity(0.05),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Center(
            child: Container(
              width: 420,
              constraints: const BoxConstraints(maxWidth: 480),
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 2)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_capturedImage!.path), height: 160),
                    ),
                    const SizedBox(height: 16),
                    // Location badge/glass panel
                    Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        child: _isFetchingLocation
                            ? Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeInOut,
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryBlue.withOpacity(0.37),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Fetching location...",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.09
                                    ),
                                  ),
                                ],
                              )
                            : _locationError != null
                                ? Row(
                                    children: [
                                      Icon(Icons.error, color: Colors.red[200]),
                                      const SizedBox(width: 8),
                                      Text(_locationError!, style: const TextStyle(color: Colors.red)),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Icon(Icons.my_location, color: AppColors.primaryBlue),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _address ?? "Unknown location",
                                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _modernDropdown('Issue Category', _issueType, DummyData.issueTypes,
                        (val) => setState(() => _issueType = val)),
                    const SizedBox(height: 10),
                    _modernDropdown('Department', _department, DummyData.departments,
                        (val) => setState(() => _department = val)),
                    const SizedBox(height: 10),
                    _modernDropdown('Urgency', _urgency, DummyData.urgencyLevels,
                        (val) => setState(() => _urgency = val)),
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (val) => setState(() => _description = val),
                      maxLines: 3,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.blueGrey[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.blueGrey.withOpacity(0.045),
                        helperText: 'Describe the issue in detail...',
                        helperStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retake'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: AppColors.primaryBlue,
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() => _capturedImage = null);
                          },
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Review & Confirm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate() &&
                                  !_isFetchingLocation &&
                                  _address != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConfirmReportScreen(
                                      image: File(_capturedImage!.path),
                                      issueType: _issueType,
                                      department: _department,
                                      urgency: _urgency,
                                      description: _description,
                                      address: _address ?? "Unknown location",
                                      latitude: _latitude ?? 0,
                                      longitude: _longitude ?? 0,
                                      onEdit: () {
                                        Navigator.pop(context);
                                      },
                                      onSubmit: () {
                                        setState(() {
                                          _capturedImage = null;
                                          _issueType = '';
                                          _department = '';
                                          _urgency = '';
                                          _description = '';
                                          _address = null;
                                          _latitude = null;
                                          _longitude = null;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernDropdown(String label, String value, List<String> options, Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value.isNotEmpty ? value : null,
      onChanged: (val) => onChanged(val!),
      items: options
          .map((opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt, style: const TextStyle(fontWeight: FontWeight.w500)),
              ))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.blueGrey.withOpacity(0.045),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Please select $label.toLowerCase()' : null,
    );
  }
}

// (keep custom painter code unchanged)

