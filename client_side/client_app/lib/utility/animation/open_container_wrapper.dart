import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper({
    super.key,
    required this.child,
    required this.nextScreen,
    this.transitionType = ContainerTransitionType.fade,
    this.borderRadius = 25.0,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.closedColor,
  });

  final Widget child;
  final Widget nextScreen;
  final ContainerTransitionType transitionType;
  final double borderRadius;
  final Duration transitionDuration;
  final Color? closedColor;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      closedColor: closedColor ?? Colors.transparent,
      transitionType: transitionType,
      transitionDuration: transitionDuration,
      closedElevation: 0,
      openElevation: 0,
      closedBuilder: (context, VoidCallback openContainer) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: openContainer,
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 100),
              child: child,
            ),
          ),
        );
      },
      openBuilder: (context, _) => nextScreen,
    );
  }
}
