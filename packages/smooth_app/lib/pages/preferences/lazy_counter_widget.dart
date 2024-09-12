import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';

/// Widget displaying a Lazy Counter: cached value, refresh button, and loading.
class LazyCounterWidget extends StatefulWidget {
  const LazyCounterWidget(this.lazyCounter);

  final LazyCounter lazyCounter;

  @override
  State<LazyCounterWidget> createState() => _LazyCounterWidgetState();
}

class _LazyCounterWidgetState extends State<LazyCounterWidget> {
  bool _loading = false;
  int? _count;

  @override
  void initState() {
    super.initState();
    final UserPreferences userPreferences = context.read<UserPreferences>();
    _count = widget.lazyCounter.getLocalCount(userPreferences);
    if (_count == null) {
      _asyncLoad();
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (_count != null) Text(_count.toString()),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator.adaptive(),
              ),
            )
          else
            IconButton(
              onPressed: () => _asyncLoad(),
              icon: const Icon(Icons.refresh),
            ),
        ],
      );

  Future<void> _asyncLoad() async {
    if (_loading) {
      return;
    }
    _loading = true;
    final UserPreferences userPreferences = context.read<UserPreferences>();
    if (mounted) {
      setState(() {});
    }
    try {
      final int? value = await widget.lazyCounter.getServerCount();
      if (value != null) {
        await widget.lazyCounter.setLocalCount(value, userPreferences);
        _count = value;
      }
    } catch (e) {
      //
    } finally {
      _loading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
