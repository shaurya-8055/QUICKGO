import 'provider/cart_provider.dart';
import '../../utility/extensions.dart';
import '../../utility/currency_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../utility/animation/animated_switcher_wrapper.dart';
import '../../utility/app_color.dart';
import 'components/buy_now_bottom_sheet.dart';
import 'components/cart_list_section.dart';
import 'components/empty_cart.dart';
import '../home_screen.dart';
import '../profile_screen/provider/profile_provider.dart';
import '../my_address_screen/my_address_screen.dart';

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

          final profileProvider = Provider.of<ProfileProvider>(context);
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Address section
                if (profileProvider.addresses.isEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.purpleGradientStart,
                          AppColor.purpleGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.purpleGradientStart.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off,
                            size: 44, color: Colors.white),
                        const SizedBox(height: 14),
                        Text(
                          'No address found! Please add your delivery address to proceed.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyAddressPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Add Address'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.primary.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select Delivery Address',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MyAddressPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_location_alt_outlined,
                                  size: 20),
                              label: const Text('Add Address'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size(0, 0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final idx = profileProvider.selectedAddressIndex;
                            if (idx == null ||
                                idx < 0 ||
                                idx >= profileProvider.addresses.length) {
                              return const Text('No address selected.');
                            }
                            final address = profileProvider.addresses[idx];
                            return Container(
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: cs.primary, width: 1.5),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.deepPurple),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(address.phone,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            '${address.street}, ${address.city}, ${address.state} ${address.postalCode}, ${address.country}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

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
                          Text(
                            CurrencyHelper.formatCurrencyCompact(
                                context.cartProvider.getGrandTotal()),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
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
                          onPressed: profileProvider.selectedAddressIndex ==
                                  null
                              ? null
                              : () {
                                  // Copy selected address to CartProvider controllers
                                  final selectedIdx =
                                      profileProvider.selectedAddressIndex;
                                  if (selectedIdx != null &&
                                      selectedIdx >= 0 &&
                                      selectedIdx <
                                          profileProvider.addresses.length) {
                                    final addr =
                                        profileProvider.addresses[selectedIdx];
                                    final cartProvider = context.cartProvider;
                                    cartProvider.phoneController.text =
                                        addr.phone;
                                    cartProvider.streetController.text =
                                        addr.street;
                                    cartProvider.cityController.text =
                                        addr.city;
                                    cartProvider.stateController.text =
                                        addr.state;
                                    cartProvider.postalCodeController.text =
                                        addr.postalCode;
                                    cartProvider.countryController.text =
                                        addr.country;
                                  }
                                  showCustomBottomSheet(context);
                                },
                          label: const Text('Checkout Securely'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
