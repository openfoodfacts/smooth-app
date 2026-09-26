import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomePageListContainer extends StatelessWidget {
  const HomePageListContainer({
    required this.title,
    this.onTap,
    this.sliver,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? sliver;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 20.0,
              bottom: 10.0,
              start: 24.0,
              end: 24.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ?sliver,
      ],
    );
  }
}
