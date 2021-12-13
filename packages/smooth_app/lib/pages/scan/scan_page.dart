import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();

  @override
  State<ScanPage> createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  static ContinuousScanModel? continuousScanModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateModel();
  }

  Future<void> _updateModel() async {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    if (continuousScanModel == null) {
      continuousScanModel = await ContinuousScanModel(
        languageCode: ProductQuery.getCurrentLanguageCode(context),
        countryCode: ProductQuery.getCurrentCountryCode(),
      ).load(localDatabase);
    } else {
      await continuousScanModel?.refresh();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (continuousScanModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider<ContinuousScanModel>(
      create: (BuildContext context) => continuousScanModel!,
      child: const ContinuousScanPage(),
    );
  }
}
