import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import 'skeleton_circle_avatar.dart';
import 'skeleton_text.dart';

class SkeletonListTile extends StatelessWidget {
  final bool show_avatar;
  final bool show_trailing;
  final double vertical_padding;
  final SkeletonAnimationType animation_type;

  const SkeletonListTile({
    super.key,
    this.show_avatar = true,
    this.show_trailing = false,
    this.vertical_padding = 12,
    this.animation_type = SkeletonAnimationType.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    final screen_width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical_padding),
      child: Row(
        children: [
          if (show_avatar) ...[
            SkeletonCircleAvatar(
              radius: 22,
              animation_type: animation_type,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(
                  width: screen_width * 0.45,
                  height: 15,
                  animation_type: animation_type,
                ),
                const SizedBox(height: 8),
                SkeletonText.caption(
                  width: screen_width * 0.3,
                  animation_type: animation_type,
                ),
              ],
            ),
          ),
          if (show_trailing) ...[
            const SizedBox(width: 12),
            SkeletonText(
              width: 48,
              height: 14,
              animation_type: animation_type,
            ),
          ],
        ],
      ),
    );
  }
}
