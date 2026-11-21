import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/app_localizations_delegates.dart';
import 'package:smooth_app/pages/image/product_image_other_page.dart';
import 'package:smooth_app/pages/product/helpers/pinch_to_zoom_indicator.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_view_padding.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

const String _barcode = '123';
const String _heroTag = 'hero';

/// Reports an error to its listeners only, like a failing download: an error
/// raised with no listener is an unhandled exception for the test.
class _FailingImageStreamCompleter extends ImageStreamCompleter {
  static int deliveredErrors = 0;

  @override
  void addListener(ImageStreamListener listener) {
    super.addListener(listener);
    deliveredErrors++;
    listener.onError?.call(
      Exception('Original not available'),
      StackTrace.current,
    );
  }
}

void main() {
  late UriProductHelper uriHelper;

  String resizedUrl(ProductImage image) =>
      image.getUrl(_barcode, uriHelper: uriHelper);

  String originalUrl(ProductImage image) => image.getUrl(
    _barcode,
    uriHelper: uriHelper,
    imageSize: ImageSize.ORIGINAL,
  );

  ProductImage buildImage(
    String imgid, {
    int? width = 800,
    int? height = 600,
    DateTime? uploaded,
  }) => ProductImage.raw(
    imgid: imgid,
    size: ImageSize.DISPLAY,
    width: width,
    height: height,
    uploaded: uploaded,
  );

  /// Fills the image cache, so no network request is made.
  Future<void> stubImages(
    WidgetTester tester,
    List<ProductImage> images, {
    bool originalFails = false,
  }) async {
    final ui.Image pixels = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    final ImageCache cache = PaintingBinding.instance.imageCache;
    addTearDown(pixels.dispose);
    addTearDown(cache.clear);
    _FailingImageStreamCompleter.deliveredErrors = 0;

    for (final ProductImage image in images) {
      cache.putIfAbsent(
        NetworkImage(resizedUrl(image)),
        () => OneFrameImageStreamCompleter(
          SynchronousFuture<ImageInfo>(ImageInfo(image: pixels.clone())),
        ),
      );
      cache.putIfAbsent(
        NetworkImage(originalUrl(image)),
        () => originalFails
            ? _FailingImageStreamCompleter()
            : OneFrameImageStreamCompleter(
                SynchronousFuture<ImageInfo>(ImageInfo(image: pixels.clone())),
              ),
      );
    }
  }

  Future<void> pumpPage(
    WidgetTester tester,
    List<ProductImage> images, {
    int current = 0,
    String? heroTag,
    bool originalFails = false,
  }) async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    final UserPreferences prefs = await UserPreferences.getUserPreferences();
    ProductQuery.setQueryType(prefs);
    uriHelper = ProductQuery.getUriProductHelper(productType: null);
    final ThemeProvider themeProvider = ThemeProvider(prefs);

    await stubImages(tester, images, originalFails: originalFails);

    await tester.pumpWidget(
      MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<LocalDatabase>.value(
            value: MockLocalDatabase(),
          ),
        ],
        child: MaterialApp(
          builder: (BuildContext context, Widget? child) =>
              SmoothViewPadding(child: child!),
          localizationsDelegates: appLocalizationsDelegates,
          theme: SmoothTheme.getThemeData(
            Brightness.light,
            themeProvider,
            () => ColorProvider(prefs),
            () => TextContrastProvider(prefs),
          ),
          home: ProductImageOtherPage(
            product: Product(barcode: _barcode),
            language: OpenFoodFactsLanguage.ENGLISH,
            images: images,
            currentImage: images[current],
            heroTag: heroTag,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder networkImage(String url) => find.byWidgetPredicate(
    (Widget widget) =>
        widget is Image &&
        widget.image is NetworkImage &&
        (widget.image as NetworkImage).url == url,
  );

  Future<void> pinchZoom(WidgetTester tester) async {
    final Offset center = tester.getCenter(find.byType(PhotoViewGallery));
    final TestGesture first = await tester.startGesture(
      center - const Offset(20.0, 0.0),
      pointer: 1,
    );
    final TestGesture second = await tester.startGesture(
      center + const Offset(20.0, 0.0),
      pointer: 2,
    );
    await first.moveBy(const Offset(-80.0, 0.0));
    await second.moveBy(const Offset(80.0, 0.0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
  }

  Future<void> swipeToNextPhoto(WidgetTester tester) async {
    await tester.drag(
      find.byType(PhotoViewGallery),
      const Offset(-600.0, 0.0),
    );
    await tester.pumpAndSettle();
  }

  final List<ProductImage> threePhotos = <ProductImage>[
    buildImage('2'),
    buildImage('3'),
    buildImage('4'),
  ];

  testWidgets('the photos are displayed in a single zoomable gallery', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    expect(find.byType(PhotoViewGallery), findsOneWidget);
    expect(find.byType(PhotoView), findsOneWidget);
    expect(networkImage(resizedUrl(threePhotos[0])), findsOneWidget);
  });

  testWidgets('the pinch-to-zoom explainer stays available', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    expect(find.byType(PinchToZoomExplainer), findsOneWidget);

    await swipeToNextPhoto(tester);

    expect(find.byType(PinchToZoomExplainer), findsOneWidget);
  });

  testWidgets('the gallery starts on the photo the screen is opened with', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos, current: 2);

    expect(find.text('3 / 3'), findsOneWidget);
    expect(networkImage(resizedUrl(threePhotos[2])), findsOneWidget);
  });

  testWidgets('the original photo is only built after the page is zoomed', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    expect(networkImage(originalUrl(threePhotos[0])), findsNothing);

    await pinchZoom(tester);

    expect(networkImage(originalUrl(threePhotos[0])), findsOneWidget);
    expect(networkImage(resizedUrl(threePhotos[0])), findsOneWidget);

    await pinchZoom(tester);

    expect(networkImage(originalUrl(threePhotos[0])), findsOneWidget);
  });

  testWidgets('swiping without zooming never requests an original photo', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    await swipeToNextPhoto(tester);
    await swipeToNextPhoto(tester);

    for (final ProductImage image in threePhotos) {
      expect(networkImage(originalUrl(image)), findsNothing);
    }
  });

  testWidgets('a failing original photo keeps the resized one', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos, originalFails: true);

    await pinchZoom(tester);

    expect(networkImage(originalUrl(threePhotos[0])), findsOneWidget);
    expect(networkImage(resizedUrl(threePhotos[0])), findsOneWidget);
    expect(_FailingImageStreamCompleter.deliveredErrors, greaterThan(0));
    expect(find.text('Error loading photo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zooming a photo does not load the original of the next one', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    await pinchZoom(tester);

    // A zoomed photo is panned first: the next one only comes at its edge.
    for (int i = 0; i < 5 && find.text('2 / 3').evaluate().isEmpty; i++) {
      await swipeToNextPhoto(tester);
    }

    expect(find.text('2 / 3'), findsOneWidget);
    expect(networkImage(originalUrl(threePhotos[1])), findsNothing);

    await pinchZoom(tester);

    expect(networkImage(originalUrl(threePhotos[1])), findsOneWidget);
  });

  testWidgets('a double-tap zooms in and a second one goes back to fit', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    Future<void> doubleTap() async {
      final Offset center = tester.getCenter(find.byType(PhotoViewGallery));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tapAt(center);
      await tester.pumpAndSettle();
    }

    await doubleTap();

    expect(networkImage(originalUrl(threePhotos[0])), findsOneWidget);

    await doubleTap();

    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('"Use as" applies to the displayed photo', (
    WidgetTester tester,
  ) async {
    final List<String> requested = <String>[];

    await http.runWithClient(
      () async {
        await pumpPage(tester, threePhotos);
        await swipeToNextPhoto(tester);

        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Product photo'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.pump(const Duration(seconds: 1));

        expect(requested, <String>[originalUrl(threePhotos[1])]);
      },
      () => MockClient((http.Request request) async {
        requested.add(request.url.toString());
        // The download never ends: only the requested URL matters.
        return Completer<http.Response>().future;
      }),
    );
  });

  testWidgets('the indicator and the details follow the displayed photo', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, threePhotos);

    expect(find.text('1 / 3'), findsOneWidget);

    await swipeToNextPhoto(tester);

    expect(find.text('1 / 3'), findsNothing);
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(originalUrl(threePhotos[1])),
      findsOneWidget,
    );
  });

  group('hero', () {
    Iterable<Hero> heroes(WidgetTester tester) =>
        tester.widgetList<Hero>(find.byType(Hero));

    testWidgets('only the opened photo has a Hero', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, threePhotos, current: 1, heroTag: _heroTag);

      expect(heroes(tester).map((Hero hero) => hero.tag), <Object>[_heroTag]);

      await swipeToNextPhoto(tester);

      expect(heroes(tester), isEmpty);
    });

    for (final (String, String?) tag in <(String, String?)>[
      ('a null tag', null),
      ('an empty tag', ''),
    ]) {
      testWidgets('no Hero with ${tag.$1}', (
        WidgetTester tester,
      ) async {
        await pumpPage(tester, threePhotos, heroTag: tag.$2);

        expect(heroes(tester), isEmpty);
      });
    }
  });

  group('child size', () {
    Size? childSize(WidgetTester tester) =>
        tester.widget<PhotoView>(find.byType(PhotoView)).childSize;

    testWidgets('it fits the photo ratio in the gallery', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, <ProductImage>[
        buildImage('2', width: 1000, height: 500),
      ]);

      final Size gallery = tester.getSize(find.byType(PhotoViewGallery));

      expect(
        childSize(tester),
        applyBoxFit(
          BoxFit.contain,
          const Size(1000.0, 500.0),
          gallery,
        ).destination,
      );
    });

    final Map<String, ProductImage> unknownSizes = <String, ProductImage>{
      'a missing width': buildImage('2', width: null),
      'a missing height': buildImage('2', height: null),
      'a zero width': buildImage('2', width: 0),
      'a negative height': buildImage('2', height: -10),
    };

    for (final MapEntry<String, ProductImage> entry in unknownSizes.entries) {
      testWidgets('it is null with ${entry.key}', (WidgetTester tester) async {
        await pumpPage(tester, <ProductImage>[entry.value]);

        expect(childSize(tester), isNull);
      });
    }
  });

  testWidgets('an expired photo shows the label for the displayed photo', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, <ProductImage>[
      buildImage('2'),
      buildImage('3', uploaded: DateTime(2020)),
    ]);

    expect(find.text('This image may be outdated'), findsNothing);

    await swipeToNextPhoto(tester);

    expect(find.text('This image may be outdated'), findsOneWidget);
  });

  for (final double textScale in <double>[1.0, 1.3]) {
    testWidgets('an outdated photo fits a small screen at $textScale', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080.0, 2400.0);
      tester.view.devicePixelRatio = 3.0;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpPage(tester, <ProductImage>[
        buildImage('2', uploaded: DateTime(2020)),
      ]);

      expect(tester.takeException(), isNull);
    });
  }
}
