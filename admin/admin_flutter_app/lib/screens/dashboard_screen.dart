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
                onPressed: () async => await authService.signOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border:
                  const Border(right: BorderSide(color: Colors.grey, width: 1)),
            ),
            child: Column(
              children: [
                _buildSidebarSection('Issues', Icons.assignment,
                    ['New', 'In Progress', 'Resolved', 'Escalated']),
                _buildSidebarSection('Analytics', Icons.analytics,
                    ['Response Time', 'Resolution Rate', 'Satisfaction']),
                _buildSidebarSection('Insights', Icons.lightbulb,
                    ['Peak Hours', 'Common Issue', 'Hotspot']),
                _buildSidebarSection('Predictions', Icons.trending_up,
                    ['Next Week', 'Risk Areas']),
                _buildSidebarSection(
                    'Officers', Icons.people, ['John Smith', 'Sarah Johnson']),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DataService>(
              builder: (context, dataService, child) {
                if (dataService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (dataService.error != null) {
                  return Center(child: Text('Error: ${dataService.error}'));
                }
                if (dataService.data.isEmpty) {
                  return const Center(child: Text('No issues found'));
                }

                return ListView.builder(
                  itemCount: dataService.data.length,
                  itemBuilder: (context, index) {
                    final issue = dataService.data[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: issue['urgency'] == 'High'
                              ? Colors.red
                              : Colors.orange,
                          child: Text(
                              '${issue['count']}'), // number of grouped complaints
                        ),
                        title: Text(
                            "${issue['issue_type']} (${issue['count']} reports)"),
                        subtitle: Text(
                          "Location: ${issue['latitude']}, ${issue['longitude']}\n${issue['description']}",
                        ),
                        trailing: Chip(
                          label: Text(issue['status']),
                          backgroundColor: issue['status'] == 'Resolved'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items.map((item) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              Text(item, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
