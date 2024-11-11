import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;

part 'app_icons_font.dart';

class Add extends AppIcon {
  const Add({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add);
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
    super.key,
  }) : super._(_IconsFont.add_price_british_pound);

  const AddPrice.dollar({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_dollar);

  const AddPrice.euro({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_euro);

  const AddPrice.ruble({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_ruble);

  const AddPrice.rupee({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_rupee);

  const AddPrice.swissFranc({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_swiss_franc);

  const AddPrice.turkishLira({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_turkish_lira);

  const AddPrice.ukrainianHryvnia({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_ukrainian_hryvnia);

  const AddPrice.won({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_won);

  const AddPrice.yen({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_price_yen);
}

class AddToList extends AppIcon {
  const AddToList({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.add_to_list);
}

class AppStore extends AppIcon {
  const AppStore({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.app_store);
}

class Arrow extends AppIcon {
  const Arrow.right({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 0,
        super._(_IconsFont.arrow_right);

  const Arrow.left({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 2,
        super._(_IconsFont.arrow_right);

  const Arrow.down({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 1,
        super._(_IconsFont.arrow_right);

  const Arrow.up({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 3,
        super._(_IconsFont.arrow_right);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: turns,
      child: super.build(context),
    );
  }
}

class Barcode extends AppIcon {
  const Barcode({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.barcode);

  const Barcode.rounded({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.barcode_rounded);

  const Barcode.withCorners({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.barcode_corners);
}

class Camera extends AppIcon {
  const Camera.filled({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.camera_filled);

  const Camera.outlined({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.camera_outlined);

  const Camera.happy({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.camera_happy);
}

class Categories extends AppIcon {
  const Categories({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.categories);
}

class Chicken extends AppIcon {
  const Chicken({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.chicken);
}

class Check extends AppIcon {
  const Check({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.check);
}

class Chevron extends AppIcon {
  const Chevron.left({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 2,
        super._(_IconsFont.chevron_right);

  const Chevron.right({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 0,
        super._(_IconsFont.chevron_right);

  const Chevron.up({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 2,
        super._(_IconsFont.chevron_down);

  const Chevron.down({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 0,
        super._(_IconsFont.chevron_down);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: turns,
      child: super.build(context),
    );
  }
}

class ClearText extends AppIcon {
  const ClearText({
    super.color,
    super.size,
    super.shadow,
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

class CircledArrow extends AppIcon {
  const CircledArrow.right({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 0,
        super._(_IconsFont.circled_arrow);

  const CircledArrow.left({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 2,
        super._(_IconsFont.circled_arrow);

  const CircledArrow.down({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 1,
        super._(_IconsFont.circled_arrow);

  const CircledArrow.up({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 3,
        super._(_IconsFont.circled_arrow);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: turns,
      child: super.build(context),
    );
  }
}

class Close extends AppIcon {
  const Close({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.close);
}

class Compare extends AppIcon {
  const Compare({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.compare);
}

class Contribute extends AppIcon {
  const Contribute({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.contribute);
}

class Countries extends AppIcon {
  const Countries({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.countries);

  const Countries.alt({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.country);
}

class Cupcake extends AppIcon {
  const Cupcake({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.cupcake);
}

class Crash extends AppIcon {
  const Crash({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.crash);
}

class Currency extends AppIcon {
  const Currency({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.currency);
}

class DangerousZone extends AppIcon {
  const DangerousZone({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.dangerous_zone);
}

class Delete extends AppIcon {
  const Delete.trash({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.delete_trash);
}

class Document extends AppIcon {
  const Document({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.document);
}

class Donate extends AppIcon {
  const Donate({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.donate);
}

class DoubleChevron extends AppIcon {
  const DoubleChevron.left({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 3,
        super._(_IconsFont.double_chevron);

  const DoubleChevron.right({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 1,
        super._(_IconsFont.double_chevron);

  const DoubleChevron.up({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 0,
        super._(_IconsFont.double_chevron);

  const DoubleChevron.down({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 2,
        super._(_IconsFont.double_chevron);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: turns,
      child: super.build(context),
    );
  }
}

class Edit extends AppIcon {
  const Edit({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.edit);
}

class Environment extends AppIcon {
  const Environment({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.environment);
}

class ExternalLink extends AppIcon {
  const ExternalLink({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.external_link);
}

class Expand extends AppIcon {
  const Expand({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.expand);
}

class Eye extends AppIcon {
  const Eye.visible({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.eye_visible);

  const Eye.invisible({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.eye_invisible);
}

class Fish extends AppIcon {
  const Fish({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.fish);
}

class Fruit extends AppIcon {
  const Fruit({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.fruit);
}

class GitHub extends AppIcon {
  const GitHub({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.github);
}

class Info extends AppIcon {
  const Info({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.info);
}

class HappyToast extends AppIcon {
  const HappyToast({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.happy_toast);
}

class History extends AppIcon {
  const History({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.history);
}

class Help extends AppIcon {
  const Help({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.help_circled);
}

class Incognito extends AppIcon {
  const Incognito({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.incognito);
}

class Ingredients extends AppIcon {
  const Ingredients({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.ingredients);

  const Ingredients.basket({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.ingredients_basket);
}

class Lab extends AppIcon {
  const Lab({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.lab);
}

class Labels extends AppIcon {
  const Labels({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.labels);
}

class Language extends AppIcon {
  const Language({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.language);

  const Language.world({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.language_world);
}

class Lifebuoy extends AppIcon {
  const Lifebuoy({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.lifebuoy);
}

class LightBulb extends AppIcon {
  const LightBulb({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.light_bulb);
}

class Logout extends AppIcon {
  const Logout({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.logout);
}

class MagicWand extends AppIcon {
  const MagicWand({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.magic_wand);
}

class Menu extends AppIcon {
  const Menu.hamburger({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.hamburger_menu);
}

class Milk extends AppIcon {
  const Milk({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.milk);
}

class NoPicture extends AppIcon {
  const NoPicture({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.no_picture);
}

class NutritionFacts extends AppIcon {
  const NutritionFacts({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.nutrition_facts);

  const NutritionFacts.alt({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.nutritional_facts);
}

class Outdated extends AppIcon {
  const Outdated({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.outdated);
}

class Packaging extends AppIcon {
  const Packaging({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.packaging);
}

class Password extends AppIcon {
  const Password.lock({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.password);
}

class Personalization extends AppIcon {
  const Personalization({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.personalization);

  const Personalization.alt({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.personalization_alt);
}

class Picture extends AppIcon {
  const Picture.add({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.image_add);

  const Picture.check({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.image_check);
}

class Programming extends AppIcon {
  const Programming({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.programming);
}

class Question extends AppIcon {
  const Question({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.question);

  const Question.circled({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.question_circled);
}

class QRCode extends AppIcon {
  const QRCode({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.qrcode);

  const QRCode.withCorners({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.qrcode_corners);
}

class Salt extends AppIcon {
  const Salt({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.salt);
}

class Share extends AppIcon {
  factory Share({
    Color? color,
    double? size,
    Shadow? shadow,
    Key? key,
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      return Share.cupertino(
        color: color,
        size: size,
        shadow: shadow,
        key: key,
      );
    } else {
      return Share.material(
        color: color,
        size: size,
        shadow: shadow,
        key: key,
      );
    }
  }

  const Share.material({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.share_material);

  const Share.cupertino({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.share_cupertino);
}

class Search extends AppIcon {
  const Search({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.search);

  const Search.advanced({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.advanced_search);
}

class Settings extends AppIcon {
  const Settings({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.settings);
}

class Soda extends AppIcon {
  const Soda.happy({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.soda_happy);

  const Soda.unhappy({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.soda_unhappy);
}

class Sound extends AppIcon {
  const Sound.on({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.sound_on);

  const Sound.off({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.sound_off);
}

class Sparkles extends AppIcon {
  const Sparkles({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.sparkles);
}

class Stores extends AppIcon {
  const Stores({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.store);
}

class Suggestion extends AppIcon {
  const Suggestion({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.suggestion);
}

class ThreeDots extends AppIcon {
  const ThreeDots.vertical({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 0,
        super._(_IconsFont.dots_vertical);

  const ThreeDots.horizontal({
    super.color,
    super.size,
    super.shadow,
    super.key,
  })  : turns = 1,
        super._(_IconsFont.dots_vertical);

  final int turns;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: turns,
      child: super.build(context),
    );
  }
}

class ToggleCamera extends AppIcon {
  const ToggleCamera({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.toggle_camera);
}

class Torch extends AppIcon {
  const Torch.on({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.torch_on);

  const Torch.off({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.torch_off);
}

class Vibration extends AppIcon {
  const Vibration({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.vibration);
}

class Warning extends AppIcon {
  const Warning({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super._(_IconsFont.warning);
}

abstract class AppIcon extends StatelessWidget {
  const AppIcon._(
    this.icon, {
    this.color,
    this.shadow,
    this.size,
    this.semanticLabel,
    super.key,
  }) : assert(size == null || size >= 0);

  final IconData icon;
  final Color? color;
  final double? size;
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
      _ => iconTheme?.color ??
          iconThemeData.color ??
          Theme.of(context).iconTheme.color,
    };

    return Icon(
      icon,
      color: color,
      size: size ?? iconTheme?.size,
      semanticLabel: iconTheme?.semanticLabel ?? semanticLabel,
      shadows: shadow != null
          ? <Shadow>[shadow!]
          : iconTheme?.shadow != null
              ? <Shadow>[iconTheme!.shadow!]
              : null,
    );
  }
}

/// Allows to override the default theme of an [AppIcon]
/// If not provided, the default [IconTheme] will be used (which lacks a [shadow])
class AppIconTheme extends InheritedWidget {
  const AppIconTheme({
    super.key,
    required super.child,
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
        semanticLabel != oldWidget.semanticLabel ||
        shadow != oldWidget.shadow ||
        shadow != oldWidget.shadow;
  }
}
