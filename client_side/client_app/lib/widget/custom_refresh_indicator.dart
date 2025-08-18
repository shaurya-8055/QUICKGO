import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pullController;
  late AnimationController _refreshController;
  late Animation<double> _pullAnimation;
  late Animation<double> _rotationAnimation;

  bool _isRefreshing = false;
  final double _refreshTriggerDistance = 80.0;

  @override
  void initState() {
    super.initState();
    _pullController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pullAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pullController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _pullController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _refreshController.reset();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.extentBefore == 0.0) {
          final overscroll = notification.metrics.pixels;

          if (overscroll < 0) {
            final pullProgress =
                (-overscroll / _refreshTriggerDistance).clamp(0.0, 1.0);
            _pullController.value = pullProgress;

            if (pullProgress >= 1.0 && !_isRefreshing) {
              _handleRefresh();
            }
          }
        }

        if (notification is ScrollEndNotification) {
          if (!_isRefreshing) {
            _pullController.reverse();
          }
        }

        return false;
      },
      child: Stack(
        children: [
          widget.child,
          // Custom refresh indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pullAnimation,
              builder: (context, child) {
                if (_pullAnimation.value == 0.0 && !_isRefreshing) {
                  return const SizedBox.shrink();
                }

                return Container(
                  height: _pullAnimation.value * 60,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation:
                          _isRefreshing ? _rotationAnimation : _pullAnimation,
                      builder: (context, child) {
                        if (_isRefreshing) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Icon(
                              Icons.refresh,
                              color: widget.color ?? const Color(0xFF667eea),
                              size: 24,
                            ),
                          );
                        } else {
                          return Transform.rotate(
                            angle: _pullAnimation.value * math.pi,
                            child: Icon(
                              Icons.arrow_downward,
                              color: widget.color ?? const Color(0xFF667eea),
                              size: 24,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
