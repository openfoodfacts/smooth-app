import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_table.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_title.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

class FolksonomyListAttributesCard extends StatelessWidget {
  const FolksonomyListAttributesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        ProductPageTitle(
          label: appLocalizations.product_tags_title,
          trailing: (_) => const _FolksonomyCardButton(),
        ),
        _FolksonomyCardBody(
          onEmptyPageTag: () =>
              _openFolksonomyPage(context, context.read<Product>()),
        ),
      ],
    );
  }
}

Future<void> _openFolksonomyPage(BuildContext context, Product product) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext lContext) => FolksonomyPage(product: product),
    ),
  );
  if (context.mounted) {
    await context.read<FolksonomyProvider>().fetchProductTags();
  }
}

class _FolksonomyCardBody extends StatelessWidget {
  const _FolksonomyCardBody({required this.onEmptyPageTag});

  final VoidCallback onEmptyPageTag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100.0),
      child: Consumer<FolksonomyProvider>(
        builder: (BuildContext context, FolksonomyProvider provider, _) {
          if (provider.value is FolksonomyStateLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (provider.value.tags?.isNotEmpty != true) {
            return InkWell(
              onTap: onEmptyPageTag,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: LARGE_SPACE,
                  vertical: VERY_LARGE_SPACE,
                ),
                child: Column(
                  spacing: BALANCED_SPACE,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: context.lightTheme()
                            ? theme.primaryLight
                            : theme.primaryMedium,
                      ),
                      child: const Padding(
                        padding: EdgeInsetsDirectional.all(LARGE_SPACE),
                        child: SvgPicture(
                          AssetBytesLoader(
                            'assets/icons/property_empty.svg.vec',
                          ),
                          width: 35.0,
                        ),
                      ),
                    ),
                    Text(
                      appLocalizations.no_product_tags_found_message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final Iterable<ProductTag> displayTags = provider.value.tags!;

            return ProductPageTable(
              columnPercents: const <double>[0.45, 0.55],
              columns: <Widget>[
                Text(appLocalizations.tag_keys),
                Text(appLocalizations.tag_values),
              ],
              rows: displayTags
                  .map(
                    (ProductTag item) => ProductPageTableRow(
                      columns: <String>[
                        item.key.replaceAll(':', '\n'),
                        item.value,
                      ],
                    ),
                  )
                  .toList(growable: false),
            );
          }
        },
      ),
    );
  }
}

class _FolksonomyCardButton extends StatelessWidget {
  const _FolksonomyCardButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openFolksonomyPage(context, context.read<Product>()),
      icon: Consumer<FolksonomyProvider>(
        builder: (BuildContext context, FolksonomyProvider provider, _) {
          Widget getIcon(List<ProductTag> tags) {
            final AppLocalizations appLocalizations = AppLocalizations.of(
              context,
            );

            if (tags.isNotEmpty == true) {
              return Tooltip(
                message: appLocalizations.add_edit_tags,
                child: const icons.Edit(size: 15.0),
              );
            } else {
              return Tooltip(
                message: appLocalizations.add_tags,
                child: const icons.Add(),
              );
            }
          }

          return switch (provider.value) {
            FolksonomyStateError(action: final FolksonomyAction? action)
                when action == null =>
              EMPTY_WIDGET,
            FolksonomyStateError(tags: final List<ProductTag> tags) => getIcon(
              tags,
            ),
            FolksonomyStateLoaded(tags: final List<ProductTag> tags) => getIcon(
              tags,
            ),
            _ => EMPTY_WIDGET,
          };
        },
      ),
    );
  }
}
