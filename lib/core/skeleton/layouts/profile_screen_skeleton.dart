import 'package:flutter/material.dart';
import '../skeleton_responsive.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/skeleton_circle_avatar.dart';
import '../widgets/skeleton_image.dart';
import '../widgets/skeleton_list_tile.dart';
import '../widgets/skeleton_text.dart';
import '../widgets/skeleton_box.dart';

class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontal_padding = SkeletonResponsive.horizontalPadding(context);
    final screen_width = MediaQuery.sizeOf(context).width;
    final is_tablet = SkeletonResponsive.isTablet(context);
    final avatar_radius = is_tablet ? 56.0 : 48.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontal_padding),
      child: Column(
        children: [
          const SizedBox(height: 32),
          SkeletonCircleAvatar(radius: avatar_radius),
          const SizedBox(height: 16),
          SkeletonText.title(width: screen_width * 0.4),
          const SizedBox(height: 8),
          SkeletonText.caption(width: screen_width * 0.55),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (_) => Column(
                children: [
                  SkeletonText(
                    width: 40,
                    height: 20,
                  ),
                  const SizedBox(height: 6),
                  SkeletonText.caption(width: 56),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SkeletonBox(
            width: double.infinity,
            height: 44,
            border_radius: BorderRadius.circular(22),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonText(
              width: screen_width * 0.3,
              height: 12,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: is_tablet ? 140 : 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => SkeletonImage(
                width: is_tablet ? 140 : 110,
                height: is_tablet ? 140 : 110,
                border_radius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonText(
              width: screen_width * 0.35,
              height: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            5,
            (_) => const SkeletonListTile(show_trailing: true),
          ),
          const SizedBox(height: 24),
          SkeletonCard(
            height: 100,
            border_radius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
