import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class FolksonomyListAttributesCard extends StatelessWidget {
  const FolksonomyListAttributesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardWithRoundedHeader(
      title: appLocalizations.product_tags_title,
      leading: const icons.Lists(),
      trailing: const _FolksonomyCardButton(),
      contentPadding: EdgeInsetsDirectional.zero,
      child: SizedBox(
        width: double.infinity,
        child: _FolksonomyCardBody(
          onEmptyPageTag: () =>
              _openFolksonomyPage(context, context.read<Product>()),
        ),
      ),
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

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100.0),
      child: Consumer<FolksonomyProvider>(
        builder: (BuildContext context, FolksonomyProvider provider, _) {
          if (provider.value is FolksonomyStateLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (provider.value.tags?.isNotEmpty != true) {
            return InkWell(
              onTap: onEmptyPageTag,
              child: Center(
                child: Text(
                  appLocalizations.no_product_tags_found_message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            final SmoothColorsThemeExtension extension = context
                .extension<SmoothColorsThemeExtension>();

            final Iterable<ProductTag> displayTags = provider.value.tags!.take(
              5,
            );

            return ClipRRect(
              borderRadius: ROUNDED_BORDER_RADIUS,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
                headingRowHeight: 48.0,
                headingRowColor: WidgetStatePropertyAll<Color>(
                  extension.primaryLight,
                ),
                dataTextStyle: DefaultTextStyle.of(context).style,
                columns: <DataColumn>[
                  DataColumn(label: Text(appLocalizations.tag_key)),
                  DataColumn(label: Text(appLocalizations.tag_value)),
                ],
                rows: displayTags
                    .map((ProductTag tag) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(tag.key)),
                          DataCell(Text(tag.value)),
                        ],
                      );
                    })
                    .toList(growable: false),
              ),
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
