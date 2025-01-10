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

/// Same as [Listener] but for [ValueNotifier] : notifies when the value changes
class ValueNotifierListener<T extends ValueNotifier<S>, S>
    extends SingleChildStatefulWidget {
  const ValueNotifierListener({
    this.listener,
    this.listenerWithValueNotifier,
    super.key,
    super.child,
  }) : assert(
          listener != null || listenerWithValueNotifier != null,
          'At least one listener must be provided',
        );

  final void Function(
    BuildContext context,
    S? previousValue,
    S currentValue,
  )? listener;

  final void Function(
    BuildContext context,
    T valueNotifier,
    S? previousValue,
    S currentValue,
  )? listenerWithValueNotifier;

  @override
  State<ValueNotifierListener<T, S>> createState() =>
      _ValueNotifierListenerState<T, S>();
}

class _ValueNotifierListenerState<T extends ValueNotifier<S>, S>
    extends SingleChildState<ValueNotifierListener<T, S>> {
  S? _oldValue;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final S? oldValue = _oldValue;
    final T valueNotifier = context.watch<T>();
    final S newValue = valueNotifier.value;
    _oldValue = newValue;

    widget.listener?.call(
      context,
      oldValue,
      newValue,
    );

    widget.listenerWithValueNotifier?.call(
      context,
      valueNotifier,
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

/// Same as [Consumer] for [ValueNotifier] but only rebuilds if [buildWhen]
/// returns true (and on the first build).
class ConsumerValueNotifierFilter<T extends ValueNotifier<S>, S>
    extends StatefulWidget {
  const ConsumerValueNotifierFilter({
    required this.builder,
    this.buildWhen,
    this.child,
    super.key,
  });

  final Widget Function(
    BuildContext context,
    S value,
    Widget? child,
  ) builder;
  final bool Function(S? previousValue, S currentValue)? buildWhen;

  final Widget? child;

  @override
  State<ConsumerValueNotifierFilter<T, S>> createState() =>
      _ConsumerValueNotifierFilterState<T, S>();
}

class _ConsumerValueNotifierFilterState<T extends ValueNotifier<S>, S>
    extends State<ConsumerValueNotifierFilter<T, S>> {
  S? oldValue;
  Widget? oldWidget;

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (BuildContext context, T provider, Widget? child) {
        if ((widget.buildWhen != null &&
                widget.buildWhen!.call(oldValue, provider.value)) ||
            widget.buildWhen == null && oldValue != provider.value ||
            oldWidget == null) {
          oldWidget = widget.builder(
            context,
            provider.value,
            child,
          );
        }

        oldValue = provider.value;

        return widget.builder(
          context,
          provider.value,
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

extension ProviderExtension on BuildContext {
  T? readSafe<T>() {
    try {
      return read<T>();
    } catch (_) {
      return null;
    }
  }

  T? watchSafe<T>() {
    try {
      return watch<T>();
    } catch (_) {
      return null;
    }
  }
}
