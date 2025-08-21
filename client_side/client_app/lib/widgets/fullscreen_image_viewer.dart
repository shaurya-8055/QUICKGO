import 'package:flutter/material.dart';
import '../../widget/custom_network_image.dart';

class FullscreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTagPrefix;

  const FullscreenImageViewer({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    required this.heroTagPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: initialIndex);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: Hero(
                  tag: '${heroTagPrefix}_$index',
                  child: InteractiveViewer(
                    child: CustomNetworkImage(
                      imageUrl: imageUrls[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
