class Complaint {
  final String id;
  final String issueType;
  final String department;
  final String urgency;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime reportedDate;
  final String imagePath;

  Complaint({
    required this.id,
    required this.issueType,
    required this.department,
    required this.urgency,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.reportedDate,
    required this.imagePath,
  });
}
