import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/onboarding/v2/onboarding_bottom_hills.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Onboarding page: "reinvention"
class OnboardingHomePage extends StatelessWidget {
  const OnboardingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      backgroundColor: const Color(0xFFE3F3FE),
      body: Provider<OnboardingConfig>.value(
        value: OnboardingConfig._(MediaQuery.sizeOf(context)),
        child: Stack(
          children: <Widget>[
            const _OnboardingWelcomePageContent(),
            OnboardingBottomHills(
              onTap: () async {
                final UserPreferences userPreferences =
                    context.read<UserPreferences>();
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();

                await OnboardingLoader(localDatabase)
                    .runAtNextTime(OnboardingPage.HOME_PAGE, context);
                if (context.mounted) {
                  await OnboardingFlowNavigator(userPreferences).navigateToPage(
                    context,
                    OnboardingPage.HOME_PAGE.getNextPage(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingWelcomePageContent extends StatelessWidget {
  const _OnboardingWelcomePageContent();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final double fontMultiplier = OnboardingConfig.of(context).fontMultiplier;
    final double hillsHeight = OnboardingBottomHills.height(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: hillsHeight * 0.5 + MediaQuery.viewPaddingOf(context).top,
        bottom: hillsHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Text(
              appLocalizations.onboarding_home_welcome_text1,
              style: TextStyle(
                fontSize: 45 * fontMultiplier,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 37,
            child: _SunAndCloud(),
          ),
          Expanded(
            flex: 45,
            child: FractionallySizedBox(
              widthFactor: 0.65,
              child: Align(
                alignment: const Alignment(0, -0.2),
                child: OnboardingText(
                  text: appLocalizations.onboarding_home_welcome_text2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunAndCloud extends StatefulWidget {
  const _SunAndCloud();

  @override
  State<_SunAndCloud> createState() => _SunAndCloudState();
}

class _SunAndCloudState extends State<_SunAndCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() => setState(() {}));
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    return RepaintBoundary(
      child: LayoutBuilder(builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        return Stack(
          children: <Widget>[
            Positioned.directional(
              top: constraints.maxHeight * 0.3,
              bottom: constraints.maxHeight * 0.2,
              start: (_animation.value * 161.0) * 0.3,
              textDirection: textDirection,
              child: SvgPicture.asset('assets/onboarding/cloud.svg'),
            ),
            const Align(
              alignment: Alignment.center,
              child: RiveAnimation.asset(
                'assets/animations/off.riv',
                artboard: 'Success',
                animations: <String>['Timeline 1'],
              ),
            ),
            Positioned.directional(
              top: constraints.maxHeight * 0.22,
              bottom: constraints.maxHeight * 0.35,
              end: (_animation.value * 40.0) - 31,
              textDirection: textDirection,
              child: SvgPicture.asset('assets/onboarding/cloud.svg'),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class OnboardingText extends StatelessWidget {
  const OnboardingText({
    required this.text,
    this.margin,
    super.key,
  });

  final String text;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    double fontMultiplier;
    try {
      fontMultiplier = OnboardingConfig.of(context).fontMultiplier;
    } catch (_) {
      fontMultiplier =
          OnboardingConfig.computeFontMultiplier(MediaQuery.sizeOf(context));
    }

    final Color backgroundColor =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!.orange;

    return RichText(
      text: TextSpan(
        children: _extractChunks().map(((String text, bool highlighted) el) {
          if (el.$2) {
            return _createSpan(
              el.$1,
              30 * fontMultiplier,
              backgroundColor,
            );
          } else {
            return TextSpan(text: el.$1);
          }
        }).toList(growable: false),
        style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 30 * fontMultiplier,
              height: 1.53,
              fontWeight: FontWeight.w600,
            ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Iterable<(String, bool)> _extractChunks() {
    final Iterable<RegExpMatch> matches =
        RegExp(r'\*\*(.*?)\*\*').allMatches(text);

    if (matches.length <= 1) {
      return <(String, bool)>[(text, false)];
    }

    final List<(String, bool)> chunks = <(String, bool)>[];

    int lastMatch = 0;

    for (final RegExpMatch match in matches) {
      if (matches.first.start > 0) {
        chunks.add((text.substring(lastMatch, match.start), false));
      }

      chunks.add((text.substring(match.start + 2, match.end - 2), true));
      lastMatch = match.end;
    }

    if (lastMatch < text.length) {
      chunks.add((text.substring(lastMatch), false));
    }

    return chunks;
  }

  WidgetSpan _createSpan(String text, double fontSize, Color backgroundColor) =>
      HighlightedTextSpan(
        text: text,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsetsDirectional.only(
          top: 1.0,
          bottom: 5.0,
          start: 15.0,
          end: 15.0,
        ),
        margin: margin ?? const EdgeInsetsDirectional.symmetric(vertical: 2.5),
        backgroundColor: backgroundColor,
        radius: 30.0,
      );
}

// TODO(g123k): Move elsewhere when the onboarding will be redesigned
class OnboardingConfig {
  OnboardingConfig._(Size screenSize)
      : fontMultiplier = computeFontMultiplier(screenSize);
  final double fontMultiplier;

  static double computeFontMultiplier(Size screenSize) =>
      ((screenSize.width * 45) / 428) / 45;

  static OnboardingConfig of(BuildContext context) =>
      context.watch<OnboardingConfig>();
}
