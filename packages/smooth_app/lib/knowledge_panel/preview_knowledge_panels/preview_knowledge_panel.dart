import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Abstract base class for knowledge panels that support preview and detailed views
abstract class PreviewKnowledgePanel extends StatefulWidget {
  const PreviewKnowledgePanel({
    super.key,
    required this.product,
    required this.panels,
  });

  final Product product;
  final List<Widget> panels;

  @override
  PreviewKnowledgePanelState<PreviewKnowledgePanel> createState();
}

abstract class PreviewKnowledgePanelState<T extends PreviewKnowledgePanel>
    extends State<T> {
  bool _preview = true;

  /// Override this method to build the preview content
  Widget buildPreviewContent(BuildContext context);

  /// Override this method to provide custom button text
  String get detailsButtonText => 'Voir les détails';

  @override
  Widget build(BuildContext context) {
    return _preview ? _buildPreviewView(context) : _buildDetailedView(context);
  }

  Widget _buildPreviewView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildPreviewContent(context),
        const SizedBox(height: VERY_LARGE_SPACE),
        _buildDetailsButton(context),
      ],
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsetsDirectional.zero,
      itemCount: widget.panels.length,
      itemBuilder: (BuildContext context, int index) => widget.panels[index],
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return InkWell(
      onTap: () {
        setState(() {
          _preview = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        decoration: BoxDecoration(
          color: lightTheme
              ? themeExtension.primaryMedium
              : themeExtension.primaryDark,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              detailsButtonText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: lightTheme
                    ? themeExtension.primarySemiDark
                    : themeExtension.primaryMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
