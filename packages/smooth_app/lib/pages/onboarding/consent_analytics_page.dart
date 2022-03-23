// ignore_for_file: avoid_void_async

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

import '../../database/local_database.dart';

class ConsentAnalytics extends StatelessWidget {
  const ConsentAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: size.height * 0.2,
            width: size.width * 0.28,
            child: Image.asset(
              'assets/onboarding/data.png',
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Send anonymous analytics',
              maxLines: 1,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.025),
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
              style:
                  TextStyle(fontSize: size.height * 0.021, color: Colors.black),
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
              style:
                  TextStyle(fontSize: size.height * 0.021, color: Colors.black),
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          //Authorize Button
          InkWell(
            borderRadius: BorderRadius.circular(25.0),
            onTap: () {
              _analyticsLogic(true, userPreferences, localDatabase, context);
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
                        color: const Color.fromARGB(144, 0, 0, 0),
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
            height: size.height * 0.03,
          ),

          //Refuse Button
          InkWell(
            borderRadius: BorderRadius.circular(25.0),
            onTap: () {
              _analyticsLogic(false, userPreferences, localDatabase, context);
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
                        color: const Color.fromARGB(144, 0, 0, 0),
                        offset: Offset(size.width * 0.004, size.height * 0.004))
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

  void _analyticsLogic(bool accept, UserPreferences userPreferences,
      LocalDatabase localDatabase, BuildContext context) async {
    userPreferences.setCrashReports(false);
    userPreferences.setAnalyticsReports(false);
    await OnboardingLoader(localDatabase)
        .runAtNextTime(OnboardingPage.CONSENT_PAGE, context);
    OnboardingFlowNavigator(userPreferences).navigateToPage(context,
        OnboardingFlowNavigator.getNextPage(OnboardingPage.CONSENT_PAGE));
  }
}
