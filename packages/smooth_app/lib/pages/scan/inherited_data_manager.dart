import 'package:flutter/material.dart';

class InheritedDataManager extends StatefulWidget {
  const InheritedDataManager({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  static InheritedDataManagerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedDataManagerProvider>()!
        .data;
  }

  @override
  State<InheritedDataManager> createState() => InheritedDataManagerState();
}

class InheritedDataManagerState extends State<InheritedDataManager> {
  late bool showSearchCard;

  @override
  void initState() {
    showSearchCard = false;
    super.initState();
  }

  void resetShowSearchCard(bool newValue) {
    setState(() {
      showSearchCard = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedDataManagerProvider(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedDataManagerProvider extends InheritedWidget {
  const _InheritedDataManagerProvider({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final InheritedDataManagerState data;

  @override
  bool updateShouldNotify(_InheritedDataManagerProvider oldWidget) {
    return data.showSearchCard;
  }
}
