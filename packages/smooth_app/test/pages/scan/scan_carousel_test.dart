import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

class _ScanModel extends ContinuousScanModel {
  ScannedProductState state = ScannedProductState.LOADING;

  void add(String barcode) {
    getBarcodes().add(barcode);
    lastConsultedBarcode = barcode;
  }

  @override
  ScannedProductState? getBarcodeState(String barcode) => state;
}

class _Database extends Mock implements Database {
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async => <Map<String, Object?>>[];
}

class _LocalDatabase extends MockLocalDatabase {
  final Database _database = _Database();

  @override
  Database get database => _database;
}

class _NewsProvider extends Mock implements AppNewsProvider {
  @override
  bool get hasContent => false;
}

class _FileLoader extends Mock implements rive.FileLoader {
  final Completer<rive.File> _file = Completer<rive.File>();

  @override
  Future<rive.File> file() => _file.future;

  @override
  bool get isFileAvailable => false;
}

void main() {
  late UserPreferences preferences;
  late ProductPreferences productPreferences;
  late _ScanModel model;
  late List<int> movements;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    preferences = await UserPreferences.getUserPreferences();
    productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: preferences.setImportance,
        getImportance: preferences.getImportance,
        notify: () => productPreferences.notifyListeners(),
      ),
    );
    await productPreferences.init(PlatformAssetBundle());
    await preferences.init(productPreferences);
  });

  setUp(() {
    model = _ScanModel();
    movements = <int>[];
    final Duration interval =
        VisibilityDetectorController.instance.updateInterval;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    addTearDown(() {
      VisibilityDetectorController.instance.updateInterval = interval;
      model.dispose();
    });
  });

  Future<void> pumpCarousel(WidgetTester tester) async {
    await tester.pumpWidget(
      MockSmoothApp(
        preferences,
        UserManagementProvider(),
        productPreferences,
        ThemeProvider(preferences),
        TextContrastProvider(preferences),
        ColorProvider(preferences),
        MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<ContinuousScanModel>.value(value: model),
            ChangeNotifierProvider<AppNewsProvider>.value(
              value: _NewsProvider(),
            ),
            Provider<rive.FileLoader>.value(value: _FileLoader()),
          ],
          child: ExternalScanCarouselManager(
            child: ScanPageCarousel(
              onPageChangedTo: (int page, String? barcode) =>
                  movements.add(page),
            ),
          ),
        ),
        localDatabase: _LocalDatabase(),
      ),
    );
    await tester.pump();
  }

  Future<void> finishMovement(WidgetTester tester) async {
    await tester.pump();
    for (int frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();
  }

  double? currentPage(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView)).controller!.page;

  testWidgets('scrolls to the first and subsequent scanned products', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester);
    expect(currentPage(tester), 0);
    model.add('1234');
    await finishMovement(tester);
    expect(currentPage(tester), closeTo(1, 0.01));
    model.add('5678');
    await finishMovement(tester);
    expect(currentPage(tester), 2);
    expect(movements, <int>[1, 2]);
  });

  testWidgets('scrolls to an existing product after a manual swipe', (
    WidgetTester tester,
  ) async {
    model.getBarcodes().addAll(<String>['1234', '5678']);
    await pumpCarousel(tester);
    await model.onScan('5678');
    await finishMovement(tester);
    expect(currentPage(tester), 2);
    await tester.drag(find.byType(CarouselSlider), const Offset(650, 0));
    await finishMovement(tester);
    expect(model.latestConsultedBarcode, '1234');
    await model.onScan('5678');
    await finishMovement(tester);
    expect(currentPage(tester), 2);
  });

  testWidgets('honors a barcode selected before the controller is ready', (
    WidgetTester tester,
  ) async {
    model.add('1234');
    await pumpCarousel(tester);
    await finishMovement(tester);
    expect(currentPage(tester), closeTo(1, 0.01));
  });

  testWidgets('a rapid rescan can return to the page being left', (
    WidgetTester tester,
  ) async {
    model.getBarcodes().addAll(<String>['1234', '5678', '9012']);
    await pumpCarousel(tester);
    await model.onScan('1234');
    await finishMovement(tester);
    await model.onScan('9012');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    await model.onScan('1234');
    await finishMovement(tester);
    expect(currentPage(tester), closeTo(1, 0.01));
  });

  testWidgets('product state notifications do not lose the scan target', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester);
    model.add('1234');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), closeTo(1, 0.01));
  });

  testWidgets('rapid new scans select the latest product', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester);
    model.add('1234');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    model.add('5678');
    model.add('9012');
    await finishMovement(tester);
    expect(currentPage(tester), 3);
    expect(model.latestConsultedBarcode, '9012');
  });

  testWidgets('repeated scans and notifications do not repeat feedback', (
    WidgetTester tester,
  ) async {
    model.getBarcodes().add('1234');
    await pumpCarousel(tester);
    await model.onScan('1234');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    await model.onScan('1234');
    await finishMovement(tester);
    await model.onScan('1234');
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), 1);
    expect(movements, <int>[1]);
  });

  testWidgets('removing products keeps the page in range', (
    WidgetTester tester,
  ) async {
    model.getBarcodes().addAll(<String>['1234', '5678', '9012']);
    await pumpCarousel(tester);
    await model.onScan('9012');
    await finishMovement(tester);
    model.getBarcodes().remove('1234');
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), 2);
    model.getBarcodes().remove('9012');
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), 1);
    model.getBarcodes().clear();
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), 0);
    model.add('3456');
    await finishMovement(tester);
    expect(currentPage(tester), closeTo(1, 0.01));
    model.add('7890');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    model.getBarcodes().remove('7890');
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), closeTo(1, 0.01));
  });

  testWidgets('returning to the search card allows a rescan', (
    WidgetTester tester,
  ) async {
    model.getBarcodes().add('1234');
    await pumpCarousel(tester);
    await model.onScan('1234');
    await finishMovement(tester);
    final BuildContext context = tester.element(find.byType(ScanPageCarousel));
    ExternalScanCarouselManager.read(context).showSearchCard();
    await finishMovement(tester);
    expect(currentPage(tester), 0);
    expect(model.latestConsultedBarcode, isNull);
    await model.onScan('1234');
    await finishMovement(tester);
    expect(currentPage(tester), 1);
  });

  testWidgets('the search card can interrupt a scan animation', (
    WidgetTester tester,
  ) async {
    model.getBarcodes().addAll(<String>['1234', '5678', '9012']);
    await pumpCarousel(tester);
    await model.onScan('1234');
    await finishMovement(tester);
    await model.onScan('9012');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    final BuildContext context = tester.element(find.byType(ScanPageCarousel));
    ExternalScanCarouselManager.read(context).showSearchCard();
    await finishMovement(tester);
    expect(currentPage(tester), 0);
    expect(model.latestConsultedBarcode, isNull);
  });

  testWidgets('can be disposed with a pending selection', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester);
    model.add('1234');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cached and found product updates preserve navigation', (
    WidgetTester tester,
  ) async {
    model.state = ScannedProductState.CACHED;
    model.getBarcodes().addAll(<String>['1234', '5678']);
    await pumpCarousel(tester);
    await model.onScan('5678');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    model.state = ScannedProductState.FOUND;
    model.notifyListeners();
    await finishMovement(tester);
    expect(currentPage(tester), 2);
    expect(movements, <int>[2]);
    await model.onScan('1234');
    await finishMovement(tester);
    expect(currentPage(tester), 1);
  });
}
