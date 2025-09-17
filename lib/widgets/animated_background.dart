import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math';

// Helper class for particle rendering
class ParticleModel {
  late Animatable<double> _tween;
  late double _size;
  late Duration _duration;
  late Duration _startTime;
  late Color _color;
  late ParticleType _type;

  ParticleModel(Random random) {
    _tween = Tween(begin: 0.0, end: 1.0);
    _duration = Duration(milliseconds: 3000 + random.nextInt(6000));
    _startTime = Duration(milliseconds: random.nextInt(8000));
    _size = 0.5 + random.nextDouble() * 2.5;
    _color = Colors.white.withOpacity(random.nextDouble() * 0.3 + 0.1);
    _type = random.nextBool() ? ParticleType.circle : ParticleType.square;
  }

  // --- THE FIX IS HERE: Accept 'screenSize' as a parameter ---
  Widget build(BuildContext context, Duration time, Size screenSize) {
    final simulation = _tween.transform(
      (time.inMilliseconds - _startTime.inMilliseconds).remainder(_duration.inMilliseconds) / _duration.inMilliseconds,
    );
    
    // Calculate actual position based on screen size
    final dx = 0.8 * screenSize.width * simulation; // Move mostly horizontal
    final dy = (simulation - 0.5).abs() * screenSize.height * 0.4; // Subtle vertical bounce

    return Positioned(
      left: dx + (simulation * screenSize.width * 0.2), // Adjust horizontal speed
      top: dy + (simulation * screenSize.height * 0.6), // Adjust vertical position
      child: IgnorePointer(
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: _color,
            shape: _type == ParticleType.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: _type == ParticleType.square ? BorderRadius.circular(1) : null,
          ),
        ),
      ),
    );
  }
}

enum ParticleType { circle, square }

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your base gradient for depth
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF121212),
                Color(0xFF1A1A1A),
              ],
            ),
          ),
        ),
        // The particle layer
        Positioned.fill(child: Particles(200)), // 200 particles for density
      ],
    );
  }
}

class Particles extends StatefulWidget {
  final int numberOfParticles;

  const Particles(this.numberOfParticles, {super.key});

  @override
  State<Particles> createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random _random = Random();
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.numberOfParticles; i++) {
      particles.add(ParticleModel(_random));
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- THE FIX IS HERE: Get screen size and pass it down ---
    final screenSize = MediaQuery.of(context).size;

    return LoopAnimationBuilder(
      tween: ConstantTween(1),
      duration: const Duration(seconds: 10),
      builder: (context, value, child) {
        return Stack(
          children: particles.map((p) => p.build(context, Duration(milliseconds: DateTime.now().millisecondsSinceEpoch), screenSize)).toList(),
        );
      },
    );
  }
}