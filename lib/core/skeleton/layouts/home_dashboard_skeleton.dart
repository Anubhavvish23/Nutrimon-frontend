import 'package:flutter/material.dart';
import '../skeleton_responsive.dart';
import 'did_you_know_skeleton.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/skeleton_text.dart';

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontal_padding = SkeletonResponsive.horizontalPadding(context);
    const quick_action_columns = 2;
    final screen_width = MediaQuery.sizeOf(context).width;
    const grid_spacing = 12.0;
    final grid_item_width = ((screen_width -
                horizontal_padding * 2 -
                grid_spacing * (quick_action_columns - 1)) /
            quick_action_columns)
        .clamp(80.0, double.infinity);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontal_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText.title(
                width: screen_width * 0.55,
              ),
              const SizedBox(height: 8),
              SkeletonText.caption(
                width: screen_width * 0.65,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const DidYouKnowSkeleton(),
          const SizedBox(height: 20),
          SkeletonCard(
            height: 88,
            border_radius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 24),
          SkeletonText(
            width: screen_width * 0.35,
            height: 12,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: grid_spacing,
            runSpacing: grid_spacing,
            children: List.generate(
              quick_action_columns * 2,
              (_) {
                final tile_height = (grid_item_width / 1.3).clamp(72.0, 140.0);
                return SizedBox(
                  width: grid_item_width,
                  height: tile_height,
                  child: SkeletonCard(
                    padding: const EdgeInsets.all(12),
                    border_radius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(
                          width: grid_item_width * 0.5,
                          height: 10,
                        ),
                        const Spacer(),
                        SkeletonText(
                          width: grid_item_width * 0.7,
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SkeletonText(
            width: screen_width * 0.45,
            height: 12,
          ),
          const SizedBox(height: 14),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonCard(
                height: 120,
                border_radius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SkeletonCard(
            height: 90,
            border_radius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
