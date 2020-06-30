import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/profile_page_model.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<ProfilePageModel>(
          create: (BuildContext context) => ProfilePageModel(),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50.0,),
              Text(
                'Testers settings',
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 10.0,),
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.black.withAlpha(5),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(20.0))),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Use ML Kit powered scanner'),
                    Consumer<ProfilePageModel>(builder: (BuildContext context,
                        ProfilePageModel profilePageModel, Widget child) {
                      return SmoothToggle(
                        value: profilePageModel.useMlKit,
                        onChanged: (bool newValue) {
                          profilePageModel.setMlKitState(newValue);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
