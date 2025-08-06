import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/product/simple_input/list/suggestions/robotoff/robotoff_suggestions_item.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/auto_scale_widget.dart';

class RobotoffSuggestionList extends StatefulWidget {
  const RobotoffSuggestionList({required this.helper, super.key});

  final AbstractSimpleInputPageHelper helper;

  @override
  State<RobotoffSuggestionList> createState() => _RobotoffSuggestionListState();
}

class _RobotoffSuggestionListState extends State<RobotoffSuggestionList>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>
    questionsNotifier = context
        .watch<ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>>();

    final Map<RobotoffQuestion, InsightAnnotation?> questions =
        questionsNotifier.value;

    return AutoScaleWidget(
      duration: SmoothAnimationsDuration.short,
      vsync: this,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          top: questions.isEmpty ? 0.0 : MEDIUM_SPACE,
        ),
        itemCount: questions.entries.length,
        itemBuilder: (BuildContext context, int position) {
          final MapEntry<RobotoffQuestion, InsightAnnotation?> entry = questions
              .entries
              .elementAt(position);

          return MultiProvider(
            providers: <SingleChildWidget>[
              Provider<InsightAnnotation?>.value(value: entry.value),
              Provider<RobotoffQuestion>.value(value: entry.key),
            ],
            child: AutoScaleWidget(
              vsync: this,
              duration: SmoothAnimationsDuration.short,
              child: RobotoffSuggestionListItem(
                onChanged: (bool? value) {
                  widget.helper.answerRobotoffQuestion(
                    entry.key,
                    value == true
                        ? InsightAnnotation.YES
                        : value == false
                        ? InsightAnnotation.NO
                        : null,
                  );
                },
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int position) {
          if (questions.values.elementAt(position + 1) != null) {
            return EMPTY_WIDGET;
          }

          final SmoothColorsThemeExtension extension = context
              .extension<SmoothColorsThemeExtension>();
          final bool lightTheme = context.lightTheme();

          return Divider(
            height: 0.0,
            thickness: 1.0,
            color: lightTheme
                ? extension.primaryLight
                : extension.primaryUltraBlack,
          );
        },
        shrinkWrap: true,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
