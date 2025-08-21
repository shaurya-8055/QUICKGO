import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final Function(double)? onRatingChanged;
  final bool interactive;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.onRatingChanged,
    this.interactive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive
              ? () => onRatingChanged?.call((index + 1).toDouble())
              : null,
          child: Icon(
            _getStarIcon(index),
            size: size,
            color: _getStarColor(index, activeStarColor, inactiveStarColor),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int index) {
    double starValue = index + 1;
    if (rating >= starValue) {
      return Icons.star;
    } else if (allowHalfRating && rating >= starValue - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index, Color activeColor, Color inactiveColor) {
    double starValue = index + 1;
    if (rating >= starValue) {
      return activeColor;
    } else if (allowHalfRating && rating >= starValue - 0.5) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(double) onRatingChanged;

  const InteractiveStarRating({
    Key? key,
    this.initialRating = 0,
    this.size = 30,
    this.activeColor,
    this.inactiveColor,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = widget.activeColor ?? Colors.amber;
    final inactiveStarColor = widget.inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = (index + 1).toDouble();
            });
            widget.onRatingChanged(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              _rating > index ? Icons.star : Icons.star_border,
              size: widget.size,
              color: _rating > index ? activeStarColor : inactiveStarColor,
            ),
          ),
        );
      }),
    );
  }
}
