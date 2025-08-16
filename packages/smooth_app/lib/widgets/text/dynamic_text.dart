// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

/// A simple implementation that checks if the [child] fits the bounds.
/// If not, it will use the [replacement].
class SmoothDynamicLayout
    extends
        SlottedMultiChildRenderObjectWidget<_SmoothDynamicLayoutId, RenderBox> {
  const SmoothDynamicLayout({
    required this.child,
    required this.replacement,
    super.key,
  });

  final Widget child;
  final Widget replacement;

  @override
  Widget? childForSlot(_SmoothDynamicLayoutId slot) => switch (slot) {
    _SmoothDynamicLayoutId.child => child,
    _SmoothDynamicLayoutId.replacement => replacement,
  };

  @override
  SlottedContainerRenderObjectMixin<_SmoothDynamicLayoutId, RenderBox>
  createRenderObject(BuildContext context) => _SmoothDynamicTextRenderObject();

  @override
  Iterable<_SmoothDynamicLayoutId> get slots => const <_SmoothDynamicLayoutId>[
    _SmoothDynamicLayoutId.child,
    _SmoothDynamicLayoutId.replacement,
  ];
}

enum _SmoothDynamicLayoutId { child, replacement }

class _SmoothDynamicTextRenderObject extends RenderBox
    with SlottedContainerRenderObjectMixin<_SmoothDynamicLayoutId, RenderBox> {
  _SmoothDynamicTextRenderObject();

  _SmoothDynamicLayoutId _currentId = _SmoothDynamicLayoutId.child;

  @override
  void performLayout() {
    Size childSize = _layoutChild(
      _SmoothDynamicLayoutId.child,
      unconstraint: true,
    );

    if (childSize.width > constraints.maxWidth) {
      childSize = _layoutChild(_SmoothDynamicLayoutId.replacement);
      _currentId = _SmoothDynamicLayoutId.replacement;
    } else {
      childSize = _layoutChild(_SmoothDynamicLayoutId.child);
      _currentId = _SmoothDynamicLayoutId.child;
    }

    size = constraints.constrain(childSize);
  }

  Size _layoutChild(_SmoothDynamicLayoutId id, {bool unconstraint = false}) {
    final RenderBox renderBox = childForSlot(id)!;
    renderBox.layout(
      unconstraint ? const BoxConstraints() : constraints,
      parentUsesSize: true,
    );
    return renderBox.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox child = childForSlot(_SmoothDynamicLayoutId.child)!;
    final RenderBox replacement = childForSlot(
      _SmoothDynamicLayoutId.replacement,
    )!;

    if (_currentId == _SmoothDynamicLayoutId.child) {
      context.paintChild(child, offset);
    } else {
      context.paintChild(replacement, offset);
    }
  }
}
