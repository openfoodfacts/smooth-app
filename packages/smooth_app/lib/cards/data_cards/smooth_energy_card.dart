// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_ui_library/widgets/smooth_gauge.dart';

// Project imports:
import 'package:smooth_app/cards/data_cards/smooth_data_card.dart';
import 'package:smooth_app/data_models/sneak_peek_model.dart';

// TODO(stephanegigandet): remove if not useful anymore?
class SmoothEnergyCard extends StatelessWidget {
  const SmoothEnergyCard({@required this.sneakPeakModel});

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
                    'assets/data/energy.svg',
                    color: Colors.white,
                    width: 20.0,
                    height: 20.0,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Flexible(
                    child: Text(
                      'Energy',
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
            height: 5.0,
          ),
          const Expanded(
            child: Center(
              child: SmoothGauge(
                //value: sneakPeakModel.energy,
                value: 0.0,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
      color: Colors.black54,
    );
  }
}
