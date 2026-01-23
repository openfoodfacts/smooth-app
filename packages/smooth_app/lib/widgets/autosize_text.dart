// ignore_for_file: unnecessary_getters_setters
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget similar to a [Text] Widget, except that it scales down
/// the font size if there's not enough space.
///
/// It can be grouped with other [AutoSizeText] widgets using
/// an [AutoSizeGroup] to synchronize their font sizes.
class AutoSizeText extends StatefulWidget {
  const AutoSizeText(
    this.text, {
    this.style,
    this.minFontSize = 8.0,
    this.maxFontSize = double.infinity,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.group,
    super.key,
  }) : assert(minFontSize > 0.0),
       assert(maxFontSize >= minFontSize),
       assert(maxLines == null || maxLines > 0),
       assert(
         overflow == null || maxLines != null,
         'Overflow can only be specified if maxLines is also specified.',
       );

  final String text;
  final TextStyle? style;
  final double minFontSize;
  final double maxFontSize;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;
  final AutoSizeGroup? group;

  @override
  State<AutoSizeText> createState() => _AutoSizeTextState();
}

class _AutoSizeTextState extends State<AutoSizeText> {
  @override
  void initState() {
    super.initState();
    widget.group?._register(this);
  }

  @override
  void didUpdateWidget(AutoSizeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      oldWidget.group?._remove(this);
      widget.group?._register(this);
    }
  }

  void _notifySync() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFontSizeCalculated(double fontSize) =>
      widget.group?._updateFontSize(this, fontSize);

  @override
  Widget build(BuildContext context) {
    final double? groupFontSize = widget.group?._fontSize;
    final double? effectiveGroupFontSize =
        (groupFontSize != null && groupFontSize != double.infinity)
        ? groupFontSize
        : null;

    return _AutoSizeTextRenderWidget(
      text: widget.text,
      style: DefaultTextStyle.of(context).style.merge(widget.style),
      minFontSize: widget.minFontSize,
      maxFontSize: widget.maxFontSize,
      textAlign: widget.textAlign ?? TextAlign.start,
      textDirection: widget.textDirection ?? Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: widget.maxLines,
      groupFontSize: effectiveGroupFontSize,
      onFontSizeCalculated: _onFontSizeCalculated,
    );
  }

  @override
  void dispose() {
    widget.group?._remove(this);
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('minFontSize', widget.minFontSize));
    properties.add(DoubleProperty('maxFontSize', widget.maxFontSize));
    properties.add(IntProperty('maxLines', widget.maxLines));
  }
}

class _AutoSizeTextRenderWidget extends LeafRenderObjectWidget {
  const _AutoSizeTextRenderWidget({
    required this.text,
    required this.style,
    required this.minFontSize,
    required this.maxFontSize,
    required this.textAlign,
    required this.textDirection,
    required this.textScaler,
    required this.onFontSizeCalculated,
    this.maxLines,
    this.groupFontSize,
  });

  final String text;
  final TextStyle style;
  final double minFontSize;
  final double maxFontSize;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final int? maxLines;
  final double? groupFontSize;
  final ValueChanged<double> onFontSizeCalculated;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AutoSizeTextRenderBox(
        text: text,
        style: style,
        minFontSize: minFontSize,
        maxFontSize: maxFontSize,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: maxLines,
        groupFontSize: groupFontSize,
        onFontSizeCalculated: onFontSizeCalculated,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _AutoSizeTextRenderBox renderObject,
  ) => renderObject
    ..text = text
    ..style = style
    ..minFontSize = minFontSize
    ..maxFontSize = maxFontSize
    ..textAlign = textAlign
    ..textDirection = textDirection
    ..maxLines = maxLines
    ..groupFontSize = groupFontSize
    ..onFontSizeCalculated = onFontSizeCalculated;
}

class _AutoSizeTextRenderBox extends RenderBox {
  _AutoSizeTextRenderBox({
    required String text,
    required TextStyle style,
    required double minFontSize,
    required double maxFontSize,
    required TextAlign textAlign,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required ValueChanged<double> onFontSizeCalculated,
    int? maxLines,
    double? groupFontSize,
  }) : _text = text,
       _style = style,
       _minFontSize = minFontSize,
       _maxFontSize = maxFontSize,
       _textAlign = textAlign,
       _textDirection = textDirection,
       _textScaler = textScaler,
       _maxLines = maxLines,
       _groupFontSize = groupFontSize,
       _onFontSizeCalculated = onFontSizeCalculated;

  String _text;
  TextStyle _style;
  double _minFontSize;
  double _maxFontSize;
  TextAlign _textAlign;
  TextDirection _textDirection;
  TextScaler _textScaler;
  int? _maxLines;
  double? _groupFontSize;
  ValueChanged<double> _onFontSizeCalculated;

  TextPainter? _textPainter;

  String get text => _text;

  set text(String value) {
    if (_text == value) {
      return;
    }
    _text = value;
    _textPainter = null;
    markNeedsLayout();
  }

  TextStyle get style => _style;

  set style(TextStyle value) {
    if (_style == value) {
      return;
    }
    _style = value;
    _textPainter = null;
    markNeedsLayout();
  }

  double get minFontSize => _minFontSize;

  set minFontSize(double value) {
    if (_minFontSize == value) {
      return;
    }
    _minFontSize = value;
    markNeedsLayout();
  }

  double get maxFontSize => _maxFontSize;

  set maxFontSize(double value) {
    if (_maxFontSize == value) {
      return;
    }
    _maxFontSize = value;
    markNeedsLayout();
  }

