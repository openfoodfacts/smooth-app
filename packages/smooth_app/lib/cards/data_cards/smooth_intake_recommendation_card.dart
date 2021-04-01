// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';
import 'package:smooth_ui_library/widgets/smooth_gauge.dart';

// Project imports:
import 'package:smooth_app/cards/data_cards/smooth_data_card.dart';
import 'package:smooth_app/data_models/sneak_peek_model.dart';

// TODO(stephanegigandet): remove if not useful anymore?
class SmoothIntakeRecommendationCard extends StatelessWidget {
  const SmoothIntakeRecommendationCard({@required this.sneakPeakModel});

  final SneakPeakModel sneakPeakModel;

  @override
  Widget build(BuildContext context) {
    return SmoothDataCard(
      content: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/data/target.svg',
                    color: Colors.white,
                    width: 20.0,
                    height: 20.0,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Flexible(
                    child: Text(
                      'Recommended daily intakes',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              GestureDetector(
                child: SvgPicture.asset(
                  'assets/misc/information.svg',
                  color: Colors.white,
                  width: 24.0,
                  height: 20.0,
                ),
                onTap: () {},
              )
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                const SizedBox(
                  width: 12.0,
                ),
                _generateNutritionPercentageDisplay('Energy',
                    Colors.greenAccent, 0.0), //sneakPeakModel.energy),
                const SizedBox(
                  width: 12.0,
                ),
                _generateNutritionPercentageDisplay('Sugars',
                    Colors.orangeAccent, 0.0), //sneakPeakModel.sugars),
                const SizedBox(
                  width: 12.0,
                ),
                _generateNutritionPercentageDisplay(
                    'Fat', Colors.redAccent, 0.0), //sneakPeakModel.fat),
                const SizedBox(
                  width: 12.0,
                ),
                _generateNutritionPercentageDisplay('Saturated-fat',
                    Colors.blueAccent, 0.0), //sneakPeakModel.saturatedFat),
                const SizedBox(
                  width: 12.0,
                ),
                _generateNutritionPercentageDisplay(
                    'Carbohydrates',
                    Colors.deepPurpleAccent,
                    0.0), //sneakPeakModel.carbohydrates),
                const SizedBox(
                  width: 12.0,
                ),
              ],
            ),
          ),
        ],
      ),
      color: Colors.black54,
    );
  }

  Widget _generateNutritionPercentageDisplay(
      String name, Color color, double value) {
    return Column(
      children: <Widget>[
        SmoothGauge(
          value: value,
          size: 60.0,
          color: color,
        ),
        const SizedBox(
          height: 5.0,
        ),
        Flexible(
          child: Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }
}
