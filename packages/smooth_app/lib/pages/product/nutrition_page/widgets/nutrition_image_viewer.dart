import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_indicator_icon.dart';

class NutritionImageViewer extends StatefulWidget {
  const NutritionImageViewer({
    required this.visible,
    required this.onClose,
    super.key,
  });

  final bool visible;
  final VoidCallback onClose;

  @override
  State<NutritionImageViewer> createState() => _NutritionImageViewerState();
}

class _NutritionImageViewerState extends State<NutritionImageViewer> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return EMPTY_WIDGET;
    }

    return ExcludeSemantics(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.2,
        width: double.infinity,
        child: ColoredBox(
          color: context.lightTheme() ? Colors.grey[850]! : Colors.grey[800]!,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: InteractiveViewer(
                  child: Image(
                    fit: BoxFit.contain,
                    image: TransientFile.fromProduct(
                      context.watch<Product>(),
                      ImageField.NUTRITION,
                      ProductQuery.getLanguage(),
                    ).getImageProvider()!,
                    frameBuilder: _frameBuilder,
                    loadingBuilder: _loadingBuilder,
                    errorBuilder: _errorBuilder,
                  ),
                ),
              ),
              PositionedDirectional(
                top: 1.0,
                end: 2.5,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onClose,
                    child: Tooltip(
                      message: AppLocalizations.of(context).close,
                      child: const SmoothIndicatorIcon(
                        icon: Padding(
                          padding: EdgeInsetsDirectional.all(2.0),
                          child: Close(),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
}
