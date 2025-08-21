import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

Widget buildShimmerPlaceholder(
    double? width, double? height, BorderRadius? borderRadius) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    ),
  );
}

Widget buildErrorWidget(
    double? width, double? height, BorderRadius? borderRadius) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: borderRadius,
    ),
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey,
      size: 32,
    ),
  );
}

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double scale;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.scale = 1.0,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return _FadeInNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      shimmer: buildShimmerPlaceholder(width, height, borderRadius),
      errorWidget: buildErrorWidget(width, height, borderRadius),
    );
  }
}

class _FadeInNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget shimmer;
  final Widget errorWidget;

  const _FadeInNetworkImage({
    required this.imageUrl,
    required this.fit,
    this.width,
    this.height,
    this.borderRadius,
    required this.shimmer,
    required this.errorWidget,
  });

  @override
  State<_FadeInNetworkImage> createState() => _FadeInNetworkImageState();
}

class _FadeInNetworkImageState extends State<_FadeInNetworkImage> {
  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      widget.imageUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        final isLoaded = wasSynchronouslyLoaded || frame != null;
        return AnimatedOpacity(
          opacity: isLoaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.shimmer;
      },
      errorBuilder: (context, error, stackTrace) => widget.errorWidget,
    );
    if (widget.borderRadius != null) {
      image = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: image,
      );
    }
    return image;
  }

  Widget buildShimmerPlaceholder(
      double? width, double? height, BorderRadius? borderRadius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget buildErrorWidget(
      double? width, double? height, BorderRadius? borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}
