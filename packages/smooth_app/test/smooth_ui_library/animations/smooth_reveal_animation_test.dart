import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class _SwitchablePage extends StatefulWidget {
  const _SwitchablePage({this.delay = 0});

  final int delay;

  @override
  State<_SwitchablePage> createState() => _SwitchablePageState();
}

class _SwitchablePageState extends State<_SwitchablePage> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  late final List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _widgetOptions = <Widget>[
      SmoothRevealAnimation(
        delay: widget.delay,
        child: const Text(
          'Index 0: Home, which has SmoothRevealAnimation',
          style: optionStyle,
        ),
      ),
      const Text(
        'Index 1: Business, which does not have SmoothRevealAnimation',
        style: optionStyle,
      ),
    ];
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: AppBar(title: const Text('Test App')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() {
  // Regression test for https://github.com/openfoodfacts/smooth-app/issues/483
  testWidgets(
    "SmoothRevealAnimation doesn't use AnimationController after dispose",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _SwitchablePage(
            // Set a large delay so that the AnimationController has time to be
            // disposed.
            delay: 1000,
          ),
        ),
      );

      expect(find.byType(SmoothRevealAnimation), findsOneWidget);

      // Move to the page that doesn't have SmoothRevealAnimation.
      await tester.tap(find.text('Business'));
      await tester.pumpAndSettle();
      expect(find.byType(SmoothRevealAnimation), findsNothing);

      // Wait 1 second so the SmoothRevealAnimation delay expires on the previous
      // page.
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );
}
