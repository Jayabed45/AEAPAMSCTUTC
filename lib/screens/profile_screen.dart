import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_combined_chart.dart';
import '../controllers/user_controller.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserController>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.user;
          final email = controller.userEmail ?? 'No email';
          final username = email != 'No email' ? email.split('@')[0] : 'User';

          return RefreshIndicator(
            onRefresh: () => controller.loadUserProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: colorScheme.primary
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  _getInitials(
                                    user?.fullName,
                                    user?.username,
                                    email,
                                  ),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                user?.fullName ?? user?.username ?? username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (user?.isVerified ?? false) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.verified,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user?.role ?? ""} • ${user?.organization ?? ""}',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
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
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedIndex = 0),
                              child: _buildTabButton(
                                'Analytics',
                                _selectedIndex == 0,
                                theme,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedIndex = 1),
                              child: _buildTabButton(
                                'Profile Info',
                                _selectedIndex == 1,
                                theme,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:
                        _selectedIndex == 0
                            ? const CombinedProfileChart()
                            : _buildProfileInfo(theme, controller),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(ThemeData theme, UserController controller) {
    final colorScheme = theme.colorScheme;
    final email = controller.userEmail ?? 'No email';
    final username = email != 'No email' ? email.split('@')[0] : 'No username';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow('Email', email, theme),
          Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            height: 24,
          ),
          _buildInfoRow('Username', username, theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, bool isActive, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration:
          isActive
              ? BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              )
              : null,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color:
                isActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String? fullName, String? username, String? email) {
    if (fullName != null &&
        fullName.isNotEmpty &&
        fullName != 'Loading...' &&
        fullName != 'User') {
      List<String> names = fullName.trim().split(' ');
      if (names.length >= 2) {
        if (names[0].isNotEmpty && names[1].isNotEmpty) {
          return (names[0][0] + names[1][0]).toUpperCase();
        }
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    if (username != null &&
        username.isNotEmpty &&
        username != 'User' &&
        username != 'Loading...') {
      return username[0].toUpperCase();
    }
    if (email != null && email.isNotEmpty && email != 'No email') {
      return email[0].toUpperCase();
    }
    return '?';
  }
}
