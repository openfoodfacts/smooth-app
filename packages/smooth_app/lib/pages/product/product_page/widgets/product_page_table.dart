import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductPageTable extends StatelessWidget {
  const ProductPageTable({
    required this.columnPercents,
    required this.columns,
    required this.rows,
    super.key,
  });

  final List<double> columnPercents;
  final List<Widget> columns;
  final List<ProductPageTableRow> rows;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return Table(
      columnWidths: Map<int, TableColumnWidth>.fromEntries(
        columnPercents.mapIndexed(
          (int position, double percent) => MapEntry<int, TableColumnWidth>(
            position,
            FlexColumnWidth(percent),
          ),
        ),
      ),
      border: TableBorder.all(color: theme.primaryMedium),
      children: <TableRow>[
        TableRow(
          decoration: BoxDecoration(
            color: context.lightTheme()
                ? theme.primaryLight
                : theme.primaryUltraBlack,
          ),
          children: columns
              .map((Widget widget) => _ProductPageTableHeader(child: widget))
              .toList(growable: false),
        ),
        ...rows,
      ],
    );
  }
}

class _ProductPageTableHeader extends StatelessWidget {
  const _ProductPageTableHeader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),
        child: child,
      ),
    );
  }
}

class ProductPageTableRow extends TableRow {
  const ProductPageTableRow({required this.columns, super.key});

  final List<String> columns;

  @override
  List<Widget> get children => columns
      .map((String col) {
        Widget child = Text(col);
        final bool isLink = col.startsWith('http');

        if (isLink) {
          child = Row(
            spacing: VERY_SMALL_SPACE,
            children: <Widget>[
              Expanded(child: child),
              const ExternalLink(size: 10.0),
            ],
          );
        }

        child = Padding(
          padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: child,
        );

        if (isLink) {
          return InkWell(
            onTap: () => LaunchUrlHelper.launchURL(col),
            child: child,
          );
        }

        return child;
      })
      .toList(growable: false);
}
