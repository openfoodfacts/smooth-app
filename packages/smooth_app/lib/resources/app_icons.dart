import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;

part 'app_food_icons.dart';
part 'app_icons_font.dart';

class Add extends AppIcon {
  const Add({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add);

  const Add.circled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_circled);
}

class AddPrice extends AppIcon {
  factory AddPrice(off.Currency currency) {
    return switch (currency) {
      off.Currency.GBP => const AddPrice.britishPound(),
      off.Currency.USD => const AddPrice.dollar(),
      off.Currency.EUR => const AddPrice.euro(),
      off.Currency.RUB => const AddPrice.ruble(),
      off.Currency.INR => const AddPrice.rupee(),
      off.Currency.CHF => const AddPrice.swissFranc(),
      off.Currency.TRY => const AddPrice.turkishLira(),
      off.Currency.UAH => const AddPrice.ukrainianHryvnia(),
      off.Currency.KRW => const AddPrice.won(),
      off.Currency.JPY => const AddPrice.yen(),
      _ => const AddPrice.dollar(),
    };
  }

  const AddPrice.britishPound({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_british_pound);

  const AddPrice.dollar({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_dollar);

  const AddPrice.euro({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_euro);

  const AddPrice.ruble({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_ruble);

  const AddPrice.rupee({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_rupee);

  const AddPrice.swissFranc({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_swiss_franc);

  const AddPrice.turkishLira({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_turkish_lira);

  const AddPrice.ukrainianHryvnia({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_ukrainian_hryvnia);

  const AddPrice.won({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_won);

  const AddPrice.yen({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_price_yen);
}

class AddProperty extends AppIcon {
  const AddProperty({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_property);

  const AddProperty.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_property_alt);
}

class AddToList extends AppIcon {
  factory AddToList({
    required int count,
    Color? color,
    double? size,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) {
    return AddToList._count(
      iconData: _getResource(count),
      color: color,
      size: size,
      shadow: shadow,
      semanticLabel: semanticLabel,
      key: key,
    );
  }

  const AddToList._count({
    required IconData iconData,
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(iconData);

  const AddToList.symbol({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.add_to_list);

  static IconData _getResource(int count) {
    switch (count) {
      case 1:
        return _IconsFont.add_to_list_1;
      case 2:
        return _IconsFont.add_to_list_2;
      case 3:
        return _IconsFont.add_to_list_3;
      case 4:
        return _IconsFont.add_to_list_4;
      case 5:
        return _IconsFont.add_to_list_5;
      case 6:
        return _IconsFont.add_to_list_6;
      case 7:
        return _IconsFont.add_to_list_7;
      case 8:
        return _IconsFont.add_to_list_8;
      case 9:
        return _IconsFont.add_to_list_9;
      default:
        return _IconsFont.add_to_list_9_plus;
    }
  }
}

class AppStore extends AppIcon {
  const AppStore({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.app_store);
}

class Arrow extends AppIcon {
  const Arrow.right({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 0,
       super._(_IconsFont.arrow_right);

  const Arrow.left({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 2,
       super._(_IconsFont.arrow_right);

  const Arrow.down({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 1,
       super._(_IconsFont.arrow_right);

  const Arrow.up({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 3,
       super._(_IconsFont.arrow_right);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(quarterTurns: turns, child: super.build(context));
  }
}

class Barcode extends AppIcon {
  const Barcode({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.barcode);

  const Barcode.rounded({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.barcode_rounded);

  const Barcode.withCorners({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.barcode_corners);
}

class Book extends AppIcon {
  const Book({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.book);
}

class Brush extends AppIcon {
  const Brush({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.brush);
}

class Build extends AppIcon {
  const Build({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.build);
}

class Calendar extends AppIcon {
  const Calendar({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.calendar);

  const Calendar.add({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.calendar_add);

  const Calendar.edit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.calendar_edit);
}

class Camera extends AppIcon {
  const Camera.add({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.camera_add);

  const Camera.aperture({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.aperture);

  const Camera.bulk({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.camera_bulk);

  const Camera.filled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.camera_filled);

  const Camera.outlined({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.camera_outlined);

  const Camera.happy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.camera_happy);

  const Camera.restart({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.camera_restart);
}

class Cards extends AppIcon {
  const Cards({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.cards);
}

class Certificate extends AppIcon {
  const Certificate({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.certificate);
}

class Certification extends AppIcon {
  const Certification({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.certification);
}

class Changes extends AppIcon {
  const Changes({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.changes);
}

class Charity extends AppIcon {
  const Charity({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.charity);
}

class Chart extends AppIcon {
  const Chart.line({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.line_chart);

  const Chart.pie({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.pie_chart);
}

class Chicken extends AppIcon {
  const Chicken({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.chicken);
}

class Check extends AppIcon {
  const Check({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.check);

  const Check.circled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.check_circled);
}

class CheckBox extends AppIcon {
  const CheckBox({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.checkbox);

  const CheckBox.filled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.checkbox_filled);
}

class CheckList extends AppIcon {
  const CheckList.document({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.checklist_document);

  const CheckList.twoLines({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.checklist_two_items);

  const CheckList.threeLines({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.checklist_three_items);
}

class Chef extends AppIcon {
  const Chef({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.chef);
}

class Chevron extends AppIcon {
  const Chevron.left({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 2,
       super._(_IconsFont.chevron_right);

  const Chevron.right({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 0,
       super._(_IconsFont.chevron_right);

  const Chevron.up({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 2,
       super._(_IconsFont.chevron_down);

  const Chevron.down({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 0,
       super._(_IconsFont.chevron_down);

  final int turns;

  static Chevron horizontalDirectional(
    BuildContext context, {
    Color? color,
    double? size,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) {
    return switch (Directionality.of(context)) {
      TextDirection.ltr => Chevron.right(
        color: color,
        size: size,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      ),
      TextDirection.rtl => Chevron.left(
        color: color,
        size: size,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(quarterTurns: turns, child: super.build(context));
  }
}

class CircledArrow extends AppIcon {
  const CircledArrow._base({
    required this.turns,
    CircledArrowType? type,
    this.circleColor,
    super.color,
    super.size,
    this.padding,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : assert(
         (circleColor == null &&
                 (type == null || type == CircledArrowType.thin)) ||
             (circleColor != null && type == CircledArrowType.normal),
         'circleColor is only supported and must be provided when type = CircledArrowType.normal',
       ),
       type = type ?? CircledArrowType.thin,
       super._(
         type == CircledArrowType.thin
             ? _IconsFont.circled_arrow
             : _IconsFont.arrow_right,
       );
  const CircledArrow.right({
    CircledArrowType? type,
    Color? circleColor,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) : this._base(
         type: type,
         turns: 0,
         circleColor: circleColor,
         color: color,
         size: size,
         padding: padding,
         shadow: shadow,
         semanticLabel: semanticLabel,
         key: key,
       );

  const CircledArrow.left({
    CircledArrowType? type,
    Color? circleColor,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) : this._base(
         type: type,
         turns: 2,
         circleColor: circleColor,
         color: color,
         size: size,
         padding: padding,
         shadow: shadow,
         semanticLabel: semanticLabel,
         key: key,
       );

  const CircledArrow.down({
    CircledArrowType? type,
    Color? circleColor,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) : this._base(
         type: type,
         turns: 1,
         circleColor: circleColor,
         color: color,
         size: size,
         padding: padding,
         shadow: shadow,
         semanticLabel: semanticLabel,
         key: key,
       );

  const CircledArrow.up({
    CircledArrowType? type,
    Color? circleColor,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) : this._base(
         type: type,
         turns: 3,
         circleColor: circleColor,
         color: color,
         size: size,
         padding: padding,
         shadow: shadow,
         semanticLabel: semanticLabel,
         key: key,
       );

  static CircledArrow horizontalDirectional(
    BuildContext context, {
    CircledArrowType? type,
    Color? circleColor,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) {
    return switch (Directionality.of(context)) {
      TextDirection.ltr => CircledArrow.right(
        type: type,
        circleColor: circleColor,
        color: color,
        size: size,
        padding: padding,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      ),
      TextDirection.rtl => CircledArrow.left(
        type: type,
        circleColor: circleColor,
        color: color,
        size: size,
        padding: padding,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      ),
    };
  }

  final int turns;
  final CircledArrowType type;
  final Color? circleColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Widget child = RotatedBox(
      quarterTurns: turns,
      child: super.build(context),
    );

    if (type == CircledArrowType.normal) {
      return Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
        padding:
            padding ??
            const EdgeInsetsDirectional.only(
              start: 4.1,
              end: 3.9,
              top: 4.0,
              bottom: 4.0,
            ),
        child: child,
      );
    } else {
      return child;
    }
  }

  @override
  double? get size =>
      type == CircledArrowType.thin ? super.size : ((super.size ?? 20.0) - 8.0);
}

enum CircledArrowType { thin, normal }

class City extends AppIcon {
  const City({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.city);
}

class ClearText extends AppIcon {
  const ClearText({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clear_text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Fake it's centered
      padding: const EdgeInsetsDirectional.only(end: 1.0),
      child: super.build(context),
    );
  }
}

class Clear extends AppIcon {
  const Clear({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clear);
}

class Clipboard extends AppIcon {
  const Clipboard({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clipboard);

  const Clipboard.down({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clipboard_down);

  const Clipboard.left({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clipboard_left);

  const Clipboard.right({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clipboard_right);
}

class Clock extends AppIcon {
  const Clock({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clock);

  const Clock.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.clock_alt);
}

class Close extends AppIcon {
  const Close({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.close);

  const Close.bold({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.close_bold);

  const Close.circled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.close_circled);
}

class Copy extends AppIcon {
  const Copy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.copy);
}

class Coffee extends AppIcon {
  const Coffee.love({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.coffee_love);
}

class Community extends AppIcon {
  const Community.contribute({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.community_contribute);

  const Community.help({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.community_help);

  const Community.ideas({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.community_ideas);
}

class Compare extends AppIcon {
  const Compare({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.compare);

  const Compare.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.compare_alt);

  const Compare.disabled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.compare_disabled);
}

class Compass extends AppIcon {
  const Compass({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.compass);
}

class Collapse extends AppIcon {
  const Collapse({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.collapse);
}

class Construction extends AppIcon {
  const Construction({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.construction);
}

class Contribute extends AppIcon {
  const Contribute({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.contribute);
}

class Countries extends AppIcon {
  const Countries({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.countries);

  const Countries.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.country);
}

class Cupcake extends AppIcon {
  const Cupcake({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.cupcake);
}

class Crash extends AppIcon {
  const Crash({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.crash);
}

class CreativeCommons extends AppIcon {
  const CreativeCommons.logo({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.creative_commons);

  const CreativeCommons.attribution({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.creative_commons_attribution);

  const CreativeCommons.shareAlike({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.creative_commons_share_alike);
}

class Crop extends AppIcon {
  const Crop({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.crop);
}

class CrossWalk extends AppIcon {
  const CrossWalk({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.crosswalk);
}

class Currency extends AppIcon {
  const Currency({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.currency);
}

class DangerousZone extends AppIcon {
  const DangerousZone({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.dangerous_zone);
}

class Debug extends AppIcon {
  const Debug({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.debug);
}

class Discover extends AppIcon {
  const Discover({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.discover);
}

class Document extends AppIcon {
  const Document({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.document);

  const Document.sparkles({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.document_sparkles);
}

class Donate extends AppIcon {
  const Donate({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.donate);
}

class DoubleChevron extends AppIcon {
  const DoubleChevron.left({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 3,
       super._(_IconsFont.double_chevron);

  const DoubleChevron.right({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 1,
       super._(_IconsFont.double_chevron);

  const DoubleChevron.up({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 0,
       super._(_IconsFont.double_chevron);

  const DoubleChevron.down({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 2,
       super._(_IconsFont.double_chevron);

  final int turns;

  static DoubleChevron horizontalDirectional(
    BuildContext context, {
    Color? color,
    double? size,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) {
    return switch (Directionality.of(context)) {
      TextDirection.ltr => DoubleChevron.right(
        color: color,
        size: size,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      ),
      TextDirection.rtl => DoubleChevron.left(
        color: color,
        size: size,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(quarterTurns: turns, child: super.build(context));
  }
}

class Download extends AppIcon {
  const Download({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.download);
}

class Drag extends AppIcon {
  const Drag.start({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.drag_start);
}

class Edit extends AppIcon {
  const Edit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.edit);
}

class Environment extends AppIcon {
  const Environment({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.environment);

  const Environment.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.environment_alt);
}

class ExternalLink extends AppIcon {
  const ExternalLink({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.external_link);

  const ExternalLink.bold({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.external_link_alt);
}

class Expand extends AppIcon {
  const Expand({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.expand);
}

class Eye extends AppIcon {
  const Eye.checkbox({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.eye_checkbox);

  const Eye.invisible({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.eye_invisible);

  const Eye.visible({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.eye_visible);

  const Eye.visuallyImpaired({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.eye_visually_impaired);
}

class Factory extends AppIcon {
  const Factory({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.factory_icon);
}

class Faq extends AppIcon {
  const Faq({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.faq);
}

class Farmer extends AppIcon {
  const Farmer({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.farmer);
}

class Favorite extends AppIcon {
  const Favorite.check({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.favorite_check);

  const Favorite.star({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.favorite_star);
}

class Feedback extends AppIcon {
  const Feedback({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.feedback);

  const Feedback.form({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.feedback_form);
}

class Fish extends AppIcon {
  const Fish({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.fish);
}

class Flag extends AppIcon {
  const Flag({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.flag);

  const Flag.checked({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.checked_flag);
}

class Forum extends AppIcon {
  const Forum({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.forum);
}

class Fruit extends AppIcon {
  const Fruit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.fruit);
}

class Garden extends AppIcon {
  const Garden({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.garden);
}

class Gears extends AppIcon {
  const Gears({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.gears);
}

class GitHub extends AppIcon {
  const GitHub({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.github);
}

class Globe extends AppIcon {
  const Globe({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.globe);
}

class Graph extends AppIcon {
  const Graph({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.graph);
}

class HappyJam extends AppIcon {
  const HappyJam({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.happy_jam);
}

class HappyToast extends AppIcon {
  const HappyToast({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.happy_toast);
}

class History extends AppIcon {
  const History({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.history);
}

class Heart extends AppIcon {
  const Heart.filled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.heart_filled);

  const Heart.monitoring({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.heart_monitor);

  const Heart.outline({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.heart_outline);
}

class Help extends AppIcon {
  const Help({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.help_circled);
}

class HourGlass extends AppIcon {
  const HourGlass({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.hour_glass);
}

class ImageGallery extends AppIcon {
  const ImageGallery({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.gallery);
}

class Import extends AppIcon {
  const Import({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.import_icon);
}

class Incognito extends AppIcon {
  const Incognito({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.incognito);
}

class Incomplete extends AppIcon {
  const Incomplete({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.incomplete);
}

class Indicator extends AppIcon {
  const Indicator.horizontalBar({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.horizontal_bar_indicator);
}

class Ingredients extends AppIcon {
  const Ingredients({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.ingredients);

  const Ingredients.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.ingredients_alt);

  const Ingredients.basket({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.ingredients_basket);
}

class Info extends AppIcon {
  const Info({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.info);
}

class Lab extends AppIcon {
  const Lab({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.lab);

  const Lab.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.lab_alt);
}

class Labels extends AppIcon {
  const Labels({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.labels);
}

class Language extends AppIcon {
  const Language({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.language);

  const Language.world({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.language_world);
}

class Law extends AppIcon {
  const Law({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.law);
}

class Lifebuoy extends AppIcon {
  const Lifebuoy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.lifebuoy);
}

class Lifecycle extends AppIcon {
  const Lifecycle({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.lifecycle);
}

class LightBulb extends AppIcon {
  const LightBulb({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.light_bulb);
}

class Lists extends AppIcon {
  const Lists({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.lists);
}

class Location extends AppIcon {
  const Location({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.location);
}

class Logo extends AppIcon {
  const Logo.openBeautyFacts({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.logo_obf);

  const Logo.openFoodFacts({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.logo_off);

  const Logo.openPetFoodFacts({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.logo_opff);

  const Logo.openProductsFacts({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.logo_opf);
}

class Logout extends AppIcon {
  const Logout({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.logout);
}

class LoyaltyCard extends AppIcon {
  const LoyaltyCard({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.loyalty_card);
}

class MagicWand extends AppIcon {
  const MagicWand({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.magic_wand);
}

class Megaphone extends AppIcon {
  const Megaphone({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.megaphone);
}

class Menu extends AppIcon {
  const Menu.hamburger({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.hamburger_menu);
}

class Message extends AppIcon {
  const Message({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.message);

  const Message.edit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.message_edit);
}

class Milk extends AppIcon {
  const Milk({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk);

  const Milk.add({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_add);

  const Milk.camera({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_camera);

  const Milk.certification({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_certification);

  const Milk.check({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_check);

  const Milk.download({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_download);

  const Milk.edit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_edit);

  const Milk.error({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_error);

  const Milk.eye({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_eye);

  const Milk.happy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_filled);

  const Milk.incomplete({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_incomplete);

  const Milk.newIcon({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_new);

  const Milk.upload({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_upload);

  const Milk.unhappy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.milk_filled_unhappy);
}

class Monkey extends AppIcon {
  const Monkey.happy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.monkey_happy);

  const Monkey.sad({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.monkey_sad);

  const Monkey.wondering({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.monkey_wondering);
}

class Move extends AppIcon {
  const Move({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.move);
}

class NewLabel extends AppIcon {
  const NewLabel({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.new_label);
}

class Newsletter extends AppIcon {
  const Newsletter({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.newsletter);
}

class NoPicture extends AppIcon {
  const NoPicture({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.no_picture);
}

class NutritionFacts extends AppIcon {
  const NutritionFacts({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.nutrition_facts);

  const NutritionFacts.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.nutritional_facts);
}

class OCR extends AppIcon {
  const OCR({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.ocr);
}

class Offline extends AppIcon {
  const Offline({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.offline);
}

class Origins extends AppIcon {
  const Origins({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.origins);
}

class OSMLogo extends AppIcon {
  const OSMLogo({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.osm);
}

class Outdated extends AppIcon {
  const Outdated({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.outdated);
}

class Packaging extends AppIcon {
  const Packaging({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.packaging);
}

class Panel extends AppIcon {
  const Panel({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.panel);
}

class Partners extends AppIcon {
  const Partners({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.partners);
}

class Password extends AppIcon {
  const Password.lock({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.password);
}

class Personalization extends AppIcon {
  const Personalization({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.personalization);

  const Personalization.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.personalization_alt);
}

class Picture extends AppIcon {
  const Picture.add({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.image_add);

  const Picture.check({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.image_check);

  const Picture.error({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.image_error);

  const Picture.open({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.image_open);
}

class PiggyBank extends AppIcon {
  const PiggyBank({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.piggy_bank);

  const PiggyBank.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.piggy_bank_new);
}

class PinchToZoom extends AppIcon {
  const PinchToZoom({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.pinch_to_zoom);
}

class Plant extends AppIcon {
  const Plant({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.plant);
}

class Podium extends AppIcon {
  const Podium({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.podium);
}

class PostalCode extends AppIcon {
  const PostalCode({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.postal_code);
}

class News extends AppIcon {
  const News.paper({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.newspaper);

  const News.press({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.press);
}

class PriceTag extends AppIcon {
  const PriceTag({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.price_tag_dollar);
}

class PriceReceipt extends AppIcon {
  const PriceReceipt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.price_receipt);

  const PriceReceipt.add({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.price_receipt_add);
}

class Producer extends AppIcon {
  const Producer({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.producer);
}

class Profile extends AppIcon {
  const Profile({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.profile);
}

class Programming extends AppIcon {
  const Programming({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.programming);
}

class Proof extends AppIcon {
  const Proof({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.proofs);
}

class Question extends AppIcon {
  const Question({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.question);

  const Question.circled({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.question_circled);
}

class Recipe extends AppIcon {
  const Recipe({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.recipe);
}

class Recycling extends AppIcon {
  const Recycling({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.recycling);
}

class Redo extends AppIcon {
  const Redo({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.redo);
}

class Reload extends AppIcon {
  const Reload({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.reload);
}

class Remove extends AppIcon {
  const Remove({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.remove);
}

class Reset extends AppIcon {
  const Reset({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.reset);

  const Reset.reinit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.reinit);
}

class Robot extends AppIcon {
  const Robot({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.robot);
}

class Rotate extends AppIcon {
  const Rotate.clockwise({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.rotate_cw);

  const Rotate.antiClockwise({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.rotate_ccw);
}

class Salt extends AppIcon {
  const Salt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.salt);
}

class Scale extends AppIcon {
  const Scale({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.scale);

  const Scale.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.scale_alt);
}

class Share extends AppIcon {
  factory Share({
    Color? color,
    double? size,
    Shadow? shadow,
    String? semanticLabel,
    Key? key,
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      return Share.cupertino(
        color: color,
        size: size,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      );
    } else {
      return Share.material(
        color: color,
        size: size,
        shadow: shadow,
        semanticLabel: semanticLabel,
        key: key,
      );
    }
  }

  const Share.material({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.share_material);

  const Share.cupertino({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.share_cupertino);
}

class Shapes extends AppIcon {
  const Shapes({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.shapes);
}

class Search extends AppIcon {
  const Search({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.search);

  const Search.advanced({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.advanced_search);

  const Search.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.search_alt);

  const Search.database({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.database_search);

  const Search.off({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.search_off);

  const Search.offRounded({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.search_off_rounded);
}

class Select extends AppIcon {
  const Select.photo({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.photo_select);
}

class Send extends AppIcon {
  const Send({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.send);
}

class Settings extends AppIcon {
  const Settings({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.settings);
}

class Shop extends AppIcon {
  const Shop({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.shop);
}

class Shopping extends AppIcon {
  const Shopping.bag({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.shopping_bag);

  const Shopping.cart({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.shopping_cart);
}

class SocialNetwork extends AppIcon {
  const SocialNetwork.bluesky({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.bluesky);

  const SocialNetwork.instagram({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.instagram);

  const SocialNetwork.mastodon({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.mastodon);

  const SocialNetwork.tiktok({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.tiktok);

  const SocialNetwork.slack({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.slack);

  const SocialNetwork.twitter({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.twitter);
}

class Soda extends AppIcon {
  const Soda.happy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.soda_happy);

  const Soda.unhappy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.soda_unhappy);
}

class Sort extends AppIcon {
  const Sort({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.sort);
}

class Sound extends AppIcon {
  const Sound.on({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.sound_on);

  const Sound.off({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.sound_off);
}

class Sparkles extends AppIcon {
  const Sparkles({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.sparkles);
}

class SpellChecker extends AppIcon {
  const SpellChecker({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.spell_checker);
}

class Split extends AppIcon {
  const Split({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.split);
}

class Status extends AppIcon {
  const Status({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.status);
}

class Street extends AppIcon {
  const Street({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.street);
}

class Strength extends AppIcon {
  const Strength({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.strength);
}

class StopSign extends AppIcon {
  const StopSign({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.stop_sign);
}

class Stores extends AppIcon {
  const Stores({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.store);
}

class Student extends AppIcon {
  const Student({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.student);
}

class Suggestion extends AppIcon {
  const Suggestion({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.suggestion);
}

class Switches extends AppIcon {
  const Switches({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.switches);
}

class Team extends AppIcon {
  const Team({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.team);
}

class Thumb extends AppIcon {
  const Thumb.down({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.thumb_down);

  const Thumb.up({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.thumb_up);
}

class Traces extends AppIcon {
  const Traces({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.traces);
}

class TrafficLights extends AppIcon {
  const TrafficLights({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.traffic_lights);
}

class Trash extends AppIcon {
  const Trash({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.trash);

  const Trash.clear({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.trash_clear);

  const Trash.delete({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.trash_delete);
}

class ThreeDots extends AppIcon {
  const ThreeDots.vertical({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 0,
       super._(_IconsFont.dots_vertical);

  const ThreeDots.horizontal({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : turns = 1,
       super._(_IconsFont.dots_vertical);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(quarterTurns: turns, child: super.build(context));
  }
}

class ToggleCamera extends AppIcon {
  const ToggleCamera({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.toggle_camera);
}

class Toolbox extends AppIcon {
  const Toolbox({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.toolbox);
}

class Torch extends AppIcon {
  const Torch.on({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.torch_on);

  const Torch.off({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.torch_off);
}

class Trophy extends AppIcon {
  const Trophy({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.trophy);
}

class Undo extends AppIcon {
  const Undo({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.undo);
}

class Unselect extends AppIcon {
  const Unselect({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.unselect);
}

class Upload extends AppIcon {
  const Upload({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.upload);

  const Upload.bulk({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.upload_bulk);
}

class User extends AppIcon {
  const User.edit({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.user_edit);

  const User.question({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.user_question);
}

class Vibration extends AppIcon {
  const Vibration({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.vibration);
}

class Vision extends AppIcon {
  const Vision({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.vision);
}

class Warning extends AppIcon {
  const Warning({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.warning);
}

class Weight extends AppIcon {
  const Weight({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.weight);

  const Weight.alt({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.weight_alt);
}

class Wizard extends AppIcon {
  const Wizard({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.wizard);
}

class World extends AppIcon {
  const World.help({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.world_help);

  const World.location({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.worldwide_location);
}

class Zoom extends AppIcon {
  const Zoom({
    super.color,
    super.size,
    super.shadow,
    super.semanticLabel,
    super.key,
  }) : super._(_IconsFont.zoom);
}

abstract class AppIcon extends StatelessWidget {
  const AppIcon._(
    this.icon, {
    Color? color,
    this.shadow,
    double? size,
    this.semanticLabel,
    super.key,
  }) : _size = size,
       _color = color,
       assert(size == null || size >= 0);

  final IconData icon;
  final Color? _color;
  final double? _size;
  final Shadow? shadow;
  final String? semanticLabel;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (size == 0.0) {
      return const SizedBox.shrink();
    }

    final AppIconTheme? iconTheme = AppIconTheme.maybeOf(context);
    final IconThemeData iconThemeData = IconTheme.of(context);
    final Color? color = switch (this.color) {
      Color _ => this.color,
      _ =>
        iconTheme?.color ??
            iconThemeData.color ??
            Theme.of(context).iconTheme.color,
    };

    return Icon(
      icon,
      color: color,
      size: size ?? iconTheme?.size ?? iconThemeData.size,
      semanticLabel: iconTheme?.semanticLabel ?? semanticLabel,
      shadows: shadow != null
          ? <Shadow>[shadow!]
          : iconTheme?.shadow != null
          ? <Shadow>[iconTheme!.shadow!]
          : null,
    );
  }

  /// Allow to override the size by a children
  double? get size => _size;

  /// Allow to override the color tint by a children
  Color? get color => _color;
}

/// Allows to override the default theme of an [AppIcon]
/// If not provided, the default [IconTheme] will be used (which lacks a [shadow])
class AppIconTheme extends InheritedWidget {
  const AppIconTheme({
    required super.child,
    super.key,
    this.color,
    this.size,
    this.shadow,
    this.semanticLabel,
  });

  final Color? color;
  final double? size;
  final Shadow? shadow;
  final String? semanticLabel;

  static AppIconTheme of(BuildContext context) {
    final AppIconTheme? result = maybeOf(context);
    assert(result != null, 'No AppIconTheme found in context');
    return result!;
  }

  static AppIconTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppIconTheme>();
  }

  @override
  bool updateShouldNotify(AppIconTheme oldWidget) {
    return color != oldWidget.color ||
        size != oldWidget.size ||
        semanticLabel != oldWidget.semanticLabel ||
        shadow != oldWidget.shadow ||
        shadow != oldWidget.shadow;
  }
}
