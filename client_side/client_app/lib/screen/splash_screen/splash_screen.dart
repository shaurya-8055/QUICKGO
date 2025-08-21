import 'package:flutter/material.dart';
import '../login_screen/login_screen.dart';
import '../home_screen.dart';
import '../../utility/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _preloadEssentialData();
  }

  Future<void> _preloadEssentialData() async {
    // Preload user session, products, and categories
    await Future.wait([
      context.dataProvider.getAllProduct(),
      context.dataProvider.getAllCategory(),
      Future.delayed(const Duration(milliseconds: 400)), // minimal splash delay
    ]);
    final user = context.userProvider.getLoginUsr();
    final nextScreen = user?.sId == null ? const LoginScreen() : const HomeScreen();

    // Fade transition to next screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
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
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
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
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Color(0xFF00F5FF),
                      offset: Offset(0, 0),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Future of Shopping',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF00F5FF).withOpacity(0.8),
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00F5FF).withOpacity(0.5),
                    offset: const Offset(0, 0),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
