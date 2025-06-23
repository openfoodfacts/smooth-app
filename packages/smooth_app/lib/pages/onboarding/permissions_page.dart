import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/onboarding_bottom_bar.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/resources/app_animations.dart' as animations;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage(this.backgroundColor, {super.key});

  final Color backgroundColor;

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  // Ensure we open the next screen only once
  bool _eventConsumed = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Listener<PermissionListener>(
      listener: (BuildContext context, _, PermissionListener newValue) {
        if (newValue.value.isGranted && !_eventConsumed) {
          _endOnboarding(context);
          _eventConsumed = true;
        }
      },
      child: ColoredBox(
        color: widget.backgroundColor,
        child: SafeArea(
          bottom: Platform.isAndroid,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                return SizedBox.square(
                                  dimension: constraints.maxWidth * 0.5,
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: const animations.BarcodeAnimation(),
                                  ),
                                );
                              },
                        ),
                        const SizedBox(height: LARGE_SPACE),
                        AutoSizeText(
                          appLocalizations.permissions_page_title,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.displayLarge!
                              .apply(
                                color: const Color.fromARGB(255, 51, 51, 51),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SMALL_SPACE),
                        AutoSizeText(
                          appLocalizations.permissions_page_body1,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style:
                              WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED,
                        ),
                        const SizedBox(height: MEDIUM_SPACE),
                        AutoSizeText(
                          appLocalizations.permissions_page_body2,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style:
                              WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              OnboardingBottomBar(
                leftButton: !Platform.isIOS
                    ? _IgnoreButton(
                        onPermissionIgnored: () => _endOnboarding(context),
                      )
                    : null,
                rightButton: _AskPermissionButton(
                  onPermissionIgnored: () => _endOnboarding(context),
                ),
                backgroundColor: widget.backgroundColor,
                semanticsHorizontalOrder: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const OnboardingPage _onboardingPage = OnboardingPage.PERMISSIONS_PAGE;

  Future<void> _endOnboarding(BuildContext context) async {
    context.read<ThemeProvider>().finishOnboarding();

    if (!context.mounted) {
      return;
    }
    await OnboardingLoader(
      context.read<LocalDatabase>(),
    ).runAtNextTime(_onboardingPage, context);

    if (!context.mounted) {
      return;
    }
    await OnboardingFlowNavigator(
      context.read<UserPreferences>(),
    ).navigateToPage(context, _onboardingPage.getNextPage());
  }
}

class _AskPermissionButton extends StatelessWidget {
  const _AskPermissionButton({required this.onPermissionIgnored});

  final VoidCallback onPermissionIgnored;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return OnboardingBottomButton(
      onPressed: () async {
        context.read<PermissionListener>().askPermission(
          onRationaleNotAvailable: () async {
            // Don't open settings and continue the navigation
            onPermissionIgnored.call();
            return false;
          },
        );
      },
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      label: Platform.isIOS
          ? appLocalizations.onboarding_continue_button
          : appLocalizations.authorize_button_label,
    );
  }
}

class _IgnoreButton extends StatelessWidget {
  const _IgnoreButton({required this.onPermissionIgnored});

  final VoidCallback onPermissionIgnored;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return OnboardingBottomButton(
      onPressed: onPermissionIgnored,
      backgroundColor: const Color(0xFFA08D84),
      foregroundColor: Colors.white,
      label: appLocalizations.ask_me_later_button_label,
    );
  }
}
