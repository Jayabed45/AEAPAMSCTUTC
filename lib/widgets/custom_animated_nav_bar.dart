import 'package:flutter/material.dart';

class CustomAnimatedNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<CustomNavBarItem> items;
  final Color? backgroundColor;

  const CustomAnimatedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.backgroundColor,
  });

  @override
  State<CustomAnimatedNavBar> createState() => _CustomAnimatedNavBarState();
}

class _CustomAnimatedNavBarState extends State<CustomAnimatedNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Start from below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
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
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.cardColor;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == widget.selectedIndex;

                  final isLightMode = theme.brightness == Brightness.light;
                  final selectedBgColor = isLightMode
                      ? const Color(0xFF1E2328) // Dark background for light mode
                      : theme.colorScheme.primary.withValues(alpha: 0.2);
                  final selectedContentColor = isLightMode
                      ? Colors.white
                      : theme.colorScheme.primary;

                  return InkWell(
                    onTap: () => widget.onItemSelected(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuad,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 20 : 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? selectedBgColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? (item.selectedIcon ?? item.icon)
                                : item.icon,
                            color: isSelected
                                ? selectedContentColor
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                            size: 24,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: SizedBox(
                              width: isSelected ? null : 0,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: isSelected ? 8 : 0,
                                ),
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: selectedContentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNavBarItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  CustomNavBarItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });
}
