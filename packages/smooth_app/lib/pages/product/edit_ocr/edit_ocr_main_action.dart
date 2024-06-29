part of 'edit_ocr_page.dart';

class _EditOcrMainAction extends StatelessWidget {
  const _EditOcrMainAction({
    required this.onPressed,
    required this.helper,
    required this.state,
  });

  final VoidCallback onPressed;
  final OcrHelper helper;
  final _OcrState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Widget? child = switch (state) {
      _OcrState.IMAGE_LOADING => _EditOcrActionLoadingContent(
          helper: helper,
          appLocalizations: appLocalizations,
        ),
      _OcrState.IMAGE_LOADED => _ExtractMainActionContentLoaded(
          helper: helper,
          appLocalizations: appLocalizations,
          onPressed: onPressed,
        ),
      _OcrState.EXTRACTING_DATA => _EditOcrActionExtractingContent(
          helper: helper,
          appLocalizations: appLocalizations,
        ),
      _OcrState.OTHER => null,
    };

    if (child == null) {
      return EMPTY_WIDGET;
    }

    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return SizedBox(
      height: 45.0 * (_computeFontScaleFactor(context)),
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: ANGULAR_BORDER_RADIUS,
          color: theme.primarySemiDark,
          border: Border.all(
            color: theme.primaryBlack,
            width: 2.0,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ProgressIndicatorTheme(
            data: const ProgressIndicatorThemeData(
              color: Colors.white,
            ),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: Colors.white,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _computeFontScaleFactor(BuildContext context) {
    final double fontSize = DefaultTextStyle.of(context).style.fontSize ?? 15.0;
    final double scaledFontSize =
        MediaQuery.textScalerOf(context).scale(fontSize);

    return scaledFontSize / fontSize;
  }
}

class _EditOcrActionExtractingContent extends StatelessWidget {
  const _EditOcrActionExtractingContent({
    required this.helper,
    required this.appLocalizations,
  });

  final OcrHelper helper;
  final AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: helper.getActionLoadingPhoto(appLocalizations),
      excludeSemantics: true,
      child: Shimmer(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.black,
            Colors.white,
            Colors.black,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const _ExtractMainActionProgressIndicator(),
              Expanded(
                child: Text(
                  helper.getActionExtractingData(appLocalizations),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtractMainActionContentLoaded extends StatelessWidget {
  const _ExtractMainActionContentLoaded({
    required this.helper,
    required this.appLocalizations,
    required this.onPressed,
  });

  final OcrHelper helper;
  final AppLocalizations appLocalizations;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      value: helper.getActionExtractText(appLocalizations),
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: ANGULAR_BORDER_RADIUS,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  helper.getActionExtractText(appLocalizations),
                ),
              ),
              const Icon(
                Icons.download,
                semanticLabel: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditOcrActionLoadingContent extends StatelessWidget {
  const _EditOcrActionLoadingContent({
    required this.helper,
    required this.appLocalizations,
  });

  final OcrHelper helper;
  final AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: VERY_SMALL_SPACE,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const _ExtractMainActionProgressIndicator(),
          Expanded(
            child: Text(
              helper.getActionLoadingPhoto(appLocalizations),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.0,
            child: InkWell(
              onTap: () => _openExplanation(context),
              borderRadius: ANGULAR_BORDER_RADIUS,
              child: Icon(
                Icons.info_outline,
                semanticLabel: helper.getActionLoadingPhotoDialogTitle(
                  appLocalizations,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _openExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return SmoothAlertDialog(
          title: helper.getActionLoadingPhotoDialogTitle(
            appLocalizations,
          ),
          leadingTitle: const Icon(
            Icons.info_outline,
            semanticLabel: '',
          ),
          close: true,
          body: Text(
            helper.getActionLoadingPhotoDialogBody(
              appLocalizations,
            ),
          ),
          positiveAction: SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }
}

/// We use a custom progress indicator, because Material and Cupertino Widgets
/// don't have the same size.
class _ExtractMainActionProgressIndicator extends StatelessWidget {
  const _ExtractMainActionProgressIndicator();

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return const Padding(
        padding: EdgeInsetsDirectional.only(
          start: SMALL_SPACE,
          end: MEDIUM_SPACE,
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: CupertinoActivityIndicator(
          radius: 10.0,
          color: Colors.white,
        ),
      );
    }

    return const Padding(
      padding: EdgeInsetsDirectional.only(
        start: SMALL_SPACE,
        end: MEDIUM_SPACE,
        top: MEDIUM_SPACE,
        bottom: MEDIUM_SPACE,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          // backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

enum _OcrState {
  IMAGE_LOADING,
  IMAGE_LOADED,
  EXTRACTING_DATA,
  OTHER,
}
