import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/product/common/search_app_bar_title.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class SearchEmptyScreen extends StatelessWidget {
  const SearchEmptyScreen({
    required this.name,
    required this.emptiness,
    this.actions,
    Key? key,
  }) : super(key: key);

  final String name;
  final Widget emptiness;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SmoothBackButton(),
        title: SearchAppBarTitle(
          title: name,
          editableAppBarTitle: false,
        ),
        actions: actions,
      ),
      body: Center(child: emptiness),
    );
  }
}
