import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'john.doe@email.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '+91 9876543210',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Active Citizen',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total\nComplaints',
                    '15',
                    AppColors.primaryBlue,
                    Icons.report,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Resolved',
                    '12',
                    AppColors.primaryGreen,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Points\nEarned',
                    '240',
                    AppColors.primaryOrange,
                    Icons.star,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Menu Items
            _buildMenuSection([
              {
                'icon': Icons.person,
                'title': 'Edit Profile',
                'subtitle': 'Update your personal information',
                'onTap': () {},
              },
              {
                'icon': Icons.location_on,
                'title': 'Saved Locations',
                'subtitle': 'Manage your frequently used locations',
                'onTap': () {},
              },
              {
                'icon': Icons.notifications,
                'title': 'Notification Settings',
                'subtitle': 'Configure your notification preferences',
                'onTap': () {},
              },
            ]),
            
            const SizedBox(height: 16),
            
            _buildMenuSection([
              {
                'icon': Icons.language,
                'title': 'Language',
                'subtitle': 'English',
                'onTap': () {
                  _showLanguageDialog(context);
                },
              },
              {
                'icon': Icons.dark_mode,
                'title': 'Theme',
                'subtitle': 'Light Mode',
                'onTap': () {},
              },
              {
                'icon': Icons.security,
                'title': 'Privacy & Security',
                'subtitle': 'Manage your privacy settings',
                'onTap': () {},
              },
            ]),
            
            const SizedBox(height: 16),
            
            _buildMenuSection([
              {
                'icon': Icons.help,
                'title': 'Help & Support',
                'subtitle': 'Get help and contact support',
                'onTap': () {},
              },
              {
                'icon': Icons.info,
                'title': 'About',
                'subtitle': 'App version and information',
                'onTap': () {
                  _showAboutDialog(context);
                },
              },
              {
                'icon': Icons.feedback,
                'title': 'Feedback',
                'subtitle': 'Share your feedback with us',
                'onTap': () {},
              },
            ]),
            
            const SizedBox(height: 24),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout, color: AppColors.primaryRed),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primaryRed),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 4),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Map<String, dynamic>> items) {
    return Container(
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
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;
          bool isLast = index == items.length - 1;
          
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  item['icon'],
                  color: AppColors.darkGrey,
                ),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                subtitle: Text(
                  item['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.darkGrey,
                ),
                onTap: item['onTap'],
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey[200],
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio(
                  value: 'en',
                  groupValue: 'en',
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                title: const Text('हिंदी'),
                leading: Radio(
                  value: 'hi',
                  groupValue: 'en',
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                title: const Text('বাংলা'),
                leading: Radio(
                  value: 'bn',
                  groupValue: 'en',
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About CivicHero'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Developed by Team IgniteX'),
              SizedBox(height: 8),
              Text('Smart India Hackathon 2025'),
              SizedBox(height: 16),
              Text(
                'CivicHero helps citizens report civic issues and track their resolution progress.',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
