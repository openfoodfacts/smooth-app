import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';

import '../database/local_database.dart';
import '../helpers/analytics_helper.dart';

class TempTestingPage extends StatefulWidget {
  const TempTestingPage({Key? key}) : super(key: key);

  @override
  _TempTestingPageState createState() => _TempTestingPageState();
}

class _TempTestingPageState extends State<TempTestingPage> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();

    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text('CLICK'),
          onPressed: () async {
            print(await AnalyticsHelper.trackScannedProduct(
                barcode: '0000070000'));
          },
        ),
      ),
    );
  }
}
