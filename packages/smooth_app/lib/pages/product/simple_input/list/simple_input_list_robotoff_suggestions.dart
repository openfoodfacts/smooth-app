import 'package:animated_line_through/animated_line_through.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/hunger_games/question_image_full_page.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SimpleInputListRobotoffSuggestions extends StatelessWidget {
  const SimpleInputListRobotoffSuggestions({
    required this.helper,
    super.key,
  });

  final AbstractSimpleInputPageHelper helper;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>
        questionsNotifier = context
            .watch<ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>>();

    final Map<RobotoffQuestion, InsightAnnotation?> questions =
        questionsNotifier.value;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.only(
        top: questions.isEmpty ? 0.0 : MEDIUM_SPACE,
      ),
      itemCount: questions.entries.length,
      itemBuilder: (BuildContext context, int position) {
        final MapEntry<RobotoffQuestion, InsightAnnotation?> entry =
            questions.entries.elementAt(position);

        return MultiProvider(
          providers: <SingleChildWidget>[
            Provider<InsightAnnotation?>.value(
              value: entry.value,
            ),
            Provider<RobotoffQuestion>.value(
              value: entry.key,
            ),
          ],
          child: _SimpleInputListRobotoffSuggestion(
            onChanged: (bool? value) {
              helper.answerRobotoffQuestion(
                entry.key,
                value == true
                    ? InsightAnnotation.YES
                    : value == false
                        ? InsightAnnotation.NO
                        : null,
              );
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int position) {
        if (questions.values.elementAt(position + 1) != null) {
          return EMPTY_WIDGET;
        }

        final SmoothColorsThemeExtension extension =
            context.extension<SmoothColorsThemeExtension>();
        final bool lightTheme = context.lightTheme();

        return Divider(
          height: 0.0,
          thickness: 1.0,
          color:
              lightTheme ? extension.primaryLight : extension.primaryUltraBlack,
        );
      },
      shrinkWrap: true,
    );
  }
}

class _SimpleInputListRobotoffSuggestion extends StatefulWidget {
  const _SimpleInputListRobotoffSuggestion({
    required this.onChanged,
  });

  final Function(bool? value) onChanged;

  @override
  State<_SimpleInputListRobotoffSuggestion> createState() =>
      _SimpleInputListRobotoffSuggestionState();
}

