import 'package:flutter/material.dart';

import '../helpers/analytics_helper.dart';

class TempTestingPage extends StatefulWidget {
  const TempTestingPage({Key? key}) : super(key: key);

  @override
  _TempTestingPageState createState() => _TempTestingPageState();
}

class _TempTestingPageState extends State<TempTestingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text('CLICK'),
          onPressed: () async {
            print(
              await AnalyticsHelper(context).trackStart(),
            );
          },
        ),
      ),
    );
  }
}
