import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../login_screen/login_screen.dart';
import '../home_screen.dart';
import '../../utility/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _fireworksController;
  late AnimationController _spinnerController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _fireworksAnimation;
  late Animation<double> _spinnerAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Glow effect controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Fireworks controller
    _fireworksController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Spinner controller
    _spinnerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Background gradient controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat(reverse: true);

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    // Fireworks animation
    _fireworksAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireworksController,
      curve: Curves.easeInOut,
    ));

    // Spinner animation
    _spinnerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinnerController,
      curve: Curves.linear,
    ));

    // Background animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start background and particle animations immediately
    _backgroundController.forward();
    _particleController.forward();

    // Delay for dramatic effect
    await Future.delayed(const Duration(milliseconds: 800));

    // Start logo animation
    _logoController.forward();

    // Start fireworks after logo appears
    await Future.delayed(const Duration(milliseconds: 1200));
    _fireworksController.forward();

    // Wait for full experience before navigation
    await Future.delayed(const Duration(milliseconds: 3500));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    final user = context.userProvider.getLoginUsr();
    final nextScreen =
        user?.sId == null ? const LoginScreen() : const HomeScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _fireworksController.dispose();
    _spinnerController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF0F0F23), const Color(0xFF1A1A2E),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF16213E), const Color(0xFF0F3460),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF0F3460), const Color(0xFF16213E),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF1A1A2E), const Color(0xFF0F0F23),
                      _backgroundAnimation.value)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                AnimatedBuilder(
                  animation: _particleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter:
                          FuturisticParticlesPainter(_particleAnimation.value),
                      size: Size.infinite,
                    );
                  },
                ),

                // Fireworks effect
                AnimatedBuilder(
                  animation: _fireworksAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: FireworksPainter(_fireworksAnimation.value),
                      size: Size.infinite,
                    );
                  },
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with glowing effect
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Opacity(
                              opacity: _logoOpacityAnimation.value,
                              child: AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF00F5FF)
                                              .withOpacity(0.3),
                                          const Color(0xFF0080FF)
                                              .withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 0.7, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00F5FF)
                                              .withOpacity(
                                                  0.6 * _glowAnimation.value),
                                          blurRadius: 30 * _glowAnimation.value,
                                          spreadRadius:
                                              10 * _glowAnimation.value,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF0080FF)
                                              .withOpacity(
                                                  0.4 * _glowAnimation.value),
                                          blurRadius: 60 * _glowAnimation.value,
                                          spreadRadius:
                                              20 * _glowAnimation.value,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF00F5FF),
                                            Color(0xFF0080FF),
                                            Color(0xFF0040FF),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // App name with futuristic styling
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return const LinearGradient(
                                      colors: [
                                        Color(0xFF00F5FF),
                                        Color(0xFF0080FF),
                                        Color(0xFFFFFFFF),
                                      ],
                                      stops: [0.0, 0.5, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'ECommerce Pro',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2.0,
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFF00F5FF),
                                          offset: Offset(0, 0),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Future of Shopping',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF00F5FF)
                                        .withOpacity(0.8),
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF00F5FF)
                                            .withOpacity(0.5),
                                        offset: const Offset(0, 0),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 80),

                      // Futuristic spinner
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: AnimatedBuilder(
                              animation: _spinnerAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: FuturisticSpinnerPainter(
                                      _spinnerAnimation.value),
                                  size: const Size(60, 60),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Futuristic particles painter
class FuturisticParticlesPainter extends CustomPainter {
  final double animationValue;

  FuturisticParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating particles with neon glow
    for (int i = 0; i < 80; i++) {
      final x = (i * 47.3 + animationValue * 50) % size.width;
      final y = (i * 31.7 + animationValue * 30) % size.height;
      final radius = (math.sin(animationValue * 2 * math.pi + i) * 2 + 3).abs();

      // Outer glow
      paint.color = const Color(0xFF00F5FF).withOpacity(0.3);
      canvas.drawCircle(Offset(x, y), radius * 2, paint);

      // Inner particle
      paint.color = const Color(0xFF00F5FF).withOpacity(0.8);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Connecting lines between nearby particles
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF00F5FF).withOpacity(0.2);

    for (int i = 0; i < 20; i++) {
      final x1 = (i * 47.3 + animationValue * 50) % size.width;
      final y1 = (i * 31.7 + animationValue * 30) % size.height;
      final x2 = ((i + 1) * 47.3 + animationValue * 50) % size.width;
      final y2 = ((i + 1) * 31.7 + animationValue * 30) % size.height;

      final distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
      if (distance < 100) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Fireworks painter
class FireworksPainter extends CustomPainter {
  final double animationValue;

  FireworksPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Multiple firework bursts
    for (int burst = 0; burst < 4; burst++) {
      final centerX = size.width * (0.2 + burst * 0.2);
      final centerY = size.height * (0.3 + (burst % 2) * 0.4);
      final burstProgress = (animationValue + burst * 0.25) % 1.0;

      // Each burst has multiple sparks
      for (int spark = 0; spark < 12; spark++) {
        final angle = spark * 2 * math.pi / 12;
        final distance = burstProgress * 100;
        final sparkX = centerX + math.cos(angle) * distance;
        final sparkY = centerY + math.sin(angle) * distance;

        // Fade out as distance increases
        final opacity = (1.0 - burstProgress).clamp(0.0, 1.0);
        final sparkSize = (1.0 - burstProgress * 0.7) * 4;

        // Gradient colors for each spark
        final colors = [
          const Color(0xFFFFD700),
          const Color(0xFF00F5FF),
          const Color(0xFFFF1493),
          const Color(0xFF32CD32),
        ];

        paint.color = colors[spark % 4].withOpacity(opacity);

        // Draw spark with glow
        canvas.drawCircle(Offset(sparkX, sparkY), sparkSize, paint);

        // Add glow effect
        paint.color = colors[spark % 4].withOpacity(opacity * 0.3);
        canvas.drawCircle(Offset(sparkX, sparkY), sparkSize * 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Futuristic spinner painter
class FuturisticSpinnerPainter extends CustomPainter {
  final double animationValue;

  FuturisticSpinnerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Outer ring with gradient
    final outerSweepGradient = SweepGradient(
      startAngle: animationValue * 2 * math.pi,
      endAngle: animationValue * 2 * math.pi + math.pi,
      colors: [
        Colors.transparent,
        const Color(0xFF00F5FF),
        const Color(0xFF0080FF),
        Colors.transparent,
      ],
    );

    paint.shader = outerSweepGradient
        .createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 5, paint);

    // Inner ring with opposite rotation
    final innerSweepGradient = SweepGradient(
      startAngle: -animationValue * 3 * math.pi,
      endAngle: -animationValue * 3 * math.pi + math.pi * 0.7,
      colors: [
        Colors.transparent,
        const Color(0xFFFF1493),
        const Color(0xFF00F5FF),
        Colors.transparent,
      ],
    );

    paint.shader = innerSweepGradient
        .createShader(Rect.fromCircle(center: center, radius: radius * 0.7));
    paint.strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.7, paint);

    // Center pulse
    paint.shader = null;
    paint.style = PaintingStyle.fill;
    final pulseOpacity =
        (math.sin(animationValue * 4 * math.pi) * 0.3 + 0.7).clamp(0.0, 1.0);
    paint.color = const Color(0xFF00F5FF).withOpacity(pulseOpacity);
    canvas.drawCircle(center, 8, paint);

    // Center glow
    paint.color = const Color(0xFF00F5FF).withOpacity(pulseOpacity * 0.3);
    canvas.drawCircle(center, 15, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
