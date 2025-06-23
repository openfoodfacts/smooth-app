import 'package:animated_line_through/animated_line_through.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/hunger_games/question_image_full_page.dart';
import 'package:smooth_app/pages/product/simple_input/list/suggestions/robotoff/robotoff_suggestion_item_button.dart';
import 'package:smooth_app/pages/product/simple_input/list/suggestions/robotoff/robotoff_suggestion_item_picture.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class RobotoffSuggestionListItem extends StatefulWidget {
  const RobotoffSuggestionListItem({required this.onChanged});

  final Function(bool? value) onChanged;

  @override
  State<RobotoffSuggestionListItem> createState() =>
      _RobotoffSuggestionListItemState();
}

class _RobotoffSuggestionListItemState extends State<RobotoffSuggestionListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _imageController;
  late final Animation<double> _pictureAnimation;

  @override
  void initState() {
    super.initState();

    _imageController =
        AnimationController(
            duration: SmoothAnimationsDuration.short,
            vsync: this,
          )
          ..addListener(() => setState(() {}))
          // Image is disabled by default
          ..value = 1.0;
    _pictureAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(color: Colors.black),
      child: SizedBox(
        height: 50.0 + (130.0 * _pictureAnimation.value),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Consumer<RobotoffQuestion>(
                builder: (BuildContext context, RobotoffQuestion question, _) {
                  if (question.imageUrl?.isEmpty == true) {
                    return EMPTY_WIDGET;
                  }

                  return Offstage(
                    offstage: _pictureAnimation.value == 0.0,
                    child: Opacity(
                      opacity: _pictureAnimation.value,
                      child: RobotoffSuggestionListItemPicture(
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
                        },
                      ),
                    ),
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

      // Hide the proof
      if (_imageController.value < 1.0) {
        _imageController.forward();
      }
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

    _valueController =
        AnimationController(
            duration: SmoothAnimationsDuration.short,
            vsync: this,
          )
          ..addListener(() => setState(() {}))
          ..value = 0.0;

    _valueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _valueController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: null,
      end: null,
    ).animate(_valueController);
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final InsightAnnotation? annotation = context.watch<InsightAnnotation?>();

    return Listener<InsightAnnotation?>(
      listener:
          (
            BuildContext context,
            InsightAnnotation? previousValue,
            InsightAnnotation? currentValue,
          ) => _updateAnimations(
            context,
            previousValue,
            currentValue,
            lightTheme,
          ),
      child: Material(
        color: Color.lerp(
          (lightTheme ? extension.primaryMedium : extension.primarySemiDark)
              .withValues(alpha: 0.9),
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
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
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
                          _RobotoffSuggestionSparkles(
                            status: _RobotoffSuggestionStatus.fromAnnotation(
                              annotation,
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
                                    style: TextTheme.of(context).bodyLarge
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
                  RobotoffSuggestionListItemButton(
                    icon: const Icon(Icons.delete, size: 25.0),
                    padding: const EdgeInsetsDirectional.all(7.5),
                    tooltip:
                        appLocalizations.edit_product_form_item_deny_suggestion,
                    onTap: () => widget.onValueChanged(false),
                    visible:
                        annotation == null ||
                        annotation == InsightAnnotation.YES,
                  ),
                  RobotoffSuggestionListItemButton(
                    icon: const icons.Add(size: 20.0),
                    padding: const EdgeInsetsDirectional.all(10.0),
                    tooltip:
                        appLocalizations.edit_product_form_item_add_suggestion,
                    onTap: () => widget.onValueChanged(true),
                    visible:
                        annotation == null ||
                        annotation == InsightAnnotation.NO,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateAnimations(
    BuildContext context,
    InsightAnnotation? previousValue,
    InsightAnnotation? currentValue,
    bool lightTheme,
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
  }

  Color _getTextColor(InsightAnnotation? value, bool lightTheme) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return switch (value) {
      InsightAnnotation.YES =>
        lightTheme ? extension.success : extension.successBackground,
      InsightAnnotation.NO =>
        lightTheme ? extension.error : extension.errorBackground,
      _ => lightTheme ? Colors.black : Colors.white,
    };
  }

  @override
  void dispose() {
    super.dispose();
    _valueController.dispose();
  }
}

class _RobotoffSuggestionSparkles extends StatefulWidget {
  const _RobotoffSuggestionSparkles({required this.status});

  final _RobotoffSuggestionStatus status;

  @override
  State<_RobotoffSuggestionSparkles> createState() =>
      _RobotoffSuggestionSparklesState();
}

class _RobotoffSuggestionSparklesState
    extends State<_RobotoffSuggestionSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Color?> _circleColorAnimation;
  late Animation<Color?> _iconColorAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.short,
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    _circleColorAnimation = ColorTween(
      begin: _backgroundColor(widget.status, extension, lightTheme),
    ).animate(_controller);
    _iconColorAnimation = ColorTween(
      begin: _iconColor(widget.status, extension, lightTheme),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_RobotoffSuggestionSparkles oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status) {
      final SmoothColorsThemeExtension extension = context
          .extension<SmoothColorsThemeExtension>();
      final bool lightTheme = context.lightTheme();

      _circleColorAnimation = ColorTween(
        begin: _backgroundColor(oldWidget.status, extension, lightTheme),
        end: _backgroundColor(widget.status, extension, lightTheme),
      ).animate(_controller);
      _iconColorAnimation = ColorTween(
        begin: _iconColor(oldWidget.status, extension, lightTheme),
        end: _iconColor(widget.status, extension, lightTheme),
      ).animate(_controller);

      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: 32.0, // 8 + 8 + 16
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: _circleColorAnimation.value,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 9.5,
              end: 6.5,
              top: 8.0,
              bottom: 8.0,
            ),
            child: SparkleAnimation(
              type: SparkleAnimationType.glow,
              color: _iconColorAnimation.value!,
              size: 18.0,
              animated: widget.status == _RobotoffSuggestionStatus.neutral,
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(
    _RobotoffSuggestionStatus status,
    SmoothColorsThemeExtension ext,
    bool lightTheme,
  ) {
    return switch (status) {
      _RobotoffSuggestionStatus.positive => ext.successBackground,
      _RobotoffSuggestionStatus.negative => ext.errorBackground,
      _ => lightTheme ? Colors.white54 : Colors.black54,
    };
  }

  Color _iconColor(
    _RobotoffSuggestionStatus status,
    SmoothColorsThemeExtension ext,
    bool lightTheme,
  ) {
    return switch (status) {
      _RobotoffSuggestionStatus.positive => ext.success,
      _RobotoffSuggestionStatus.negative => ext.error,
      _ => lightTheme ? Colors.black : Colors.white,
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum _RobotoffSuggestionStatus {
  positive,
  negative,
  neutral;

  static _RobotoffSuggestionStatus fromAnnotation(
    InsightAnnotation? annotation,
  ) {
    return switch (annotation) {
      InsightAnnotation.YES => positive,
      InsightAnnotation.NO => negative,
      _ => neutral,
    };
  }
}
