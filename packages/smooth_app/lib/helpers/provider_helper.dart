import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Same as [Consumer] but only notifies of a new value
class Listener<T> extends SingleChildStatefulWidget {
  const Listener({
    required this.listener,
    super.key,
    super.child,
  });

  final void Function(
    BuildContext context,
    T? previousValue,
    T currentValue,
  ) listener;

  @override
  State<Listener<T>> createState() => _ListenerState<T>();
}

class _ListenerState<T> extends SingleChildState<Listener<T>> {
  T? _oldValue;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final T? oldValue = _oldValue;
    final T newValue = context.watch<T>();
    _oldValue = newValue;

    widget.listener(
      context,
      oldValue,
      newValue,
    );

    return child ?? const SizedBox.shrink();
  }
}
