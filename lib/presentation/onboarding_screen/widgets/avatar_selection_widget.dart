import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AvatarSelectionWidget extends StatelessWidget {
  final String selectedAvatar;
  final List<String> avatarOptions;
  final Map<String, IconData> avatarIcons;
  final ValueChanged<String> onAvatarSelected;

  const AvatarSelectionWidget({
    super.key,
    required this.selectedAvatar,
    required this.avatarOptions,
    required this.avatarIcons,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1,
      ),
      itemCount: avatarOptions.length,
      itemBuilder: (context, index) {
        final avatar = avatarOptions[index];
        final isSelected = selectedAvatar == avatar;

        return InkWell(
          onTap: () => onAvatarSelected(avatar),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF91A13F)
                  : const Color(0xFFF7F7F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF91A13F)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  avatarIcons[avatar],
                  size: 40,
                  color: isSelected ? Colors.white : const Color(0xFF91A13F),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  avatar.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
