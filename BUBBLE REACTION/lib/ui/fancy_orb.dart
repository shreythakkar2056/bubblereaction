import 'dart:math' as math;
import 'package:flutter/material.dart';

class FancyOrb extends StatefulWidget {
  final Color color;
  final double size;
  const FancyOrb({required this.color, required this.size, super.key});

  @override
  State<FancyOrb> createState() => _FancyOrbState();
}

class _FancyOrbState extends State<FancyOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.97 + 0.1 * math.sin(_controller.value * 2 * math.pi);
        final rotation = _controller.value * 2 * math.pi;
        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.color.withAlpha((0.95 * 255).round()),
              widget.color.withAlpha((0.7 * 255).round()),
              Colors.black.withAlpha((0.5 * 255).round()),
            ],
            stops: const [0.0, 0.7, 1.0],
            center: const Alignment(-0.3, -0.3),
            radius: 0.95,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha((0.35 * 255).round()),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: widget.color.withAlpha((0.18 * 255).round()),
              blurRadius: 24,
              spreadRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Align(
          alignment: const Alignment(-0.5, -0.7),
          child: Container(
            width: widget.size * 0.18,
            height: widget.size * 0.12,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.13 * 255).round()),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 