import '../../product_by_category_screen/product_by_category_screen.dart';
import '../../../utility/animation/open_container_wrapper.dart';
import 'package:flutter/material.dart';
import '../../../models/category.dart';

class CategorySelector extends StatefulWidget {
  final List<Category> categories;

  const CategorySelector({
    super.key,
    required this.categories,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  List<AnimationController> _itemControllers = [];
  List<Animation<double>> _itemAnimations = [];
  int _previousCategoryCount = 0;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _updateAnimationControllers();
  }

  @override
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories.length != widget.categories.length) {
      _updateAnimationControllers();
    }
  }

  void _updateAnimationControllers() {
    // Dispose old controllers
    for (var controller in _itemControllers) {
      controller.dispose();
    }

    // Create new controllers for current categories
    _itemControllers = List.generate(
      widget.categories.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _itemAnimations = _itemControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Update stagger controller duration
    _staggerController.duration =
        Duration(milliseconds: widget.categories.length * 100 + 500);

    if (widget.categories.isNotEmpty &&
        _previousCategoryCount != widget.categories.length) {
      _startStaggeredAnimation();
      _previousCategoryCount = widget.categories.length;
    }
  }

  void _startStaggeredAnimation() async {
    if (_itemControllers.isEmpty) return;

    // Ensure all items appear within ~1 second total
    final count = _itemControllers.length;
    const totalMs = 1000; // 1 second cap
    // Compute per-item delay; clamp to reasonable bounds
    final perDelayMs =
        (totalMs / (count == 0 ? 1 : count)).clamp(10, 200).toInt();

    // Start first item immediately for snappy feel
    if (mounted) {
      _itemControllers.first.forward();
    }

    for (int i = 1; i < count; i++) {
      final delay = Duration(milliseconds: i * perDelayMs);
      Future.delayed(delay, () {
        if (!mounted) return;
        if (i < _itemControllers.length) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if no categories or animations not ready
    if (widget.categories.isEmpty ||
        _itemAnimations.length != widget.categories.length) {
      return Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Compute size to fit N cards based on screen width (responsive)
    final screenW = MediaQuery.of(context).size.width;
    final bool isTablet = screenW >= 720;
    // Choose visible count by breakpoint so it feels natural across devices
    final int visibleCount = screenW < 340
        ? 5
        : (screenW < 420 ? 6 : (screenW < 600 ? 7 : (screenW < 900 ? 8 : 10)));
    const listHPadding = 12.0; // matches ListView horizontal padding
    final spacing = isTablet ? 8.0 : 6.0; // slightly more room on tablets
    final cardW =
        ((screenW - (listHPadding * 2) - spacing * (visibleCount - 1)) /
                visibleCount)
            .clamp(68.0, 120.0);
    // Height = image (flex) + label. Our label is ~2 lines max; budget ~22px.
    final cardH = cardW + 22; // room for label + small gap

    return Container(
      height: cardH + 16, // include a bit of vertical padding
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: listHPadding),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];

          // Safety check to prevent range errors
          if (index >= _itemAnimations.length ||
              index >= _itemControllers.length) {
            return const SizedBox.shrink();
          }

          return AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _itemAnimations[index].value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - _itemAnimations[index].value)),
                  child: Opacity(
                    opacity: (_itemAnimations[index].value.clamp(0.0, 1.0))
                        .toDouble(),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                      child: OpenContainerWrapper(
                        nextScreen: ProductByCategoryScreen(
                            selectedCategory: widget.categories[index]),
                        child: _PortraitCategoryCard(
                          category: category,
                          index: index,
                          width: cardW,
                          height: cardH,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// A compact portrait card with a landscape image on top and text below.
class _PortraitCategoryCard extends StatefulWidget {
  final Category category;
  final int index;
  final double width;
  final double height;
  const _PortraitCategoryCard(
      {required this.category,
      required this.index,
      required this.width,
      required this.height});

  @override
  State<_PortraitCategoryCard> createState() => _PortraitCategoryCardState();
}

class _PortraitCategoryCardState extends State<_PortraitCategoryCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag =
        'category_${widget.category.sId ?? widget.category.name ?? 'idx_${widget.index}'}';
    final isSelected = widget.category.isSelected;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF667eea)
              : theme.dividerColor.withOpacity(0.15),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag: tag,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: (widget.category.image != null &&
                          widget.category.image!.isNotEmpty)
                      ? Image.network(
                          widget.category.image!,
                          key: ValueKey('img_${widget.category.image}'),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stack) {
                            return Container(
                              color: theme.colorScheme.surfaceVariant,
                              alignment: Alignment.center,
                              child: Icon(Icons.category,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6)),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: theme.colorScheme.surfaceVariant,
                          alignment: Alignment.center,
                          child: Icon(Icons.category,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF667eea)
                    : theme.colorScheme.onSurface.withOpacity(0.85),
                fontSize: (widget.width / 8.5).clamp(11.0, 12.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              child: Text(
                widget.category.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
