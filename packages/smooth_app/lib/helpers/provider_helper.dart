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

/// Same as [Consumer] but only rebuilds if [buildWhen] returns true
/// (And on the first build)
class ConsumerFilter<T> extends StatefulWidget {
  const ConsumerFilter({
    required this.builder,
    required this.buildWhen,
    this.child,
    super.key,
  });

  final Widget Function(
    BuildContext context,
    T value,
    Widget? child,
  ) builder;
  final bool Function(T? previousValue, T currentValue) buildWhen;

  final Widget? child;

  @override
  State<ConsumerFilter<T>> createState() => _ConsumerFilterState<T>();
}

class _ConsumerFilterState<T> extends State<ConsumerFilter<T>> {
  T? oldValue;
  Widget? oldWidget;

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (BuildContext context, T value, Widget? child) {
        if (widget.buildWhen(oldValue, value) || oldWidget == null) {
          oldWidget = widget.builder(
            context,
            value,
            child,
          );
        }

        oldValue = value;

        return widget.builder(
          context,
          value,
          oldWidget,
        );
      },
      child: widget.child,
    );
  }
}

extension ValueNotifierExtensions<T> on ValueNotifier<T> {
  void emit(T value) => this.value = value;
}
