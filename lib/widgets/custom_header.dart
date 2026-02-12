import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final double height;
  final VoidCallback? onProfilePressed;
  final List<Widget>? actions;

  const CustomHeader({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
    this.onProfilePressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      actions:
          actions ??
          [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            IconButton(
              onPressed:
                  onProfilePressed ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
              icon: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
          ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
