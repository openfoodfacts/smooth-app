import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/product/helpers/pinch_to_zoom_indicator.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_indicator_icon.dart';
import 'package:smooth_app/widgets/smooth_interactive_viewer.dart';

class EditProductImageViewer extends StatefulWidget {
  const EditProductImageViewer({
    required this.visible,
    required this.onClose,
    required this.imageField,
    this.language,
    super.key,
  });

  final bool visible;
  final VoidCallback onClose;
  final ImageField imageField;
  final OpenFoodFactsLanguage? language;

  @override
  State<EditProductImageViewer> createState() => _EditProductImageViewerState();
}

class _EditProductImageViewerState extends State<EditProductImageViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SmoothAnimationsDuration.medium,
      reverseDuration: SmoothAnimationsDuration.short,
      vsync: this,
    )..addListener(() => setState(() {}));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutSine),
    );
  }

  @override
  void didUpdateWidget(covariant EditProductImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value == 0.0) {
      return EMPTY_WIDGET;
    }

    return ExcludeSemantics(
      child: SizedOverflowBox(
        size: Size(
          double.infinity,
          MediaQuery.sizeOf(context).height * 0.2 * _animation.value,
        ),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.2,
          child: ColoredBox(
            color: context.lightTheme() ? Colors.grey[850]! : Colors.grey[800]!,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: SmoothInteractiveViewer(
                    child: Image(
                      fit: BoxFit.contain,
                      image: _getImageProvider(context),
                      frameBuilder: _frameBuilder,
                      loadingBuilder: _loadingBuilder,
                      errorBuilder: _errorBuilder,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 1.0,
                  end: 3.5,
                  child: Offstage(
                    offstage: _animation.value != 1.0,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onClose,
                        child: Tooltip(
                          message: AppLocalizations.of(context).close,
                          child: const SmoothIndicatorIcon(
                            icon: icons.Close(
                              size: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 1.0,
                  end: 3.5,
                  child: Offstage(
                    offstage: _animation.value != 1.0,
                    child: const PinchToZoomExplainer(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _getImageProvider(BuildContext context) {
    final Product product = context.watch<Product>();

    final Iterable<OpenFoodFactsLanguage> languages = getProductImageLanguages(
      product,
      ImageField.NUTRITION,
    );

    for (final OpenFoodFactsLanguage language in <OpenFoodFactsLanguage?>[
      widget.language,
      ProductQuery.getLanguage(),
      OpenFoodFactsLanguage.ENGLISH,
      languages.first,
    ].nonNulls) {
      if (languages.contains(language)) {
        return TransientFile.fromProduct(
          product,
          widget.imageField,
          language,
        ).getImageProvider()!;
      }
    }

    return NetworkImage(product.imageNutritionUrl ?? '');
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (frame == null) {
      return _loadingWidget();
    } else if (_isLoading) {
      onNextFrame(
        () => setState(() => _isLoading = false),
      );
    }
    return child;
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child;
    }
    return _loadingWidget();
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    onNextFrame(
      () => setState(() => _isLoading = false),
    );

    return FractionallySizedBox(
      widthFactor: 0.6,
      child: Center(
        child: Text(
          AppLocalizations.of(context).nutrition_page_photo_error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
