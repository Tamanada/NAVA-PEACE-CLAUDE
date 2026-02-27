import 'package:flutter/material.dart';

/// Navigation item configuration for bottom navigation bar
enum BottomNavItem { homeHome, worldMap, market, me }

/// Custom bottom navigation bar widget for NAVA PEACE app
/// Implements reorganized navigation with Home-Home, World Map, Market, Me tabs
class CustomBottomBar extends StatelessWidget {
  /// Current selected navigation item
  final BottomNavItem currentItem;

  /// Callback when navigation item is tapped
  final ValueChanged<BottomNavItem> onItemSelected;

  /// Optional notification badge count for specific items
  final Map<BottomNavItem, int>? badgeCounts;

  /// Whether to show labels under icons
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
    this.badgeCounts,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                item: BottomNavItem.homeHome,
                icon: Icons.touch_app_rounded,
                label: 'Home',
                route: '/dashboard-screen',
              ),
              _buildNavItem(
                context: context,
                item: BottomNavItem.worldMap,
                icon: Icons.public_rounded,
                label: 'World Map',
                route: '/map-home-screen',
              ),
              _buildNavItem(
                context: context,
                item: BottomNavItem.market,
                icon: Icons.shopping_bag_rounded,
                label: 'Market',
                route: '/referral-management-screen',
              ),
              _buildNavItem(
                context: context,
                item: BottomNavItem.me,
                icon: Icons.person_rounded,
                label: 'Me',
                route: '/profile-settings-screen',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required BottomNavItem item,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentItem == item;
    final badgeCount = badgeCounts?[item] ?? 0;
    final hasBadge = badgeCount > 0;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              onItemSelected(item);
              Navigator.pushReplacementNamed(context, route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with optional badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // Notification badge
                    if (hasBadge)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Label
                if (showLabels) ...[
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to provide easy access to bottom bar from any screen
extension BottomBarNavigation on BuildContext {
  /// Navigate to a specific bottom bar item
  void navigateToBottomBarItem(BottomNavItem item) {
    final route = switch (item) {
      BottomNavItem.homeHome => '/dashboard-screen',
      BottomNavItem.worldMap => '/map-home-screen',
      BottomNavItem.market => '/referral-management-screen',
      BottomNavItem.me => '/profile-settings-screen',
    };
    Navigator.pushReplacementNamed(this, route);
  }
}
