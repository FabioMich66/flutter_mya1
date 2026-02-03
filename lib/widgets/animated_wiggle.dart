import 'package:flutter/material.dart';

class AnimatedWiggle extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const AnimatedWiggle({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  State<AnimatedWiggle> createState() => _AnimatedWiggleState();
}

class _AnimatedWiggleState extends State<AnimatedWiggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: -0.02,
      upperBound: 0.02,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
