import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/product/common/search_app_bar_title.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class SearchEmptyScreen extends StatelessWidget {
  const SearchEmptyScreen({
    required this.name,
    required this.emptiness,
    this.actions,
    this.includeAppBar = true,
    super.key,
  });

  final String name;
  final Widget emptiness;
  final List<Widget>? actions;
  final bool includeAppBar;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: includeAppBar
          ? AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: const SmoothBackButton(),
              title: SearchAppBarTitle(title: name, editableAppBarTitle: false),
              actions: actions,
            )
          : PreferredSize(
              preferredSize: Size(
                double.infinity,
                MediaQuery.viewInsetsOf(context).top,
              ),
              child: const SmoothEmptyAppBar(),
            ),
      body: Center(child: emptiness),
    );
  }
}
