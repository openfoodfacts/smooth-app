import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_autosize_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';

Future<void> showKnowledgePanelSquareModalSheet(
  BuildContext context, {
  required String panelId,
  required String title,
  required String value,
  required Color valueColor,
  required Product product,
}) async {
  showSmoothAutoSizeModalSheet(
    context: context,
    header: SmoothModalSheetHeader(
      title: '$title ($value)',
      prefix: SmoothModalSheetHeaderPrefixIndicator(
        color: valueColor,
        size: const Size.square(20.0),
      ),
      suffix: const SmoothModalSheetHeaderCloseButton(),
    ),
    bodyBuilder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: MEDIUM_SPACE,
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 15.0, height: 1.5),
          child: KnowledgePanelExpandedCard(
            panelId: panelId,
            product: product,
            isInitiallyExpanded: true,
            isClickable: true,
            roundedIcons: false,
            simplified: false,
          ),
        ),
      );
    },
  );
}
