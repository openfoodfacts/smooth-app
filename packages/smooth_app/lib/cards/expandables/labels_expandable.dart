import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
          children: labels != null
              ? <Widget>[
                  Container(
                    child: labels.isNotEmpty
                        ? Row(
                            children: List<Widget>.generate(
                                labels.length > 3 ? 4 : labels.length,
                                (int index) {
                              if (index == 3) {
                                return Container(
                                  width: 50.0,
                                  height: 50.0,
                                  margin: const EdgeInsets.only(left: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(40.0)),
                                    color: Colors.transparent,
                                    border: Border.all(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${labels.length - 3}',
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                );
                              }
                              return generateLabelWidget(
                                  labels[index], context);
                            }),
                          )
                        : Text(
                            'No label found',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Colors.black),
                          ),
                  ),
                ]
              : <Widget>[
                  Text(
                    'No label found',
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.black),
                  ),
                ]),
      content: Container(
        height: 70.0 * labels.length,
        child: Column(
          children: List<Widget>.generate(labels.length, (int index) {
            return Container(
              height: 60.0,
              margin: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: <Widget>[
                  generateLabelWidget(labels[index], context),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(cleanLabelName(labels[index])),
                ],
              ),
            );
          }),
        ),
      ),
      expandedHeader: Text(
        'Labels',
        style: Theme.of(context).textTheme.headline3,
      ),
    );
  }

  String cleanLabelName(String labelName) {
    String result = labelName.replaceAll('en:', '');
    result = result.replaceAll('fr:', '');
    result = result.replaceAll('-', ' ');
    result = result.toUpperCase();
    return result;
  }

  Widget generateLabelWidget(String label, BuildContext context) {
    print(label);
    switch (label) {
      case 'en:ab-agriculture-biologique':
        return GestureDetector(
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
            width: 60.0,
            child: SvgPicture.asset(
              'assets/labels/ab_label.svg',
              fit: BoxFit.contain,
            ),
          ),
        );
        break;
      case 'fr:ab-agriculture-biologique':
        return GestureDetector(
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
            width: 60.0,
            child: SvgPicture.asset(
              'assets/labels/ab_label.svg',
              fit: BoxFit.contain,
            ),
          ),
        );
        break;
      default:
        return GestureDetector(
          onTap: () {
            const SnackBar snackBar = SnackBar(
              content: Text('No data for this label'),
              duration: Duration(milliseconds: 450),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            width: 48.0,
            height: 80.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                border: Border.all(color: Colors.grey, width: 1.0)),
            child: const Center(
              child: Text(
                '?',
                style: TextStyle(color: Colors.grey, fontSize: 18.0),
              ),
            ),
          ),
        );
        break;
    }
  }
}
