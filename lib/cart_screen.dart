import 'package:flutter/material.dart';
import 'package:ndc/cart.dart';
import 'package:ndc/checkout_page.dart';
import 'package:provider/provider.dart';

import 'core/core.dart';
import 'sheets_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  bool isWeb(BuildContext context) => MediaQuery.of(context).size.width >= 700;

  bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width <= 700;

  // ─────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 70,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Your cart feels empty.',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 10),

            Text(
              'Looks like you haven’t added anything yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 26),

            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QUANTITY BUTTON
  // ─────────────────────────────────────────────

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CART LIST
  // ─────────────────────────────────────────────

  Widget _buildCartList(BuildContext context, Cart cart) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: cart.distinctCount,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final item = cart.items.values.toList()[i];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 250 + (i * 60)),
          tween: Tween(begin: 0.94, end: 1),
          curve: Curves.easeOut,
          builder: (_, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Dismissible(
            key: ValueKey(item.id),
            direction: isWeb(context)
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.red.shade400,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            onDismissed: (_) => cart.removeItem(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    spreadRadius: -8,
                    offset: const Offset(0, 14),
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // IMAGE
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                      child: item.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: appImage(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 40),
                    ),

                    const SizedBox(width: 16),

                    // DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '₹ ${item.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),

                          const SizedBox(height: 14),

                          // QUANTITY CONTROLS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _qtyButton(
                                  icon: Icons.remove,
                                  onTap: () => cart.decrement(item.id),
                                ),

                                const SizedBox(width: 14),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  transitionBuilder: (child, anim) {
                                    return ScaleTransition(
                                      scale: anim,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    item.qty.toString(),
                                    key: ValueKey(item.qty),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                _qtyButton(
                                  icon: Icons.add,
                                  onTap: () => cart.increment(item.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // DELETE
                    IconButton(
                      onPressed: () => cart.removeItem(item.id),
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // SUMMARY
  // ─────────────────────────────────────────────

  Widget _buildSummary(BuildContext context, Cart cart) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF161A20),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, -10),
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HANDLE
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹ ${cart.totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${cart.distinctCount} products • ${cart.itemCount} items',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 22),

          // CHECKOUT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: cart.itemCount == 0
                  ? null
                  : () async {
                      final vendorNo = await fetchMobileNumber();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckoutPage(vendorWhatsAppNumber: vendorNo),
                        ),
                      );
                    },
            ),
          ),

          const SizedBox(height: 10),

          // CLEAR BUTTON
         SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed:
                  cart.itemCount ==
                      0
                  ? null
                  : () async {
                      final confirm =
                          await showDialog<
                            bool
                          >(
                            context: context,
                            builder:
                                (
                                  context,
                                ) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  title: const Text(
                                    'Clear Cart?',
                                  ),
                                  content: const Text(
                                    'Are you sure you want to remove all items from the cart?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        false,
                                      ),
                                      child: const Text(
                                        'Cancel',
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        true,
                                      ),
                                      child: const Text(
                                        'Clear',
                                      ),
                                    ),
                                  ],
                                ),
                          );

                      if (confirm ==
                          true) {
                        cart.clear();
                      }
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
              child: const Text(
                'Clear Cart',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: cart.itemCount == 0
          ? _buildEmpty(context)
          : isPhone(context)
          ? Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildCartList(context, cart),
                  ),
                ),

                _buildSummary(context, cart),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildCartList(context, cart),
                  ),
                ),

                SizedBox(width: 420, child: _buildSummary(context, cart)),
              ],
            ),
    );
  }
}
