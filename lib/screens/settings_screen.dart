import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../controllers/user_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  bool _pauseNotifications = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userController = Provider.of<UserController>(context);
    final user = userController.user;
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardColor = Theme.of(context).cardColor;
    final borderColor =
        isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);
    final iconBgColor =
        isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // User Profile Section
            _buildAnimatedItem(
              _buildProfileSection(
                cardColor,
                borderColor,
                textColor,
                subTextColor,
                iconBgColor,
                user?.fullName ?? 'User',
                user?.email ?? 'No email',
                user?.username ?? 'No username',
              ),
              0,
            ),
            const SizedBox(height: 24),

            // Settings Sections
            _buildAnimatedItem(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Preferences', subTextColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow:
                          isDark
                              ? []
                              : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.notifications_outlined,
                          title: 'Pause notifications',
                          value: _pauseNotifications,
                          onChanged:
                              (value) =>
                                  setState(() => _pauseNotifications = value),
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                          activeTrackColor: AppColors.primary,
                        ),
                        _buildDivider(borderColor),
                        _buildListTile(
                          icon: Icons.tune,
                          title: 'General settings',
                          onTap: () {},
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              1,
            ),
            const SizedBox(height: 24),

            _buildAnimatedItem(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Appearance & Language', subTextColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow:
                          isDark
                              ? []
                              : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark mode',
                          value: isDark,
                          onChanged:
                              (value) => themeProvider.toggleTheme(value),
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                          activeTrackColor: AppColors.primary,
                        ),
                        _buildDivider(borderColor),
                        _buildListTile(
                          icon: Icons.translate,
                          title: 'Language',
                          trailingText: 'English',
                          onTap: () {},
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              2,
            ),
            const SizedBox(height: 24),

            _buildAnimatedItem(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Support', subTextColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow:
                          isDark
                              ? []
                              : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.help_outline,
                          title: 'FAQ',
                          onTap: () {},
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                        ),
                        _buildDivider(borderColor),
                        _buildListTile(
                          icon: Icons.info_outline,
                          title: 'Terms of service',
                          onTap: () {},
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                        ),
                        _buildDivider(borderColor),
                        _buildListTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'User policy',
                          onTap: () {},
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                        ),
                        _buildDivider(borderColor),
                        _buildListTile(
                          icon: Icons.people_outline,
                          title: 'My Contact',
                          onTap: () {},
                          textColor: textColor,
                          iconBgColor: iconBgColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              3,
            ),
            const SizedBox(height: 40),

            // Log Out Button
            _buildAnimatedItem(
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFE35D5B)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              'Log Out',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to log out?',
                              style: GoogleFonts.poppins(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Log Out',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFE53935),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (shouldLogout == true) {
                      await userController.signOut();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              4,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(Widget child, int index) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutQuad),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildProfileSection(
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color? subTextColor,
    Color iconBgColor,
    String name,
    String email,
    String username,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow:
            Theme.of(context).brightness == Brightness.light
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@$username',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(color: subTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit_outlined, color: textColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, color: color, indent: 60, endIndent: 0);
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: textColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                trailingText,
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color iconBgColor,
    required Color activeTrackColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: textColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: activeTrackColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
