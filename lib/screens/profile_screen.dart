import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/profile_combined_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings if needed, or just a placeholder
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar & Name
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/300',
                            ), // Placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Fallback icon if image fails
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'System Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.verified, color: AppColors.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Administrator • AEAPAMSCTUTC',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Custom Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton('Analytics', true)),
                    Expanded(child: _buildTabButton('History', false)),
                    Expanded(child: _buildTabButton('System', false)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Analytics Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: const [CombinedProfileChart()]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration:
          isActive
              ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              )
              : null,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? AppColors.background : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
