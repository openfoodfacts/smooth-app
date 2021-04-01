// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_ui_library/widgets/smooth_gauge.dart';

// Project imports:
import 'package:smooth_app/cards/data_cards/smooth_data_card.dart';
import 'package:smooth_app/data_models/sneak_peek_model.dart';

// TODO(stephanegigandet): remove if not useful anymore?
class SmoothQuantitySelectorCard extends StatelessWidget {
  const SmoothQuantitySelectorCard({@required this.sneakPeakModel});

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
                    'assets/data/portion.svg',
                    color: Colors.white,
                    width: 20.0,
                    height: 20.0,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Flexible(
                    child: Text(
                      'Portion',
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
            height: 10.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const SmoothGauge(
                value:
                    0.0, //sneakPeakModel.servingCount * sneakPeakModel.servingQuantity / sneakPeakModel.packageQuantity,
                size: 60.0,
                color: Colors.deepPurple,
              ),
              Column(
                children: const <Widget>[
                  /*Text('${sneakPeakModel.servingCount} portion', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8.0,),
                  Text('${sneakPeakModel.servingCount * sneakPeakModel.servingQuantity} g', style: const TextStyle(color: Colors.white),),*/
                  Text('1 portion', style: TextStyle(color: Colors.white)),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    '0 g',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            ],
          ),
          MaterialButton(
            child: const Text('Tap to increase',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300)),
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            onPressed: () {
              //sneakPeakModel.increaseServingCount();
            },
          ),
        ],
      ),
      color: Colors.black54,
    );
  }
}
