/*import 'package:flutter/material.dart';
import 'package:example/pages/test_page.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';
import 'package:smooth_ui_library/navigation/smooth_navigation_layout.dart';

void main() => runApp(SmoothUILibraryExample());

class SmoothUILibraryExample extends StatelessWidget {
  final SmoothNavigationLayoutModel layout = generateTestLayoutModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmoothNavigationLayout(
        layout: layout,
        animationDuration: 200,
        animationCurve: Curves.easeInOutBack,
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
            decoration: const BoxDecoration(
                borderRadius:  BorderRadius.all(Radius.circular(10.0)),
                color: Colors.greenAccent),
          ),
          page: const TestPage(Colors.greenAccent),
        ),
        SmoothNavigationScreenModel(
          icon: Container(
            width: 20.0,
            height: 20.0,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Colors.yellow),
          ),
          page: const TestPage(Colors.yellow),
        ),
        SmoothNavigationScreenModel(
          icon: Container(
            width: 20.0,
            height: 20.0,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Colors.redAccent),
          ),
          page: const TestPage(Colors.redAccent),
        ),
      ],
    );
  }
}*/
