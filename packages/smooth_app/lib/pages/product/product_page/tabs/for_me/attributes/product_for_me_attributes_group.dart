import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/attribute_extensions.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_title.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductForMeAttributesGroup extends StatelessWidget {
  const ProductForMeAttributesGroup({
    required this.attributes,
    required this.groupName,
    super.key,
  });

  final String groupName;
  final List<Attribute> attributes;

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) {
      return EMPTY_WIDGET;
    }

    return Column(
      children: <Widget>[
        ProductPageTitle(label: groupName),
        ...attributes.map(
          (Attribute attr) => _ProductForMeAttributeItem(attribute: attr),
        ),
      ],
    );
  }
}

class _ProductForMeAttributeItem extends StatelessWidget {
  const _ProductForMeAttributeItem({required this.attribute});

  final Attribute attribute;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool clickable = attribute.panelId?.isNotEmpty ?? false;
    final Color color = getAttributeDisplayBackgroundColor(attribute);

    return InkWell(
      onTap: clickable
          ? () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => KnowledgePanelPage(
                  panelId: attribute.panelId!,
                  product: context.read<Product>(),
                ),
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: MEDIUM_SPACE,
          vertical: SMALL_SPACE,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: MEDIUM_SPACE,
          children: <Widget>[
            attribute.getCircledIcon(
              backgroundColor: color,
              size: 30.0,
              placeholder: CircleAvatar(radius: 15.0, backgroundColor: color),
            ),
            Expanded(child: Text(_displayName(AppLocalizations.of(context)))),
            if (clickable)
              icons.AppIconTheme(
                size: 15.0,
                color: context.lightTheme() ? theme.greyDark : theme.greyLight,
                child: icons.Chevron.horizontalDirectional(context),
              ),
          ],
        ),
      ),
    );
  }

  String _displayName(AppLocalizations appLocalizations) {
    if (attribute.id == Attribute.ATTRIBUTE_ECOSCORE) {
      return '${attribute.name}${appLocalizations.sep}: ${attribute.descriptionShort}';
    } else if (attribute.id == Attribute.ATTRIBUTE_NUTRISCORE) {
      return '${attribute.name}${appLocalizations.sep}: ${attribute.descriptionShort}';
    } else if (attribute.id == Attribute.ATTRIBUTE_NOVA) {
      return attribute.descriptionShort ??
          attribute.title ??
          appLocalizations.nova_group_generic_new;
    } else {
      return attribute.title ??
          attribute.description ??
          attribute.descriptionShort ??
          '';
    }
  }
}
