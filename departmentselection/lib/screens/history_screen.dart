import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';
import '../models/complaint.dart';
import 'status_tracker_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  
  final List<Complaint> _complaints = [
    Complaint(
      id: 'CPT-2025-001234',
      issueType: 'Pothole',
      department: 'Road Department',
      urgency: 'High',
      latitude: 28.6139,
      longitude: 77.2090,
      status: 'In Progress',
      reportedDate: DateTime.now().subtract(const Duration(hours: 2)),
      imagePath: '',
    ),
    Complaint(
      id: 'CPT-2025-001233',
      issueType: 'Streetlight Broken',
      department: 'Electrical Department',
      urgency: 'Medium',
      latitude: 28.6129,
      longitude: 77.2080,
      status: 'Resolved',
      reportedDate: DateTime.now().subtract(const Duration(days: 1)),
      imagePath: '',
    ),
    Complaint(
      id: 'CPT-2025-001232',
      issueType: 'Drainage Overflow',
      department: 'Water & Sewerage',
      urgency: 'Critical',
      latitude: 28.6149,
      longitude: 77.2100,
      status: 'Assigned',
      reportedDate: DateTime.now().subtract(const Duration(days: 3)),
      imagePath: '',
    ),
    Complaint(
      id: 'CPT-2025-001231',
      issueType: 'Garbage Pile',
      department: 'Sanitation Department',
      urgency: 'Low',
      latitude: 28.6159,
      longitude: 77.2110,
      status: 'Resolved',
      reportedDate: DateTime.now().subtract(const Duration(days: 7)),
      imagePath: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Complaint> filteredComplaints = _selectedFilter == 'All' 
        ? _complaints 
        : _complaints.where((c) => c.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Complaint History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.all(16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'In Progress', 'Assigned', 'Resolved'].map((filter) {
                bool isSelected = _selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primaryBlue.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryBlue : AppColors.darkGrey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Statistics Row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _complaints.length.toString(),
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Resolved',
                    _complaints.where((c) => c.status == 'Resolved').length.toString(),
                    AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    _complaints.where((c) => c.status != 'Resolved').length.toString(),
                    AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Complaints List
          Expanded(
            child: filteredComplaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter.toLowerCase()} complaints found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your complaint history will appear here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(filteredComplaints[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    Color statusColor = _getStatusColor(complaint.status);
    IconData issueIcon = _getIssueIcon(complaint.issueType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatusTrackerScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        issueIcon,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.issueType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            complaint.id,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGrey,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        complaint.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: AppColors.darkGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint.department,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.priority_high,
                      size: 14,
                      color: _getUrgencyColor(complaint.urgency),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint.urgency,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getUrgencyColor(complaint.urgency),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.darkGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(complaint.reportedDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.darkGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return AppColors.primaryGreen;
      case 'In Progress':
        return AppColors.primaryOrange;
      case 'Assigned':
        return AppColors.primaryBlue;
      default:
        return AppColors.darkGrey;
    }
  }

  IconData _getIssueIcon(String issueType) {
    switch (issueType) {
      case 'Pothole':
        return Icons.construction;
      case 'Streetlight Broken':
        return Icons.lightbulb_outline;
      case 'Drainage Overflow':
        return Icons.water_drop_outlined;
      case 'Garbage Pile':
        return Icons.delete_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Critical':
        return AppColors.primaryPurple;
      case 'High':
        return AppColors.primaryRed;
      case 'Medium':
        return AppColors.primaryOrange;
      case 'Low':
        return AppColors.primaryGreen;
      default:
        return AppColors.darkGrey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
