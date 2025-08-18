import 'provider/cart_provider.dart';
import '../../utility/extensions.dart';
import '../../utility/currency_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utility/animation/animated_switcher_wrapper.dart';
import 'components/buy_now_bottom_sheet.dart';
import 'components/cart_list_section.dart';
import 'components/empty_cart.dart';
import '../home_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      context.cartProvider.getCartItems();
    });
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: const Text('My Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) => IconButton(
              tooltip: 'Clear cart',
              onPressed: cart.myCartItems.isEmpty
                  ? null
                  : () => context.cartProvider.clearCartItems(),
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.myCartItems.isEmpty) {
            return const EmptyCart();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cart items
              CartListSection(cartProducts: cartProvider.myCartItems),

              // Coupon input
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cartProvider.couponController,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? const Color(0xFF171A20)
                              : const Color(0xFFF7F8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: theme.dividerColor.withOpacity(0.15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: theme.dividerColor.withOpacity(0.15)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => cartProvider.checkCoupon(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),

              // Totals card + checkout
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: theme.dividerColor.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _totalRow(
                        'Subtotal',
                        CurrencyHelper.formatCurrencyCompact(
                            cartProvider.getCartSubTotal()),
                        theme),
                    if (cartProvider.couponApplied != null)
                      _totalRow(
                          'Discount',
                          '-${CurrencyHelper.formatCurrencyCompact(cartProvider.couponCodeDiscount)}',
                          theme,
                          valueColor: cs.error),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        AnimatedSwitcherWrapper(
                          child: Text(
                            CurrencyHelper.formatCurrencyCompact(
                                context.cartProvider.getGrandTotal()),
                            key: ValueKey<double>(cartProvider.getGrandTotal()),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.lock_rounded),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => showCustomBottomSheet(context),
                        label: const Text('Checkout Securely'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _totalRow(String label, String value, ThemeData theme,
    {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}
