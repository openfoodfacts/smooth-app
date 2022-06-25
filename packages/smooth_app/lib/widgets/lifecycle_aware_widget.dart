import 'package:flutter/widgets.dart';

abstract class LifecycleAwareStatefulWidget extends StatefulWidget {
  /// Initializes [key] for subclasses.
  const LifecycleAwareStatefulWidget({
    Key? key,
  }) : super(key: key);

  @override
  StatefulElement createElement() {
    return _LifecycleAwareStatefulElement(this);
  }
}

class _LifecycleAwareStatefulElement extends StatefulElement {
  _LifecycleAwareStatefulElement(super.widget);

  @override
  LifecycleAwareState<StatefulWidget> get state =>
      super.state as LifecycleAwareState<StatefulWidget>;

  @override
  void mount(Element? parent, Object? newSlot) {
    state._debugLifecycleState = StateLifecycle.initialized;
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    state._debugLifecycleState = StateLifecycle.defunct;
    super.unmount();
  }
}

/// Make the private [_debugLifecycleState] attribute from the [State]
/// accessible
abstract class LifecycleAwareState<T extends StatefulWidget> extends State<T> {
  /// The current stage in the lifecycle for this state object.
  ///
  /// This field is used by the framework when asserts are enabled to verify
  /// that [State] objects move through their lifecycle in an orderly fashion.
  StateLifecycle _debugLifecycleState = StateLifecycle.created;

  @override
  @mustCallSuper
  void initState() {
    _debugLifecycleState = StateLifecycle.created;
    super.initState();
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    _debugLifecycleState = StateLifecycle.ready;
  }

  /// Will call [setState] only if the current lifecycle state allows it
  void setStateSafe(VoidCallback fn) {
    if (_debugLifecycleState != StateLifecycle.defunct) {
      setState(fn);
    }
  }

  StateLifecycle get lifecycleState => _debugLifecycleState;
}

/// Extracted from [State] class
enum StateLifecycle {
  /// The [State] object has been created. [State.initState] is called at this
  /// time.
  created,

  /// The [State.initState] method has been called but the [State] object is
  /// not yet ready to build. [State.didChangeDependencies] is called at this time.
  initialized,

  /// The [State] object is ready to build and [State.dispose] has not yet been
  /// called.
  ready,

  /// The [State.dispose] method has been called and the [State] object is
  /// no longer able to build.
  defunct,
}
