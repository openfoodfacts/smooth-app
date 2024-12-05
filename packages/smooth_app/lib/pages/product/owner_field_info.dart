import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/widgets/smooth_banner.dart';
import 'package:smooth_app/widgets/widget_height.dart';

/// Icon to display when the product field value is "producer provided".
const IconData _ownerFieldIconData = Icons.factory;

/// Standard info tile about "owner fields".
class OwnerFieldInfo extends StatelessWidget {
  const OwnerFieldInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return ListTile(
      tileColor: dark ? darkGrey : lightGrey,
      leading: const Icon(_ownerFieldIconData),
      title: Text(appLocalizations.owner_field_info_title),
      subtitle: Text(appLocalizations.owner_field_info_message),
    );
  }
}

class OwnerFieldBanner extends StatelessWidget {
  const OwnerFieldBanner({
    this.shadow = false,
    this.onDismissClicked,
    super.key,
  });

  final bool shadow;

  /// If not null, a dismiss button is displayed
  final ValueChanged<SmoothBannerDismissEvent>? onDismissClicked;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothBanner(
      icon: const OwnerFieldIcon(),
      title: appLocalizations.owner_field_info_title,
      content: appLocalizations.owner_field_info_message,
      topShadow: shadow,
      onDismissClicked: onDismissClicked,
    );
  }
}

/// Standard icon about "owner fields".
class OwnerFieldIcon extends StatelessWidget {
  const OwnerFieldIcon({this.size, super.key});

  final double? size;

  @override
  Widget build(BuildContext context) => Icon(
        _ownerFieldIconData,
        size: size,
        semanticLabel: AppLocalizations.of(context).owner_field_info_title,
      );
}

class AnimatedOwnerFieldBanner extends StatefulWidget {
  const AnimatedOwnerFieldBanner({
    required this.visible,
    this.onHeightChanged,
    this.onDismissClicked,
    this.shadow,
    super.key,
  });

  final bool visible;
  final ValueChanged<double>? onHeightChanged;
  final bool? shadow;

  /// If not null, a dismiss button is displayed
  final VoidCallback? onDismissClicked;

  @override
  State<AnimatedOwnerFieldBanner> createState() =>
      _AnimatedOwnerFieldBannerState();
}

class _AnimatedOwnerFieldBannerState extends State<AnimatedOwnerFieldBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? _height;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.short,
    )..addListener(() => setState(() {}));

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInSine,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    if (widget.visible) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedOwnerFieldBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: _animation.value == 0.0,
      child: Transform.translate(
        offset: Offset(0.0, (_height ?? 0.0) * (1 - _animation.value)),
        child: MeasureSize(
          onChange: (Size size) {
            if (_height == null || _height! < size.height) {
              _height = size.height;
            }
            widget.onHeightChanged?.call(size.height);
          },
          child: OwnerFieldBanner(
            shadow: widget.shadow ?? false,
            onDismissClicked: _animation.value > 0.0
                ? (SmoothBannerDismissEvent event) {
                    /// From the button, we still need to animate
                    _controller.reverse(
                      from: event == SmoothBannerDismissEvent.fromButton
                          ? 1.0
                          : 0.0,
                    );
                    widget.onDismissClicked?.call();
                  }
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
