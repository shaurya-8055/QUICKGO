import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StaggeredAnimationController extends ChangeNotifier {
  final Map<String, bool> _visibilityMap = {};
  final Map<String, AnimationController> _controllers = {};
  final TickerProvider vsync;
  bool _isReducedMotion = false;

  StaggeredAnimationController({required this.vsync}) {
    _checkReducedMotion();
  }

  void _checkReducedMotion() {
    // Check for reduced motion preference
    // In a real app, you might check platform-specific settings
    _isReducedMotion = false; // Default to false for now
  }

  bool get isReducedMotion => _isReducedMotion;

  void setReducedMotion(bool value) {
    _isReducedMotion = value;
    notifyListeners();
  }

  AnimationController getController(
    String key, {
    Duration duration = const Duration(milliseconds: 200),
    Duration delay = Duration.zero,
  }) {
    if (_controllers.containsKey(key)) {
      return _controllers[key]!;
    }

    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    _controllers[key] = controller;

    // If reduced motion is enabled, complete immediately
    if (_isReducedMotion) {
      controller.value = 1.0;
    }

    return controller;
  }

  void setVisible(String key, bool isVisible,
      {Duration delay = Duration.zero}) {
    if (_visibilityMap[key] == isVisible) return;

    _visibilityMap[key] = isVisible;

    final controller = _controllers[key];
    if (controller == null) return;

    if (_isReducedMotion) {
      controller.value = isVisible ? 1.0 : 0.0;
      return;
    }

    if (isVisible) {
      Future.delayed(delay, () {
        if (_visibilityMap[key] == true && !controller.isCompleted) {
          controller.forward();
        }
      });
    } else {
      controller.reverse();
    }
  }

  bool isVisible(String key) => _visibilityMap[key] ?? false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _visibilityMap.clear();
    super.dispose();
  }
}

class StaggeredRevealItem extends StatefulWidget {
  final String itemKey;
  final int index;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Widget child;
  final StaggeredAnimationController controller;
  final double visibilityThreshold;

  const StaggeredRevealItem({
    Key? key,
    required this.itemKey,
    required this.index,
    required this.child,
    required this.controller,
    this.staggerDelay = const Duration(milliseconds: 75),
    this.animationDuration = const Duration(milliseconds: 200),
    this.visibilityThreshold = 0.15,
  }) : super(key: key);

  @override
  State<StaggeredRevealItem> createState() => _StaggeredRevealItemState();
}

class _StaggeredRevealItemState extends State<StaggeredRevealItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = widget.controller.getController(
      widget.itemKey,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation immediately if reduced motion is enabled
    if (widget.controller.isReducedMotion) {
      _animationController.value = 1.0;
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final isVisible = info.visibleFraction >= widget.visibilityThreshold;
    final delay = widget.staggerDelay * widget.index;

    widget.controller.setVisible(
      widget.itemKey,
      isVisible,
      delay: delay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.itemKey),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          if (widget.controller.isReducedMotion) {
            return widget.child;
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Don't dispose the controller here as it's managed by StaggeredAnimationController
    super.dispose();
  }
}
