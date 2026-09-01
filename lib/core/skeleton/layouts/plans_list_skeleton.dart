import 'package:flutter/material.dart';
import '../skeleton_responsive.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/skeleton_list_tile.dart';
import '../widgets/skeleton_staggered_list.dart';
import '../widgets/skeleton_text.dart';
import '../widgets/skeleton_box.dart';

class PlansListSkeleton extends StatelessWidget {
  final int item_count;

  const PlansListSkeleton({
    super.key,
    this.item_count = 4,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal_padding = SkeletonResponsive.horizontalPadding(context);
    final cross_axis_count = SkeletonResponsive.gridCrossAxisCount(context);
    final screen_width = MediaQuery.sizeOf(context).width;
    final grid_spacing = 12.0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal_padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText.title(width: screen_width * 0.45),
                    SkeletonBox(
                      width: 100,
                      height: 36,
                      border_radius: BorderRadius.circular(20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SkeletonCard(
                  height: 180,
                  border_radius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 24),
                SkeletonText(
                  width: screen_width * 0.25,
                  height: 12,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      7,
                      (_) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SkeletonBox(
                          width: 64,
                          height: 72,
                          border_radius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SkeletonText(
                  width: screen_width * 0.4,
                  height: 12,
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontal_padding),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, __) => SkeletonCard(
                border_radius: BorderRadius.circular(20),
              ),
              childCount: item_count,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross_axis_count,
              crossAxisSpacing: grid_spacing,
              mainAxisSpacing: grid_spacing,
              childAspectRatio: 0.78,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal_padding),
            child: SkeletonBox(
              width: double.infinity,
              height: 52,
              border_radius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class ListScreenSkeleton extends StatelessWidget {
  final int item_count;

  const ListScreenSkeleton({
    super.key,
    this.item_count = 8,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal_padding = SkeletonResponsive.horizontalPadding(context);

    return SkeletonStaggeredList(
      padding: EdgeInsets.symmetric(horizontal: horizontal_padding),
      item_count: item_count,
      item_builder: (_, __) => const SkeletonListTile(
        show_avatar: true,
        show_trailing: true,
      ),
    );
  }
}