  TextAlign get textAlign => _textAlign;

  set textAlign(TextAlign value) {
    if (_textAlign == value) {
      return;
    }
    _textAlign = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _textPainter = null;
    markNeedsLayout();
  }

  TextScaler get textScaler => _textScaler;

  set textScaler(TextScaler value) {
    if (_textScaler == value) {
      return;
    }
    _textScaler = value;
    _textPainter = null;
    markNeedsLayout();
  }

  int? get maxLines => _maxLines;

  set maxLines(int? value) {
    if (_maxLines == value) {
      return;
    }
    _maxLines = value;
    _textPainter = null;
    markNeedsLayout();
  }

  double? get groupFontSize => _groupFontSize;

  set groupFontSize(double? value) {
    if (_groupFontSize == value) {
      return;
    }
    _groupFontSize = value;
    _textPainter = null;
    markNeedsLayout();
  }

  ValueChanged<double> get onFontSizeCalculated => _onFontSizeCalculated;

  set onFontSizeCalculated(ValueChanged<double> value) {
    _onFontSizeCalculated = value;
  }

  @override
  void performLayout() {
    if (constraints.maxWidth == 0.0 || constraints.maxHeight == 0.0) {
      size = constraints.smallest;
      return;
    }

    // Calculate the optimal font size for this widget
    final double optimalFontSize = _computeOptimalFontSize(constraints);

    // Report the calculated font size to the group
    scheduleMicrotask(() => _onFontSizeCalculated(optimalFontSize));

    final double effectiveFontSize = _groupFontSize ?? optimalFontSize;

    _textPainter = _createTextPainter(effectiveFontSize);
    _textPainter!.layout(maxWidth: constraints.maxWidth);

    size = constraints.constrain(
      Size(_textPainter!.width, _textPainter!.height),
    );
  }

  double _computeOptimalFontSize(BoxConstraints constraints) {
    final double baseFontSize = _style.fontSize ?? 14.0;
    final double currentSize = math.min(
      baseFontSize,
      _maxFontSize == double.infinity ? baseFontSize : _maxFontSize,
    );

    double minSize = _minFontSize;
    double maxSize = currentSize;
    const double epsilon = 0.1;

    while (maxSize - minSize > epsilon) {
      final double midSize = (minSize + maxSize) / 2;
      final TextPainter painter = _createTextPainter(midSize);
      // Layout with maxWidth to allow text wrapping when maxLines is set
      painter.layout(maxWidth: constraints.maxWidth);

      if (_textFits(painter, constraints)) {
        minSize = midSize;
      } else {
        maxSize = midSize;
      }
    }

    // Verify that the final size allows the text to fit
    final TextPainter finalPainter = _createTextPainter(minSize);
    finalPainter.layout(maxWidth: constraints.maxWidth);

    if (!_textFits(finalPainter, constraints)) {
      // If it still doesn't fit, use the minimum size
      return _minFontSize;
    }

    return minSize;
  }

  /// Check if the text fits within the given constraints
  bool _textFits(TextPainter painter, BoxConstraints constraints) =>
      painter.width <= constraints.maxWidth &&
      painter.height <= constraints.maxHeight &&
      !painter.didExceedMaxLines;

  TextPainter _createTextPainter(double fontSize) => TextPainter(
    text: TextSpan(
      text: _text,
      style: _style.copyWith(fontSize: fontSize),
    ),
    textAlign: _textAlign,
    textDirection: _textDirection,
    textScaler: _textScaler,
    maxLines: _maxLines,
    ellipsis: _maxLines != null ? '…' : null,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    double translationX = 0.0;
    if (_textAlign == TextAlign.center) {
      translationX = (size.width - _textPainter!.width) / 2;
    } else if ((_textDirection == TextDirection.ltr &&
            _textAlign == TextAlign.right) ||
        (_textDirection == TextDirection.rtl && _textAlign == TextAlign.left) ||
        _textAlign == TextAlign.end) {
      translationX = size.width - _textPainter!.width;
    }

    _textPainter?.paint(context.canvas, offset.translate(translationX, 0));
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config
      ..label = _text
      ..textDirection = _textDirection;
  }
}

class AutoSizeGroup {
  AutoSizeGroup();

  final Map<_AutoSizeTextState, double> _listeners =
      <_AutoSizeTextState, double>{};
  bool _widgetsNotified = false;
  double _fontSize = double.infinity;

  void _register(_AutoSizeTextState text) {
    _listeners[text] = double.infinity;
  }

  void _updateFontSize(_AutoSizeTextState text, double maxFontSize) {
    final double oldFontSize = _fontSize;
    if (maxFontSize <= _fontSize) {
      _fontSize = maxFontSize;
      _listeners[text] = maxFontSize;
    } else if (_listeners[text] == _fontSize) {
      _listeners[text] = maxFontSize;
      _fontSize = double.infinity;
      for (final double size in _listeners.values) {
        if (size < _fontSize) {
          _fontSize = size;
        }
      }
    } else {
      _listeners[text] = maxFontSize;
    }

    if (oldFontSize != _fontSize) {
      _widgetsNotified = false;
      scheduleMicrotask(_notifyListeners);
    }
  }

  void _notifyListeners() {
    if (_widgetsNotified) {
      return;
    } else {
      _widgetsNotified = true;
    }

    for (final _AutoSizeTextState textState in _listeners.keys) {
      if (textState.mounted) {
        textState._notifySync();
      }
    }
  }

  void _remove(_AutoSizeTextState text) {
    _updateFontSize(text, double.infinity);
    _listeners.remove(text);
  }
}
