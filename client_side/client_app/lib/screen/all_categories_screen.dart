import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../core/data/data_provider.dart';
import '../utility/animation/animated_switcher_wrapper.dart';
import 'product_by_category_screen/product_by_category_screen.dart';
import '../utility/animation/open_container_wrapper.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen>
    with TickerProviderStateMixin {
  late DataProvider dataProvider;
  List<Category> categories = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late AnimationController _gridAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  String searchQuery = '';
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      categories = await dataProvider.getAllCategory();
      setState(() {
        isLoading = false;
      });
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _gridAnimationController.forward();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Category> get filteredCategories {
    if (searchQuery.isEmpty) {
      return categories;
    }
    return categories
        .where((category) =>
            category.name!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gridAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf093fb),
              Color(0xFFf5576c),
              Color(0xFF4facfe),
              Color(0xFF00f2fe),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _fadeInAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeInAnimation.value,
                              child: const Text(
                                'All Categories',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Search button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              isSearchActive = !isSearchActive;
                            });
                            if (isSearchActive) {
                              _searchAnimationController.forward();
                            } else {
                              _searchAnimationController.reverse();
                              searchQuery = '';
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isSearchActive ? 60 : 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Categories Grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF667eea)),
                          ),
                        )
                      : AnimatedSwitcherWrapper(
                          animationType: AnimationType.scale,
                          duration: const Duration(milliseconds: 500),
                          child: GridView.builder(
                            key: ValueKey(filteredCategories.length),
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: () {
                                final w = MediaQuery.of(context).size.width;
                                if (w >= 1200) return 6;
                                if (w >= 900) return 5;
                                if (w >= 700) return 4;
                                if (w >= 520) return 3;
                                return 2;
                              }(),
                              // Slightly taller on phones, tighter on tablets
                              childAspectRatio: () {
                                final w = MediaQuery.of(context).size.width;
                                if (w >= 900) return 1.05;
                                if (w >= 700) return 1.0;
                                return 0.95;
                              }(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredCategories.length,
                            itemBuilder: (context, index) {
                              final category = filteredCategories[index];
                              return AnimatedBuilder(
                                animation: _gridAnimationController,
                                builder: (context, child) {
                                  final animationValue = Curves.easeOutBack
                                      .transform(
                                        (_gridAnimationController.value -
                                                (index * 0.1))
                                            .clamp(0.0, 1.0),
                                      )
                                      .clamp(0.0, 1.0);

                                  return Transform.scale(
                                    scale: animationValue,
                                    child: Opacity(
                                      opacity: animationValue,
                                      child: CategoryCard(
                                        category: category,
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final Category category;
  final int index;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.index,
  }) : super(key: key);

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapAnimationController;
  late Animation<double> _tapScaleAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _tapScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
      [const Color(0xFFffc3a0), const Color(0xFFffafbd)],
    ];

    final gradient = gradients[widget.index % gradients.length];

    return AnimatedBuilder(
      animation: _tapScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _tapScaleAnimation.value,
          child: OpenContainerWrapper(
            borderRadius: 16,
            nextScreen: ProductByCategoryScreen(
              selectedCategory: widget.category,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.category,
                              color: Colors.white.withOpacity(0.95), size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.category.name ?? 'Category',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
