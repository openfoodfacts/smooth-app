import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({required this.offstage, required this.navigatorKey});

  final bool offstage;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ContinuousScanModel? _model;
  bool runUpdate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateModel();
  }

  Future<void> _updateModel() async {
    print('update model');
    runUpdate = true;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    if (_model == null) {
      _model = await ContinuousScanModel(
        languageCode: ProductQuery.getCurrentLanguageCode(context),
        countryCode: ProductQuery.getCurrentCountryCode(),
      ).load(localDatabase);
    } else {
      await _model?.refresh();
    }
    setState(() {});
  }

  @override
  void initState() {
    print('initState');
    super.initState();
    if (!runUpdate) {
      _updateModel();
    }
    runUpdate = false;
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider<ContinuousScanModel>(
      create: (BuildContext context) => _model!,
      child: _buildChild(),
    );
  }

  /*
  * Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => child);
      },
    )
  *
  *
  *
  * */

  Widget _buildChild() {
    print('Start build scan page');
    if (widget.offstage) {
      _model!.stopQRView();
      //This has to be build inside of the ChangeNotifierProvider to prevent the model to be disposed.
      return const Center(child: Text('A error occurred'));
    } else {
      return Navigator(
        key: widget.navigatorKey,
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ContinuousScanPage());
        },
      );
    }
  }
}
