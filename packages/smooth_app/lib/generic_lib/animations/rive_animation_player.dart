import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAnimationPlayer extends StatefulWidget {
  const RiveAnimationPlayer(
    this.path, {

    required this.artboard,
    this.size,
    super.key,
  });

  final String path;
  final String artboard;
  final Size? size;

  @override
  State<RiveAnimationPlayer> createState() => _RiveAnimationPlayerState();
}

class _RiveAnimationPlayerState extends State<RiveAnimationPlayer> {
  late File _file;
  late RiveWidgetController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  Future<void> initRive() async {
    _file = (await File.asset(widget.path, riveFactory: Factory.rive))!;
    _controller = RiveWidgetController(_file);
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (!_isInitialized) {
      child = const Center(child: CircularProgressIndicator.adaptive());
    } else {
      child = RiveWidget(controller: _controller, fit: Fit.cover);
    }

    return SizedBox.fromSize(size: widget.size, child: child);
  }

  @override
  void dispose() {
    _file.dispose();
    _controller.dispose();
    super.dispose();
  }
}
