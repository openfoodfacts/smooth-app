// ignore_for_file: avoid_void_async

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

class ConsentAnalytics extends StatelessWidget {
  const ConsentAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    const Color shadowColor = Color.fromARGB(144, 0, 0, 0);
    const Color bodyColor = Color.fromARGB(174, 19, 18, 18);
    const String assetName = 'assets/onboarding/analytics.svg';
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              height: size.height * 0.2,
              width: size.width * 0.45,
              child: SvgPicture.asset(
                assetName,
                semanticsLabel: 'Analytics Icons',
                fit: BoxFit.contain,
              )),
          SizedBox(
            height: size.height * 0.01,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Send anonymous analytics',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .apply(color: Colors.black),
            ),
          ),
          SizedBox(
            height: size.height * 0.034,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
            ),
            child: Text(
              'Help the Open Food Facts volunteer to improve the app.You decide if you want to send anonymous analytics.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .apply(color: bodyColor),
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
            ),
            child: Text(
              'If you change your mind this option can be enabled and disabled at any time from the settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .apply(color: bodyColor),
            ),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          //Authorize Button
          InkWell(
            borderRadius: BorderRadius.circular(25.0),
            onTap: () async {
              await _analyticsLogic(
                  true, userPreferences, localDatabase, context);
            },
            child: Ink(
              height: size.height * 0.06,
              width: size.width * 0.7,
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        blurRadius: 3.0,
                        color: shadowColor,
                        offset: Offset(size.width * 0.004, size.height * 0.004))
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Authorize',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: size.height * 0.025),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.02),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size.height * 0.04,
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: size.height * 0.02,
          ),

          //Refuse Button
          InkWell(
            borderRadius: BorderRadius.circular(25.0),
            onTap: () async {
              await _analyticsLogic(
                  false, userPreferences, localDatabase, context);
            },
            child: Ink(
              height: size.height * 0.06,
              width: size.width * 0.7,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      blurRadius: 3.0,
                      color: shadowColor,
                      offset: Offset(size.width * 0.004, size.height * 0.004),
                    )
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Refuse',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: size.height * 0.025),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.02),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: size.height * 0.04,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyticsLogic(bool accept, UserPreferences userPreferences,
      LocalDatabase localDatabase, BuildContext context) async {
    await userPreferences.setCrashReports(false);
    await userPreferences.setAnalyticsReports(false);
    await OnboardingLoader(localDatabase)
        .runAtNextTime(OnboardingPage.CONSENT_PAGE, context);
    OnboardingFlowNavigator(userPreferences).navigateToPage(
      context,
      OnboardingFlowNavigator.getNextPage(OnboardingPage.CONSENT_PAGE),
    );
  }
}