class _SimpleInputListRobotoffSuggestionState
    extends State<_SimpleInputListRobotoffSuggestion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _imageController;
  late final Animation<double> _pictureAnimation;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      duration: SmoothAnimationsDuration.short,
      vsync: this,
    )..addListener(() => setState(() {}));
    _pictureAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: Curves.easeInOut,
      ),
    );

    // Disable the image by default
    _imageController.forward(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(
        color: Colors.black,
      ),
      child: SizedBox(
        height: 50.0 + (130.0 * _pictureAnimation.value),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Consumer<RobotoffQuestion>(
                builder: (
                  BuildContext context,
                  RobotoffQuestion question,
                  _,
                ) {
                  if (question.imageUrl?.isEmpty == true) {
                    return EMPTY_WIDGET;
                  }

                  return Offstage(
                    offstage: _pictureAnimation.value == 0.0,
                    child: _SimpleInputListRobotoffSuggestionPicture(
                        onTap: (String heroTag) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              QuestionImageFullPage(
                            question: question,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            PositionedDirectional(
              start: 0.0,
              end: 0.0,
              top: 0.0,
              height: 50.0,
              child: _SimpleInputListRobotoffSuggestionHeader(
                onValueChanged: _onValueChanged,
                togglePicture: () {
                  if (_pictureAnimation.value == 0.0) {
                    _imageController.reverse();
                  } else {
                    _imageController.forward();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onValueChanged(bool? newValue) {
    final InsightAnnotation? annotation = context.read<InsightAnnotation?>();

    if (annotation != null &&
        ((newValue == true && annotation == InsightAnnotation.YES) ||
            (newValue == false && annotation == InsightAnnotation.NO))) {
      widget.onChanged(null);
      SmoothHapticFeedback.lightNotificationTwice();
    } else {
      widget.onChanged(newValue);
      SmoothHapticFeedback.lightNotification();
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }
}

class _SimpleInputListRobotoffSuggestionHeader extends StatefulWidget {
  const _SimpleInputListRobotoffSuggestionHeader({
    required this.togglePicture,
    required this.onValueChanged,
  });

  final VoidCallback togglePicture;
  final Function(bool?) onValueChanged;

  @override
  State<_SimpleInputListRobotoffSuggestionHeader> createState() =>
      _SimpleInputListRobotoffSuggestionHeaderState();
}

class _SimpleInputListRobotoffSuggestionHeaderState
    extends State<_SimpleInputListRobotoffSuggestionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _valueController;
  late final Animation<double> _valueAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _valueController = AnimationController(
      duration: SmoothAnimationsDuration.short,
      vsync: this,
    )..addListener(() => setState(() {}));

    _valueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _valueController,
        curve: Curves.easeInOut,
      ),
    );
    _colorAnimation = ColorTween(
      begin: null,
      end: null,
    ).animate(_valueController);

    // Use the default background
    _valueController.reverse(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final InsightAnnotation? annotation = context.watch<InsightAnnotation?>();

    return Listener<InsightAnnotation?>(
      listener: (
        BuildContext context,
        InsightAnnotation? previousValue,
        InsightAnnotation? currentValue,
      ) {
        if (previousValue != currentValue) {
          _colorAnimation = ColorTween(
            begin: _getTextColor(previousValue, lightTheme),
            end: _getTextColor(currentValue, lightTheme),
          ).animate(_valueController);

          if (currentValue != null) {
            _valueController.forward();
          } else if (currentValue == null) {
            _valueController.reverse();
          }
        }
      },
      child: Material(
        color: Color.lerp(
          lightTheme ? extension.primaryMedium : extension.primarySemiDark,
          lightTheme
              ? const Color(0xEAFFFFFF)
              : extension.primaryUltraBlack.withValues(alpha: 0.9),
          _valueAnimation.value,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: context.lightTheme() ? Colors.black : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 10.0,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      borderRadius: ANGULAR_BORDER_RADIUS,
                      onTap: widget.togglePicture,
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 10.0),
                          ExcludeSemantics(
                            child: SparkleAnimation(
                              type: SparkleAnimationType.grow,
                              color: _getTextColor(annotation, lightTheme),
                              size: 18.0,
                              animated: annotation == null,
                            ),
                          ),
                          const SizedBox(width: SMALL_SPACE),
                          Expanded(
                            child: AnimatedLineThrough(
                              isCrossed: annotation == InsightAnnotation.NO,
                              duration: SmoothAnimationsDuration.short,
                              color: lightTheme ? Colors.black : Colors.white,
                              child: Consumer<RobotoffQuestion>(
                                builder: (_, RobotoffQuestion question, __) {
                                  return AutoSizeText(
                                    question.value!,
                                    style: TextTheme.of(context)
                                        .bodyLarge
                                        ?.copyWith(
                                          color: _colorAnimation.value,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Tooltip(
                            message: appLocalizations
                                .product_edit_robotoff_show_proof,
                            child: const Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: MEDIUM_SPACE,
                                end: 9.0,
                                top: MEDIUM_SPACE,
                                bottom: 9.0,
                              ),
                              child: icons.Picture.open(size: 17.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _SimpleInputListRobotoffSuggestionButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 25.0,
                    ),
                    padding: const EdgeInsetsDirectional.all(7.5),
                    tooltip:
                        appLocalizations.edit_product_form_item_deny_suggestion,
                    onTap: () => widget.onValueChanged(false),
                    visibility: annotation == InsightAnnotation.NO
                        ? 1 - _valueAnimation.value
                        : 1.0,
                  ),
                  _SimpleInputListRobotoffSuggestionButton(
                    icon: const icons.Add(size: 20.0),
                    padding: const EdgeInsetsDirectional.all(10.0),
                    tooltip:
                        appLocalizations.edit_product_form_item_add_suggestion,
                    onTap: () => widget.onValueChanged(true),
                    visibility: annotation == InsightAnnotation.YES
                        ? 1 - _valueAnimation.value
                        : 1.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(InsightAnnotation? value, bool lightTheme) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return switch (value) {
      InsightAnnotation.YES =>
        lightTheme ? extension.success : extension.successBackground,
      InsightAnnotation.NO =>
        lightTheme ? extension.error : extension.errorBackground,
      _ => lightTheme ? Colors.black : Colors.white,
    };
  }
}

class _SimpleInputListRobotoffSuggestionButton extends StatelessWidget {
  const _SimpleInputListRobotoffSuggestionButton({
    required this.icon,
    required this.padding,
    required this.tooltip,
    required this.onTap,
    required this.visibility,
  });

  final Widget icon;
  final EdgeInsetsGeometry padding;
  final String tooltip;
  final VoidCallback onTap;
  final double visibility;

  @override
  Widget build(BuildContext context) {
    if (visibility == 0.0) {
      return EMPTY_WIDGET;
    }

    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Opacity(
          opacity: visibility,
          child: Padding(
            padding: padding,
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _SimpleInputListRobotoffSuggestionPicture extends StatelessWidget {
  const _SimpleInputListRobotoffSuggestionPicture({
    required this.onTap,
  });

  final Function(String heroTag) onTap;

  @override
  Widget build(BuildContext context) {
    final RobotoffQuestion question = context.watch<RobotoffQuestion>();

    final String? imageUrl = question.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return EMPTY_WIDGET;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String heroTag = '$imageUrl ${question.insightId}';

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Material(
            child: Hero(
              tag: heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: SmoothImage(
                  imageProvider: NetworkImage(imageUrl),
                  rounded: false,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          end: 0.0,
          bottom: 0.0,
          child: InkWell(
            onTap: () => onTap(heroTag),
            child: Tooltip(
              message: appLocalizations.product_edit_robotoff_expand_proof,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20.0,
                  vertical: MEDIUM_SPACE,
                ),
                child: const ExcludeSemantics(
                  child: icons.Expand(
                    color: Colors.white,
                    size: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
