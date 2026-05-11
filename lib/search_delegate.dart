import 'package:flutter/material.dart';
import 'package:ndc/product_detail_page.dart';
import 'package:ndc/models/product.dart';

import 'app_logger.dart';
import 'core/core.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> allProducts;

  ProductSearchDelegate({required this.allProducts});

  // ─────────────────────────────────────────────
  // SEARCH FIELD STYLE
  // ─────────────────────────────────────────────

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0D1015),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
        ),

        border: InputBorder.none,
      ),

      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: query.isEmpty ? 0 : 1,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () {
              query = '';
              showSuggestions(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ),
      ),
    ];
  }

  // ─────────────────────────────────────────────
  // LEADING
  // ─────────────────────────────────────────────

  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () {
            close(context, '');
          },

          child: Ink(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),

              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),

              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  spreadRadius: -8,
                  offset: const Offset(0, 10),
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ],
            ),

            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FILTER
  // ─────────────────────────────────────────────

  List<Product> get filteredProducts {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return allProducts.take(12).toList();
    }

    return allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.tags.any((e) => e.toLowerCase().contains(q));
    }).toList();
  }

  // ─────────────────────────────────────────────
  // MODERN PRODUCT CARD
  // ─────────────────────────────────────────────

  Widget _buildModernCard(BuildContext context, Product product, int index) {
    final theme = Theme.of(context);

    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl.first
        : null;

    final hasSale = product.salePrice.trim().isNotEmpty;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 220 + (index * 35)),

      tween: Tween(begin: 0.96, end: 1.0),

      curve: Curves.easeOut,

      builder: (_, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },

      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(30),

            onTap: () {
              AppLogger.i('Search Result → ${product.id}');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },

            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Colors.white.withValues(alpha: 0.07),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),

                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),

                boxShadow: [
                  BoxShadow(
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 16),
                    color: Colors.black.withValues(alpha: 0.40),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(14),

                child: Row(
                  children: [
                    // IMAGE
                    Hero(
                      tag: 'search_product_${product.id}',

                      child: Container(
                        width: 96,
                        height: 96,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),

                          color: Colors.white.withValues(alpha: 0.04),
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),

                          child: imageUrl != null
                              ? appImage(imageUrl, fit: BoxFit.cover)
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 42,
                                  color: Colors.white38,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // TITLE
                          Text(
                            product.name,

                            maxLines: 2,

                            overflow: TextOverflow.ellipsis,

                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // TAGS
                          if (product.tags.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,

                              children: product.tags
                                  .take(2)
                                  .map((e) => appTagChip(context, e))
                                  .toList(),
                            ),

                          const SizedBox(height: 14),

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
                                const SizedBox(width: 10),

                                Text(
                                  '₹ ${product.price}',

                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.white38,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ARROW
                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: Colors.white.withValues(alpha: 0.05),
                      ),

                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // EMPTY
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
                Icons.search_off_rounded,
                size: 80,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 26),

            Text(
              'No products found',

              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 10),

            Text(
              'Try searching with another keyword.',
              textAlign: TextAlign.center,

              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RESULTS
  // ─────────────────────────────────────────────

  @override
  Widget buildResults(BuildContext context) {
    final results = filteredProducts;

    if (results.isEmpty) {
      return _buildEmpty(context);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),

      itemCount: results.length,

      itemBuilder: (_, i) {
        return _buildModernCard(context, results[i], i);
      },
    );
  }

  // ─────────────────────────────────────────────
  // SUGGESTIONS
  // ─────────────────────────────────────────────

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = filteredProducts;

    if (suggestions.isEmpty) {
      return _buildEmpty(context);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),

      itemCount: suggestions.length,

      itemBuilder: (_, i) {
        return _buildModernCard(context, suggestions[i], i);
      },
    );
  }
}
