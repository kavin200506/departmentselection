import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';
import '../data_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataService>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return IconButton(
                onPressed: () async {
                  await authService.signOut();
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Sidebar with sections
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(right: BorderSide(color: Colors.grey, width: 1)),
            ),
            child: Column(
              children: [
                // Issues section
                _buildSidebarSection(
                  'Issues',
                  Icons.assignment,
                  [
                    'New Issues (5)',
                    'In Progress (12)',
                    'Resolved (18)',
                    'Escalated (3)',
                  ],
                ),
                
                // Analytics section
                _buildSidebarSection(
                  'Analytics',
                  Icons.analytics,
                  [
                    'Response Time: 2.3h',
                    'Resolution Rate: 75%',
                    'Satisfaction: 4.2/5',
                    'Trend: +12%',
                  ],
                ),
                
                // Insights section
                _buildSidebarSection(
                  'Insights',
                  Icons.lightbulb,
                  [
                    'Peak Hours: 9-11 AM',
                    'Common Issue: Water Supply',
                    'Hotspot: Sector 5',
                    'Recommendation: Add Staff',
                  ],
                ),
                
                // Predictions section
                _buildSidebarSection(
                  'Predictions',
                  Icons.trending_up,
                  [
                    'Next Week: +15% Issues',
                    'Risk Areas: 3 Identified',
                    'Resource Need: High',
                    'Weather Impact: Moderate',
                  ],
                ),
                
                // Officers section
                _buildSidebarSection(
                  'Officers',
                  Icons.people,
                  [
                    'John Smith - PWD',
                    'Sarah Johnson - Municipal',
                    'Mike Davis - Sanitation',
                    'Lisa Brown - Electricity',
                  ],
                ),
              ],
            ),
          ),
          
          // Right side - Main content
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 48, color: Colors.blue),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${authService.user?.email ?? 'Admin'}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Department: ${authService.user?.displayName ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total Issues', '24', Icons.warning, Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Resolved', '18', Icons.check_circle, Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Pending', '6', Icons.pending, Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent issues
                  const Text(
                    'Recent Issues',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Consumer<DataService>(
                      builder: (context, dataService, child) {
                        if (dataService.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (dataService.error != null) {
                          return Center(
                            child: Text('Error: ${dataService.error}'),
                          );
                        }
                        
                        if (dataService.data.isEmpty) {
                          return const Center(
                            child: Text('No issues found'),
                          );
                        }
                        
                        return ListView.builder(
                          itemCount: dataService.data.length,
                          itemBuilder: (context, index) {
                            final issue = dataService.data[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: issue['priority'] == 'High' ? Colors.red : Colors.orange,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(issue['title'] ?? 'Issue #${issue['id']}'),
                                subtitle: Text(issue['description'] ?? 'No description'),
                                trailing: Chip(
                                  label: Text(issue['status'] ?? 'Pending'),
                                  backgroundColor: issue['status'] == 'Resolved' ? Colors.green.shade100 : Colors.orange.shade100,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSidebarSection(String title, IconData icon, List<String> items) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: const Text('This feature will be available when Firebase is configured.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Text('Edit functionality for ${item['name']} will be available when Firebase is configured.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete functionality for ${item['name']} will be available when Firebase is configured.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
