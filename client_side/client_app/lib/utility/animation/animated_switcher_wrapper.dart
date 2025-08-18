import 'package:flutter/material.dart';

enum AnimationType {
  scale,
  slide,
  fade,
  rotation,
  slideUp,
  slideDown,
}

class AnimatedSwitcherWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final AnimationType animationType;

  const AnimatedSwitcherWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.animationType = AnimationType.scale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        switch (animationType) {
          case AnimationType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );

          case AnimationType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            );

          case AnimationType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            );

          case AnimationType.slideDown:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            );

          case AnimationType.rotation:
            return RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );

          case AnimationType.fade:
            return FadeTransition(opacity: animation, child: child);
        }
      },
      child: child,
    );
  }
}
