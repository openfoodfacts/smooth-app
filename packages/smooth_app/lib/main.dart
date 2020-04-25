import 'package:flutter/material.dart';
import 'package:smooth_app/pages/test_page.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_action_model.dart';
import 'package:smooth_ui_library/navigation/smooth_navigation_layout.dart';

void main() => runApp(SmoothApp());

class SmoothApp extends StatelessWidget {
  final SmoothNavigationLayoutModel layout = generateTestLayoutModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmoothNavigationLayout(
        layout: layout,
        //animationDuration: 400,
        //animationCurve: Curves.elasticInOut,
        //color: Colors.black54,
        //textColor: Colors.white,
        //borderRadius: 15.0,
        //reverseLayout: true,
      ),
    );
  }

  static SmoothNavigationLayoutModel generateTestLayoutModel() {
    return SmoothNavigationLayoutModel(
      screens: <SmoothNavigationScreenModel>[
        SmoothNavigationScreenModel(
          icon: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: Colors.greenAccent),
          ),
          page: TestPage(Colors.greenAccent),
          action: SmoothNavigationActionModel(
            icon: Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.greenAccent),
            ),
            onTap: () {
              print('Test');
            },
            title: 'Green main action',
          ),
        ),
        SmoothNavigationScreenModel(
          icon: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: Colors.yellow),
          ),
          page: TestPage(Colors.yellow),
        ),
        SmoothNavigationScreenModel(
          icon: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: Colors.redAccent),
          ),
          page: TestPage(Colors.redAccent),
          action: SmoothNavigationActionModel(
            icon: Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.redAccent),
            ),
            onTap: () {
              print('Test');
            },
            title: 'Red main action',
          ),
        ),
      ],
    );
  }
}
