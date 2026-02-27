import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying device ID with copy functionality
class DeviceIdFieldWidget extends StatelessWidget {
  final String deviceId;
  final VoidCallback onCopy;

  const DeviceIdFieldWidget({
    super.key,
    required this.deviceId,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device ID',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outline, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  deviceId.isEmpty ? 'Generating...' : deviceId,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: deviceId.isEmpty
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: deviceId.isEmpty ? null : onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(1.5.w),
                    child: CustomIconWidget(
                      iconName: 'content_copy',
                      size: 5.w,
                      color: deviceId.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'This unique ID identifies your device',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
