import 'package:flutter/material.dart';

class FoodPreferencesProgressIndicator extends StatelessWidget {
  const FoodPreferencesProgressIndicator({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      height: 10.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * progress,
                height: 10.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: theme.primaryColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
