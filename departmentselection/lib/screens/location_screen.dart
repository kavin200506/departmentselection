import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/constants.dart';
import 'status_tracker_screen.dart';

class LocationScreen extends StatefulWidget {
  final String issueType;
  final String department;
  final String urgency;
  final String description;

  const LocationScreen({
    super.key,
    required this.issueType,
    required this.department,
    required this.urgency,
    required this.description,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _address = '';
  bool _isLoadingLocation = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionPermanentlyDeniedDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get address from coordinates (reverse geocoding)
      await _getAddressFromCoordinates();

      setState(() {
        _isLoadingLocation = false;
        _locationPermissionGranted = true;
      });

    } catch (e) {
      print('Error getting location: $e');
      _showLocationError();
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude,
        _longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _address = '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      } else {
        _address = 'Address not found';
      }
    } catch (e) {
      print('Error getting address: $e');
      _address = 'Unable to get address';
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to use this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isLoadingLocation = false;
                });
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('This app needs location access to report civic issues accurately.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isLoadingLocation = false;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isLoadingLocation = false;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationError() {
    setState(() {
      _isLoadingLocation = false;
      _address = 'Error getting location';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to get current location. Please try again.'),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Confirm Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complaint Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const Divider(),
                  _buildSummaryRow(Icons.construction, 'Issue', widget.issueType),
                  _buildSummaryRow(Icons.business, 'Department', widget.department),
                  _buildSummaryRow(Icons.priority_high, 'Urgency', widget.urgency),
                  if (widget.description.isNotEmpty)
                    _buildSummaryRow(Icons.description, 'Description', widget.description),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Location Section
            Row(
              children: [
                const Text(
                  'Location Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                const Spacer(),
                if (_locationPermissionGranted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          size: 14,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Live GPS',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Map Placeholder with GPS indicator
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isLoadingLocation
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryBlue),
                            SizedBox(height: 16),
                            Text(
                              'Getting your GPS location...',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please ensure location services are enabled',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          // Map placeholder with GPS pattern
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryBlue.withOpacity(0.1),
                                  AppColors.primaryGreen.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              painter: GPSMapPainter(),
                              size: const Size(double.infinity, 200),
                            ),
                          ),
                          // Live location pin
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withOpacity(0.3),
                                        spreadRadius: 4,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Your Current Location',
                                    style: TextStyle(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Coordinates overlay
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Address Details with GPS info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primaryRed),
                      const SizedBox(width: 8),
                      const Text(
                        'Current Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const Spacer(),
                      if (_locationPermissionGranted)
                        Icon(
                          Icons.verified,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoadingLocation ? 'Loading address...' : _address,
                    style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.gps_fixed, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      const Text(
                        'GPS Coordinates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoadingLocation 
                        ? 'Getting GPS coordinates...'
                        : 'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_locationPermissionGranted)
                    Text(
                      'Accuracy: High GPS',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: Icon(_isLoadingLocation ? Icons.hourglass_empty : Icons.refresh),
                    label: Text(_isLoadingLocation ? 'Loading...' : 'Update Location'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      foregroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation || !_locationPermissionGranted
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StatusTrackerScreen(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.send),
                    label: const Text('Submit with GPS Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.darkGrey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for GPS map visualization
class GPSMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw GPS grid pattern
    for (double x = 0; x <= size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y <= size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw GPS accuracy circle
    final centerPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
