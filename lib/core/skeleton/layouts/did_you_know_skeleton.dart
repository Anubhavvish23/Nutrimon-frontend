import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/skeleton_shimmer.dart';

class DidYouKnowSkeleton extends StatelessWidget {
  const DidYouKnowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final skeleton_colors = SkeletonColors.of(context);
    final screen_width = MediaQuery.sizeOf(context).width;

    return SkeletonShimmer(
      colors: skeleton_colors,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: skeleton_colors.base,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  width: 16,
                  height: 16,
                  border_radius: BorderRadius.circular(4),
                  colors: skeleton_colors,
                ),
                const SizedBox(width: 8),
                SkeletonBox(
                  width: 118,
                  height: 12,
                  border_radius: BorderRadius.circular(6),
                  colors: skeleton_colors,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 36,
                  height: 36,
                  border_radius: BorderRadius.circular(18),
                  colors: skeleton_colors,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: double.infinity,
                        height: 14,
                        border_radius: BorderRadius.circular(7),
                        colors: skeleton_colors,
                      ),
                      const SizedBox(height: 8),
                      SkeletonBox(
                        width: screen_width * 0.55,
                        height: 14,
                        border_radius: BorderRadius.circular(7),
                        colors: skeleton_colors,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SkeletonBox(
                    width: index == 0 ? 14 : 8,
                    height: 8,
                    border_radius: BorderRadius.circular(4),
                    colors: skeleton_colors,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
