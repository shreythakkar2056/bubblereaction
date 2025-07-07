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
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.92 + 0.13 * math.sin(_controller.value * 2 * math.pi);
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
              widget.color.withOpacity(0.95),
              widget.color.withOpacity(0.7),
              Colors.black.withOpacity(0.5),
            ],
            stops: const [0.0, 0.7, 1.0],
            center: const Alignment(-0.3, -0.3),
            radius: 0.95,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.85),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 8,
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
              color: Colors.white.withOpacity(0.18),
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