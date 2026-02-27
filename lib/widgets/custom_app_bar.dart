import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types for different screen contexts
enum AppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with back button for navigation
  withBack,

  /// App bar with close button for modal screens
  withClose,

  /// Transparent app bar for overlay contexts
  transparent,

  /// App bar with search functionality
  withSearch,
}

/// Custom app bar widget for gamified token reward app
/// Implements clean, purposeful interface with consistent navigation patterns
/// Supports various contexts from main screens to modal presentations
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String? title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (overrides default back/close button)
  final Widget? leading;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// App bar variant determining style and behavior
  final AppBarVariant variant;

  /// Whether to show elevation shadow
  final bool showElevation;

  /// Custom background color (overrides theme)
  final Color? backgroundColor;

  /// Whether to center the title
  final bool centerTitle;

  /// Callback when back/close button is pressed
  final VoidCallback? onLeadingPressed;

  /// Optional widget to display below the app bar
  final PreferredSizeWidget? bottom;

  /// System UI overlay style for status bar
  final SystemUiOverlayStyle? systemOverlayStyle;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.variant = AppBarVariant.standard,
    this.showElevation = false,
    this.backgroundColor,
    this.centerTitle = true,
    this.onLeadingPressed,
    this.bottom,
    this.systemOverlayStyle,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine background color based on variant
    final effectiveBackgroundColor =
        backgroundColor ??
        (variant == AppBarVariant.transparent
            ? Colors.transparent
            : colorScheme.surface);

    // Determine elevation based on variant and showElevation flag
    final effectiveElevation = variant == AppBarVariant.transparent
        ? 0.0
        : (showElevation ? 2.0 : 0.0);

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      elevation: effectiveElevation,
      centerTitle: centerTitle,
      systemOverlayStyle:
          systemOverlayStyle ??
          (theme.brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: actions,
      bottom: bottom,
      shadowColor: colorScheme.shadow,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case AppBarVariant.withBack:
        return IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
          tooltip: 'Back',
          splashRadius: 24,
        );

      case AppBarVariant.withClose:
        return IconButton(
          icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
          onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
          tooltip: 'Close',
          splashRadius: 24,
        );

      case AppBarVariant.standard:
      case AppBarVariant.transparent:
      case AppBarVariant.withSearch:
        // Check if we can pop
        if (Navigator.of(context).canPop()) {
          return IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
            onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
            tooltip: 'Back',
            splashRadius: 24,
          );
        }
        return null;
    }
  }

  Widget? _buildTitle(BuildContext context) {
    if (title == null && subtitle == null) return null;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (subtitle != null) {
      // Two-line title with subtitle
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // Single-line title
    return Text(
      title!,
      style: theme.textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Pre-configured app bar for dashboard/home screen
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const DashboardAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      variant: AppBarVariant.standard,
      showElevation: false,
      actions: actions,
    );
  }
}

/// Pre-configured app bar for detail/secondary screens
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const DetailAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      subtitle: subtitle,
      variant: AppBarVariant.withBack,
      showElevation: false,
      actions: actions,
      onLeadingPressed: onBackPressed,
    );
  }
}

/// Pre-configured app bar for modal/bottom sheet screens
class ModalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onClosePressed;

  const ModalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onClosePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      variant: AppBarVariant.withClose,
      showElevation: false,
      actions: actions,
      onLeadingPressed: onClosePressed,
    );
  }
}

/// Action button for app bar with consistent styling
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool showBadge;
  final int badgeCount;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          tooltip: tooltip,
          color: colorScheme.onSurface,
          splashRadius: 24,
        ),
        if (showBadge && badgeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
    );
  }
}
