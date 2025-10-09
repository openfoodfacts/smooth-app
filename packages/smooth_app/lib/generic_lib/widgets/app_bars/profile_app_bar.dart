import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_background.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/search_bottom_bar.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({
    required this.contentHeight,
    required this.progressOffset,
    required this.title,
    required this.content,
    super.key,
  });

  final Widget title;
  final Widget content;
  final double contentHeight;

  // TODO(g123k): Improve this
  final double progressOffset;

  @override
  Widget build(BuildContext context) {
    final double minHeight =
        MediaQuery.viewPaddingOf(context).top +
        (Platform.isAndroid ? VERY_SMALL_SPACE : 0.0) +
        PROFILE_PICTURE_SIZE +
        MEDIUM_SPACE +
        SEARCH_BOTTOM_HEIGHT;

    final double maxHeight = minHeight + LARGE_SPACE + contentHeight;

    return SliverPersistentHeader(
      delegate: _ProfileAppBarDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
        progressOffset: progressOffset,
        title: title,
        content: content,
      ),
      pinned: true,
      floating: true,
    );
  }
}

class _ProfileAppBarDelegate extends SliverPersistentHeaderDelegate {
  const _ProfileAppBarDelegate({
    required this.title,
    required this.content,
    required this.progressOffset,
    required this.minHeight,
    required this.maxHeight,
  }) : assert(minHeight >= 0.0),
       assert(maxHeight >= 0.0);

  final Widget title;
  final Widget content;
  final double minHeight;
  final double maxHeight;
  final double progressOffset;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = (shrinkOffset / (minHeight - progressOffset)).clamp(
      0.0,
      1.0,
    );

    return SizedBox(
      height: maxHeight,
      child: AppBarBackground(
        scrollOffset: progress * (maxHeight - minHeight),
        bodyHeight: maxHeight - SEARCH_BOTTOM_HEIGHT,
        minHeight: minHeight,
        maxHeight: maxHeight,
        footerHeight: SEARCH_BOTTOM_HEIGHT,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: MediaQuery.viewPaddingOf(context).top,
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
              ),
              child: Column(
                children: <Widget>[
                  if (Platform.isAndroid)
                    const SizedBox(height: VERY_SMALL_SPACE),
                  title,
                  Offstage(
                    offstage: progress == 1.0,
                    child: Opacity(
                      opacity: 1.0 - progress,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16.0),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: 1.0 - progress,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              top: LARGE_SPACE,
                            ),
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            SearchBottomBar(),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileAppBarDelegate oldDelegate) =>
      title != oldDelegate.title ||
      content != oldDelegate.content ||
      progressOffset != oldDelegate.progressOffset ||
      minHeight != oldDelegate.minHeight ||
      maxHeight != oldDelegate.maxHeight;
}
