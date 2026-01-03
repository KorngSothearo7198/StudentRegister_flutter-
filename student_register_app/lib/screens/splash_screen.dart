


// lib/screens/splash_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'student/student_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _fishController;
  late Animation<double> _fadeAnimation;

  // Slide animations
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;

  // Fish animations
  final List<_FishAnimation> _fishes = [];

  @override
  void initState() {
    super.initState();

    // Main animation (2s)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.elasticOut));

    _titleSlide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.elasticOut));

    _subtitleSlide = Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.elasticOut));

    // Fish controller (continuous)
    _fishController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Create 6 flying fish
    final random = Random();
    for (int i = 0; i < 6; i++) {
      _fishes.add(_FishAnimation(
        delay: random.nextDouble() * 2,
        duration: 4 + random.nextDouble() * 4,
        startX: random.nextBool() ? -0.3 : 1.3,
        endX: random.nextBool() ? 1.3 : -0.3,
        startY: random.nextDouble(),
        endY: random.nextDouble(),
        size: 30 + random.nextDouble() * 30,
      ));
    }

    _mainController.forward();

    // After 3 seconds → go to StudentHomeScreen
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const StudentHomeScreen(
            student: {
              
            }, studentName: '', openChatStudent: {},
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _fishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0066CC),
      body: Stack(
        children: [
          // Flying Fish (Background)
          ..._fishes.map((fish) => _buildFlyingFish(fish, size)),

          // Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: _logoSlide,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 160,
                      height: 160,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _titleSlide,
                    child: const Text(
                      "Student Register",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideTransition(
                    position: _subtitleSlide,
                    child: const Text(
                      "Students Registration App ",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildPulsingLoader(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlyingFish(_FishAnimation fish, Size screenSize) {
    return AnimatedBuilder(
      animation: _fishController,
      builder: (context, child) {
        final progress = (_fishController.value * _fishController.duration!.inMilliseconds -
                fish.delay * 1000) %
            fish.duration *
            1000 /
            (fish.duration * 1000);

        if (progress < 0) return const SizedBox();

        final x = fish.startX + (fish.endX - fish.startX) * progress;
        final y = fish.startY + (fish.endY - fish.startY) * progress;

        return Positioned(
          left: x * screenSize.width,
          top: y * screenSize.height,
          child: Transform.rotate(
            angle: progress < 0.5 ? 0.2 : -0.2,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/fish.png', // ADD THIS
                width: fish.size,
                height: fish.size,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingLoader() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_mainController.value * 0.4),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        );
      },
    );
  }
}

// Fish animation config
class _FishAnimation {
  final double delay;
  final double duration;
  final double startX;
  final double endX;
  final double startY;
  final double endY;
  final double size;

  _FishAnimation({
    required this.delay,
    required this.duration,
    required this.startX,
    required this.endX,
    required this.startY,
    required this.endY,
    required this.size,
  });
}