// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';

class LabelSneakPeekView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SmoothRevealAnimation(
          startOffset: const Offset(0.0, 0.5),
          animationCurve: Curves.easeInOutBack,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: SvgPicture.asset(
                              'assets/labels/ab_label.svg',
                              height: 60.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            'AB Label',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: CarouselSlider(
                        items: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'At least 95% organic ingredients',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const Text(
                                    'Composé d\'au moins 95 % d\'ingrédients issus d\'un mode de production biologique')
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Absence d\'OGM (traces <0,9% éventuellement possibles)',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const Text(
                                  'Absence d\'OGM (possibilité de traces fortuites, accidentelles ou inévitables, dans la limite de 0,9 %)',
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Certifié par un organisme indépendant',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const Text(
                                  'Certifié par un organisme agréé par les pouvoirs publics français et répondant aux critères d\'indépendance, d\'impartialité, de compétence et d\'efficacité définis par la norme européenne EN 45011',
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Respect de la réglementation française',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const Text(
                                    'Respect de la réglementation en vigueur en France')
                              ],
                            ),
                          )
                        ],
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          height: MediaQuery.of(context).size.height * 0.2,
                          enableInfiniteScroll: false,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                                color: Colors.redAccent.withAlpha(50),
                              ),
                              child: Center(
                                child: Text(
                                  'Close',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                                color: Colors.lightBlue.withAlpha(50),
                              ),
                              child: Center(
                                child: Text(
                                  'Learn more',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(color: Colors.lightBlue),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
