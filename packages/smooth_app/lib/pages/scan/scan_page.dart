import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';

class ScanPage extends StatelessWidget {
  const ScanPage();

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    return FutureBuilder<ContinuousScanModel?>(
        future: ContinuousScanModel(
          languageCode: ProductQuery.getCurrentLanguageCode(context),
          countryCode: ProductQuery.getCurrentCountryCode(),
        ).load(localDatabase),
        builder: (BuildContext context,
            AsyncSnapshot<ContinuousScanModel?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final ContinuousScanModel? continuousScanModel = snapshot.data;
            if (continuousScanModel != null) {
              return ContinuousScanPage(continuousScanModel);
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

}
