import 'package:flutter/material.dart';

/// A custom [Hero] widget that allows to listen to the end of the animation.
/// This code is mainly a copy/paste from the Flutter widget, but some methods
/// are private.
///
/// The goal here, is to be notified when the animation is finished and
/// thus trigger an autofocus event at the perfect timing.
class SmoothHero extends StatelessWidget {
  const SmoothHero({
    required this.tag,
    required this.enabled,
    required this.child,
    this.onAnimationEnded,
    super.key,
  }) : assert(!enabled || tag != null);

  final Object? tag;
  final bool enabled;
  final Widget child;
  final Function(HeroFlightDirection direction)? onAnimationEnded;

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: enabled,
      child: Hero(
        tag: tag ?? '',
        flightShuttleBuilder: onAnimationEnded == null
            ? null
            : _flightShuttleBuilder,
        child: child,
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    animation.addStatusListener((AnimationStatus status) {
      _onAnimationStatusChanged(status, flightDirection);
    });

    /// Code from [heroes.dart]
    final Hero toHero = toHeroContext.widget as Hero;

    final MediaQueryData? toMediaQueryData = MediaQuery.maybeOf(toHeroContext);
    final MediaQueryData? fromMediaQueryData = MediaQuery.maybeOf(
      fromHeroContext,
    );

    if (toMediaQueryData == null || fromMediaQueryData == null) {
      return toHero.child;
    }

    final EdgeInsets fromHeroPadding = fromMediaQueryData.padding;
    final EdgeInsets toHeroPadding = toMediaQueryData.padding;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: toMediaQueryData.copyWith(
            padding: (flightDirection == HeroFlightDirection.push)
                ? EdgeInsetsTween(
                    begin: fromHeroPadding,
                    end: toHeroPadding,
                  ).evaluate(animation)
                : EdgeInsetsTween(
                    begin: toHeroPadding,
                    end: fromHeroPadding,
                  ).evaluate(animation),
          ),
          child: toHero.child,
        );
      },
    );
  }

  void _onAnimationStatusChanged(
    AnimationStatus status,
    HeroFlightDirection direction,
  ) {
    if (status == AnimationStatus.completed) {
      onAnimationEnded?.call(direction);
    }
  }
}
