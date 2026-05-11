import 'package:flutter/material.dart';
import 'package:ndc/models/product.dart';
import 'package:ndc/product_detail_page.dart';

import 'app_logger.dart';
import 'core/core.dart';

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String? percentOff(String price, String salePrice) {
  try {
    if (price.isEmpty || salePrice.isEmpty) {
      return null;
    }

    final p = double.parse(price);
    final s = double.parse(salePrice);

    if (p <= 0 || s >= p) {
      return null;
    }

    return '${(((p - s) / p) * 100).round()}% OFF';
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────
// PRODUCT IMAGE
// ─────────────────────────────────────────────

Widget productImage({
  required BuildContext context,
  required String heroTag,
  required String? imageUrl,
  BorderRadius? radius,
}) {
  return Hero(
    tag: heroTag,

    child: ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(28),

      child: Stack(
        fit: StackFit.expand,

        children: [
          Container(color: const Color(0xFF161A20)),

          if (imageUrl != null)
            appImage(imageUrl, fit: BoxFit.cover)
          else
            const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 52,
                color: Colors.white38,
              ),
            ),

          // GRADIENT
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black38, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// SALE BADGE
// ─────────────────────────────────────────────

Widget modernSaleBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),

      gradient: const LinearGradient(
        colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      ),

      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          offset: const Offset(0, 8),
          color: Colors.red.withValues(alpha: 0.25),
        ),
      ],
    ),

    child: Text(
      text,

      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// MODERN GRID CARD
// ─────────────────────────────────────────────

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasSale = PriceUtils.hasSale(product.price, product.salePrice);

    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl.first
        : null;

    final badgeText = hasSale
        ? percentOff(product.price, product.salePrice)
        : null;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 280),

      tween: Tween(begin: 0.96, end: 1.0),

      curve: Curves.easeOut,

      builder: (_, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },

      child: GestureDetector(
        onTap: () {
          AppLogger.i('Grid Product Opened → ${product.id}');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),

            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),

            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                spreadRadius: -8,
                offset: const Offset(0, 16),
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // IMAGE
              Expanded(
                flex: 7,

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: productImage(
                        context: context,
                        heroTag: 'product_img_${product.id}',
                        imageUrl: imageUrl,
                        radius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                    ),

                    if (badgeText != null)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: modernSaleBadge(badgeText),
                      ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                flex: 4,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // TITLE
                      Text(
                        product.name,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),

                      const Spacer(),

                      // PRICE
                      Row(
                        children: [
                          Text(
                            '₹ ${hasSale ? product.salePrice : product.price}',

                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          if (hasSale) ...[
                            const SizedBox(width: 8),

                            Text(
                              '₹ ${product.price}',

                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 10),

                      // TAGS
                      if (product.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,

                          children: product.tags
                              .take(3)
                              .map((e) => appTagChip(context, e))
                              .toList(),
                        ),
                    ],
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

// ─────────────────────────────────────────────
// MODERN LIST CARD
// ─────────────────────────────────────────────

class ProductListCard extends StatelessWidget {
  final Product product;

  const ProductListCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasSale = PriceUtils.hasSale(product.price, product.salePrice);

    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl.first
        : null;

    final badgeText = hasSale
        ? percentOff(product.price, product.salePrice)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: GestureDetector(
        onTap: () {
          AppLogger.i('List Product Opened → ${product.id}');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },

        child: Container(
          height: 170,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),

            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),

            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                spreadRadius: -8,
                offset: const Offset(0, 18),
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ],
          ),

          child: Row(
            children: [
              // IMAGE
              Expanded(
                flex: 4,

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: productImage(
                        context: context,
                        heroTag: 'product_img_${product.id}',
                        imageUrl: imageUrl,
                        radius: const BorderRadius.horizontal(
                          left: Radius.circular(34),
                        ),
                      ),
                    ),

                    if (badgeText != null)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: modernSaleBadge(badgeText),
                      ),
                  ],
                ),
              ),

              // DETAILS
              Expanded(
                flex: 6,

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // TITLE
                      Text(
                        product.name,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // TAGS
                      if (product.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,

                          children: product.tags
                              .take(4)
                              .map((e) => appTagChip(context, e))
                              .toList(),
                        ),

                      const Spacer(),

                      // PRICE
                      Row(
                        children: [
                          Text(
                            '₹ ${hasSale ? product.salePrice : product.price}',

                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          if (hasSale) ...[
                            const SizedBox(width: 10),

                            Text(
                              '₹ ${product.price}',

                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.white38,
                              ),
                            ),
                          ],

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),

                              color: Colors.white.withValues(alpha: 0.05),
                            ),

                            child: Text(
                              '#${product.id}',

                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
