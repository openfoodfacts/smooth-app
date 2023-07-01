import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provides the most up-to-date local product data for a StatefulWidget.
///
/// Typically we have
/// * a product from the database (downloaded from the server)
/// * potentially pending changes to apply on top while they're being uploaded
///
/// With this class
/// * we get the most up-to-date local product data
/// * we re-launch the task manager if relevant
/// * we track the barcodes currently "opened" by the app
class UpToDateManager {
  /// To be used in the `initState` method.
  UpToDateManager(this.initialProduct, this.localDatabase) {
    localDatabase.upToDate.showInterest(barcode);
  }

  final Product initialProduct;
  final LocalDatabase localDatabase;

  late Product product;
  String get barcode => initialProduct.barcode!;

  /// To be used in the `dispose` method.
  void dispose() => localDatabase.upToDate.loseInterest(barcode);

  /// Refreshes [product] with the latest available local data.
  ///
  /// To be used in the `build` method, after a call to
  /// `context.watch<LocalDatabase>()`.
  void refresh() {
    BackgroundTaskManager.getInstance(localDatabase).run(); // no await
    product = localDatabase.upToDate.getLocalUpToDate(initialProduct);
  }
}
