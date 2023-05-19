import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';

class ExternalPage extends StatefulWidget {
  const ExternalPage({required this.path, Key? key})
      : assert(path != ''),
        super(key: key);

  final String path;

  @override
  State<ExternalPage> createState() => _ExternalPageState();
}

class _ExternalPageState extends State<ExternalPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LaunchUrlHelper.launchURL(
        path.join('https://world.openfoodfacts.org', widget.path),
        false,
      );

      if (mounted) {
        AppNavigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
