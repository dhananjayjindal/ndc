import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ndc/sheets_service.dart';

import '/app_logger.dart';
import '/models/product.dart';

Widget appImage(
  String url, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  BorderRadius? borderRadius,
}) {
  AppLogger.d('[appImage] Loading → $url');

  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.circular(18),

    child: CachedNetworkImage(
      imageUrl: url,

      width: width,

      height: height,

      fit: fit,

      // PERFORMANCE
      filterQuality: FilterQuality.low,

      memCacheWidth: 900,

      maxWidthDiskCache: 1200,

      fadeInDuration: const Duration(milliseconds: 180),

      fadeOutDuration: const Duration(milliseconds: 100),

      // LOADING
      placeholder: (context, url) {
        AppLogger.d('[appImage] Placeholder → $url');

        return Container(
          width: width,
          height: height,

          alignment: Alignment.center,

          color: Colors.white.withValues(alpha: 0.03),

          child: const SizedBox(
            width: 24,
            height: 24,

            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        );
      },

      // SUCCESS
      imageBuilder: (context, imageProvider) {
        AppLogger.s('[appImage] Loaded Successfully');

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        );
      },

      // ERROR
      errorWidget: (context, url, error) {
        AppLogger.e('[appImage] Failed → $url', error);

        return Container(
          width: width,
          height: height,

          alignment: Alignment.center,

          color: Colors.white.withValues(alpha: 0.03),

          child: const Icon(
            Icons.broken_image_outlined,

            size: 36,

            color: Colors.white38,
          ),
        );
      },
    ),
  );
}

Widget appTagChip(BuildContext context, String tag) {
  final tagLower = tag.toLowerCase().trim();

  // 🚫 Do not build anything for "other"
  if (tagLower == 'other' || tagLower.isEmpty) {
    return const SizedBox.shrink();
  }

  final textTheme = Theme.of(context).textTheme;

  String label = tag;

  Color bgColor = Theme.of(context).colorScheme.secondaryContainer;
  Color textColor = Theme.of(context).colorScheme.onSecondaryContainer;
  // BorderSide border = BorderSide.none;

  switch (tagLower) {
    case 'hot':
      label = 'Hot 🔥';
      bgColor = const Color(0xFFFFE0E0);
      textColor = const Color(0xFFD32F2F);
      break;

    case 'onsale':
    case 'on sale':
      label = 'On Sale 🏷️';
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1976D2);
      break;

    case 'new':
      label = 'New ✨';
      bgColor = const Color(0xFFF3E5F5);
      textColor = const Color(0xFF7B1FA2);
      break;

    default:
      bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      // border: border,
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          offset: const Offset(0, 2),
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ],
    ),
    child: Text(
      label,
      style: textTheme.labelSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
  );
}

Widget glassButton({required IconData icon, required VoidCallback onTap}) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

enum ProductFilter { all, newest, trending, sale }

class ProductFilters {
  static List<Product> apply(List<Product> products, ProductFilter filter) {
    switch (filter) {
      case ProductFilter.newest:
        return products
            .where((p) => p.tags.any((e) => e.toLowerCase() == 'new'))
            .toList();

      case ProductFilter.trending:
        return products
            .where((p) => p.tags.any((e) => e.toLowerCase() == 'hot'))
            .toList();

      case ProductFilter.sale:
        return products.where((p) => p.salePrice.trim().isNotEmpty).toList();

      case ProductFilter.all:
        return products;
    }
  }
}

class PriceUtils {
  static double parse(String value) {
    return double.tryParse(value) ?? 0;
  }

  static bool hasSale(String price, String salePrice) {
    return parse(salePrice) > 0 && parse(salePrice) < parse(price);
  }

  static int discountPercent(String price, String salePrice) {
    final p = parse(price);
    final s = parse(salePrice);

    if (p <= 0 || s >= p) {
      return 0;
    }

    return (((p - s) / p) * 100).round();
  }

  static String finalPrice(String price, String salePrice) {
    return hasSale(price, salePrice) ? salePrice : price;
  }
}

class ProductRepository {
  static List<Product>? _cache;

  static Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) {
      return _cache!;
    }

    final products = await fetchProducts();

    _cache = products;

    return products;
  }
}

class AppCachedImage extends StatelessWidget {
  final String imageUrl;

  final BoxFit fit;

  final double? width;

  final double? height;

  final BorderRadius? borderRadius;

  final Widget? placeholder;

  final Widget? errorWidget;

  final bool enableMemoryCache;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[AppCachedImage] Building → $imageUrl');

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(18),

      child: CachedNetworkImage(
        imageUrl: imageUrl,

        width: width,

        height: height,

        fit: fit,

        fadeInDuration: const Duration(milliseconds: 180),

        fadeOutDuration: const Duration(milliseconds: 120),

        memCacheWidth: enableMemoryCache ? 900 : null,

        maxWidthDiskCache: 1200,

        filterQuality: FilterQuality.low,

        placeholder: (context, url) {
          AppLogger.d('[AppCachedImage] Loading → $url');

          return placeholder ??
              Container(
                color: Colors.white.withValues(alpha: 0.03),

                alignment: Alignment.center,

                child: const SizedBox(
                  width: 24,
                  height: 24,

                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              );
        },

        imageBuilder: (context, imageProvider) {
          AppLogger.s('[AppCachedImage] Loaded');

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: fit),
            ),
          );
        },

        errorWidget: (context, url, error) {
          AppLogger.e('[AppCachedImage] Failed → $url', error);

          return errorWidget ??
              Container(
                color: Colors.white.withValues(alpha: 0.03),

                alignment: Alignment.center,

                child: const Icon(
                  Icons.broken_image_outlined,

                  size: 36,

                  color: Colors.white38,
                ),
              );
        },
      ),
    );
  }
}
