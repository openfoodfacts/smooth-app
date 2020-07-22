
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/views/label_sneak_peek_view.dart';
import 'package:smooth_ui_library/page_routes/smooth_sneak_peek_route.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

class LabelsExpandable extends StatelessWidget {

  const LabelsExpandable({@required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SmoothExpandableCard(
      headerHeight: 50.0,
      collapsedHeader: Row(
        children: labels != null ? <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push<dynamic>(
                  context,
                  SmoothSneakPeekRoute<dynamic>(
                      builder: (BuildContext context) {
                        return Material(
                          color: Colors.transparent,
                          child: Center(
                            child: LabelSneakPeekView(),
                          ),
                        );
                      },
                      duration: 250));
            },
            child: Container(
              child: labels.contains('en:ab-agriculture-biologique') ? SvgPicture.asset(
                'assets/labels/ab_label.svg',
                fit: BoxFit.contain,
              ) : Text('No label found', style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.black),),
            ),
          ),
        ] : <Widget>[
          Text('No label found', style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.black),),
        ]
      ),
      content: Container(
        width: 150.0,
      ),
      expandedHeader: Text('Labels', style: Theme.of(context).textTheme.headline3,),
    );
  }

}