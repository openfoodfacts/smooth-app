import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/onboarding/onboarding_bottom_bar.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage(
    this.backgroundColor, {
    super.key,
  });

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
      listener: (
        BuildContext context,
        _,
        PermissionListener newValue,
      ) {
        if (newValue.value.isGranted && !_eventConsumed) {
          _moveToNextScreen(context);
          _eventConsumed = true;
        }
      },
      child: ColoredBox(
        color: widget.backgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Lottie.asset('assets/animations/barcode.json'),
                      ),
                    ),
                    const SizedBox(height: LARGE_SPACE),
                    AutoSizeText(
                      appLocalizations.permissions_page_title,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .apply(color: const Color.fromARGB(255, 51, 51, 51)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SMALL_SPACE),
                    AutoSizeText(
                      appLocalizations.permissions_page_body1,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: MEDIUM_SPACE),
                    AutoSizeText(
                      appLocalizations.permissions_page_body2,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )),
            OnboardingBottomBar(
              leftButton: _IgnoreButton(
                onPermissionIgnored: () => _moveToNextScreen(context),
              ),
              rightButton: _AskPermissionButton(
                onPermissionIgnored: () => _moveToNextScreen(context),
              ),
              backgroundColor: widget.backgroundColor,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _moveToNextScreen(BuildContext context) async {
    await OnboardingLoader(context.read<LocalDatabase>()).runAtNextTime(
      OnboardingPage.PERMISSIONS_PAGE,
      context,
    );

    // ignore: use_build_context_synchronously
    return OnboardingFlowNavigator(context.read<UserPreferences>())
        .navigateToPage(
      context,
      OnboardingFlowNavigator.getNextPage(OnboardingPage.PERMISSIONS_PAGE),
    );
  }
}

class _AskPermissionButton extends StatelessWidget {
  const _AskPermissionButton({
    required this.onPermissionIgnored,
  });

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
        });
      },
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      label: appLocalizations.authorize_button_label,
    );
  }
}

class _IgnoreButton extends StatelessWidget {
  const _IgnoreButton({
    required this.onPermissionIgnored,
  });

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
