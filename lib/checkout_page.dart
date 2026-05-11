// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndc/cart.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'app_logger.dart';

class CheckoutPage extends StatefulWidget {
  final String vendorWhatsAppNumber;

  const CheckoutPage({super.key, this.vendorWhatsAppNumber = ''});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _showItems = false;

  // ─────────────────────────────────────────────
  // MESSAGE
  // ─────────────────────────────────────────────

  String buildWhatsAppMessage(Cart cart) {
    final b = StringBuffer();

    b.writeln('🛍️ NAV DURGA COLLECTION');
    b.writeln('');
    b.writeln('━━━━━━━━━━━━━━━━━━');

    for (final it in cart.items.values) {
      b.writeln(it.name);

      b.writeln(
        'Qty ${it.qty} × ₹${it.price.toStringAsFixed(0)} = ₹${it.total.toStringAsFixed(0)}',
      );

      b.writeln('━━━━━━━━━━━━━━━━━━');
    }

    b.writeln('');
    b.writeln('TOTAL : ₹${cart.totalAmount.toStringAsFixed(0)}');

    return b.toString();
  }

  // ─────────────────────────────────────────────
  // SEND TO WHATSAPP
  // ─────────────────────────────────────────────

  Future<void> _sendToWhatsApp(Cart cart) async {
    if (cart.itemCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));

      return;
    }

    final msg = buildWhatsAppMessage(cart);
    final encoded = Uri.encodeComponent(msg);

    if (widget.vendorWhatsAppNumber.isEmpty) {
      await Clipboard.setData(ClipboardData(text: msg));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor no. is not available')),
      );

      return;
    }

    final num = widget.vendorWhatsAppNumber.replaceAll('+', '');

    final url = 'https://wa.me/$num?text=$encoded';

    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);

      AppLogger.d('WhatsApp launched');

      cart.clear();

      Navigator.of(context).pop();

      showSuccessPopup(context);
    } catch (e) {
      AppLogger.e('WhatsApp launch failed: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open WhatsApp')));
    }
  }

  // ─────────────────────────────────────────────
  // ORDER SUMMARY
  // ─────────────────────────────────────────────

  Widget _buildSummary(Cart cart) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, 16),
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP HANDLE
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            // TITLE
            Text(
              'Order Summary',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${cart.distinctCount} products • ${cart.itemCount} items',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),

            const SizedBox(height: 22),

            // MESSAGE PREVIEW
            buildWhatsAppMessagePreview(context, buildWhatsAppMessage(cart)),

            const SizedBox(height: 22),

            // TOTAL
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '₹${cart.totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // VIEW ITEMS
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _showItems = !_showItems;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showItems
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        _showItems ? 'Hide Order Items' : 'View Order Items',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: !_showItems
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: cart.items.values.map((it) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    it.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Text(
                                  'x${it.qty}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
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
      backgroundColor: const Color(0xFF0E1014),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                'Review Your Order',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your order will be shared via WhatsApp.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // SUMMARY
              _buildSummary(cart),

              const SizedBox(height: 28),

              // SEND BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _sendToWhatsApp(cart),

                  icon: const Icon(Icons.message_outlined),

                  label: const Text('Send Order via WhatsApp'),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // SMALL NOTE
              Center(
                child: Text(
                  'Shipping charges are excluded.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WHATSAPP PREVIEW
// ─────────────────────────────────────────────

Widget buildWhatsAppMessagePreview(BuildContext context, String message) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      image: const DecorationImage(
        image: AssetImage('assets/WABG.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 54, 26),
        decoration: BoxDecoration(
          color: const Color(0xFFE7FFDB),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.45,
              ),
            ),

            Positioned(
              bottom: -14,
              right: -34,
              child: Row(
                children: [
                  Text(
                    formatTime(),
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.done_all,
                    size: 16,
                    color: Color(0xFF4FC3F7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// TIME FORMAT
// ─────────────────────────────────────────────

String formatTime() {
  final now = DateTime.now();

  final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;

  final minute = now.minute.toString().padLeft(2, '0');

  final period = now.hour >= 12 ? 'pm' : 'am';

  return '$hour:$minute $period';
}

// ─────────────────────────────────────────────
// SUCCESS POPUP
// ─────────────────────────────────────────────

void showSuccessPopup(BuildContext context) {
  Timer? timer = Timer(const Duration(seconds: 5), () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  });

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: const Color(0xFF161A20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 90,
                  color: Colors.greenAccent,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Order Sent!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your order has been shared successfully via WhatsApp.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    timer.cancel();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) => timer.cancel());
}
