import 'package:flutter/material.dart';
import 'package:ndc/cart.dart';
import 'package:ndc/models/product.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'app_logger.dart';
import 'core/core.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final PageController _pageController;

  int _activeIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    AppLogger.i('Open ProductDetailPage → ${widget.product.id}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // DISCOUNT
  // ─────────────────────────────────────────────

  String? get discountText {
    try {
      final p = double.parse(widget.product.price);
      final s = double.parse(widget.product.salePrice);

      if (s >= p || p <= 0) return null;

      return '${(((p - s) / p) * 100).round()}% OFF';
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // ADD TO CART
  // ─────────────────────────────────────────────

  void _addToCart() {
    Provider.of<Cart>(
      context,
      listen: false,
    ).addItem(widget.product, _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        content: Text(
          '$_quantity item(s) added to cart',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // IMAGE CAROUSEL
  // ─────────────────────────────────────────────

  Widget _buildCarousel() {
    final images = widget.product.imageUrl
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (images.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 90,
          color: Colors.white38,
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (i) {
            setState(() {
              _activeIndex = i;
            });
          },
          itemBuilder: (_, i) {
            final imageUrl = images[i];

            final heroTag = 'product_${widget.product.id}_$i';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageViewer(
                      imageUrl: imageUrl,
                      heroTag: heroTag,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: heroTag,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(34),
                      child: appImage(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // BACK BUTTON
        Positioned(
          top: 60,
          left: 20,
          child: glassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),

        // SHARE BUTTON
        // Positioned(
        //   top: 60,
        //   right: 20,
        //   child: _glassButton(
        //     icon: Icons.favorite_border_rounded,
        //     onTap: () {},
        //   ),
        // ),

        // PAGE INDICATORS
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == _activeIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.22),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // GLASS BUTTON
  // ─────────────────────────────────────────────

  // Widget _glassButton({
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     borderRadius: BorderRadius.circular(18),
  //     onTap: onTap,
  //     child: Container(
  //       width: 52,
  //       height: 52,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(18),
  //         color: Colors.black.withValues(alpha: 0.5),
  //         border: Border.all(
  //           color: Colors.white.withValues(alpha: 0.6),
  //         ),
  //       ),
  //       child: Icon(
  //         icon,
  //         color: Colors.white,
  //       ),
  //     ),
  //   );
  // }

  // ─────────────────────────────────────────────
  // QUANTITY CONTROLS
  // ─────────────────────────────────────────────

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ───────────────────────────────────
          // IMAGE SECTION
          // ───────────────────────────────────
          SliverAppBar(
            expandedHeight: (MediaQuery.of(context).size.height * 0.52).clamp(
              360.0,
              560.0,
            ),
            // pinned: false,
            stretch: true,

            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCarousel(),
              stretchModes: [StretchMode.zoomBackground],
            ),
          ),

          // ───────────────────────────────────
          // CONTENT
          // ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TAGS
                  Row(
                    children: [
                      if (discountText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.redAccent,
                          ),
                          child: Text(
                            discountText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        child: Text(
                          '#${product.id}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 16,
                    thickness: 1.5,
                  ),

                  // GALLERY
                  if (product.imageUrl.length > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gallery',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: product.imageUrl.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, idx) {
                              final image = product.imageUrl[idx];

                              final active = idx == _activeIndex;

                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    idx,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );

                                  setState(() {
                                    _activeIndex = idx;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 96,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      width: active ? 2 : 1,
                                      color: active
                                          ? Colors.white
                                          : Colors.white10,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: appImage(image, fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // TITLE
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PRICE
                  buildModernPriceText(context, product),

                  const SizedBox(height: 8),

                  Text(
                    '* Inclusive of all taxes and charges',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '* Exclusive savings on larger orders',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // DESCRIPTION CARD
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.045),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          spreadRadius: -8,
                          offset: const Offset(0, 8),
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 18,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Product Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          product.description.trim().isEmpty
                              ? 'No description available.'
                              : product.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // VIDEO
                  if (product.videoUrl.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Video',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 14),

                        VideoPreviewButton(videoUrl: product.videoUrl),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────────
      // BOTTOM BAR
      // ─────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF15181E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                offset: const Offset(0, -10),
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ],
          ),
          child: Row(
            children: [
              // QUANTITY
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    _qtyButton(
                      icon: Icons.remove_rounded,
                      onTap: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : () {},
                    ),

                    const SizedBox(width: 14),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        '$_quantity',
                        key: ValueKey(_quantity),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    _qtyButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // BUTTON
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,

                  icon: const Icon(Icons.shopping_bag_outlined),

                  label: const Text('Add to Cart'),

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
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FULLSCREEN VIEWER
// ─────────────────────────────────────────────

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            maxScale: 4,
            child: appImage(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MODERN PRICE TEXT
// ─────────────────────────────────────────────

Widget
buildModernPriceText(
  BuildContext context,
  Product product,
) {
  final theme = Theme.of(
    context,
  );

  final hasSale =
      product.salePrice.trim().isNotEmpty &&
      product.salePrice !=
          product.price;

  return RichText(
    text: TextSpan(
      children: hasSale
          ? [
              TextSpan(
                text: '₹${product.price}',
                style: theme.textTheme.titleLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 2,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const WidgetSpan(
                child: SizedBox(
                  width: 12,
                ),
              ),

              TextSpan(
                text: '₹${product.salePrice}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ]
          : [
              TextSpan(
                text: '₹${product.price}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
    ),
  );
}

// ─────────────────────────────────────────────
// YOUTUBE VIDEO PREVIEW
// ─────────────────────────────────────────────

class VideoPreviewButton extends StatefulWidget {
  final String videoUrl;

  const VideoPreviewButton({super.key, required this.videoUrl});

  @override
  State<VideoPreviewButton> createState() => _VideoPreviewButtonState();
}

class _VideoPreviewButtonState extends State<VideoPreviewButton> {
  bool _showPlayer = false;

  String? get videoId =>
      YoutubePlayerController.convertUrlToId(widget.videoUrl);

  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
        videoId: videoId ?? '',
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true,
        ),
      );

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoId == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: 280, // tweak if needed
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: _showPlayer
                ? YoutubePlayer(controller: _controller)
                : InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() {
                        _showPlayer = true;
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppCachedImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                        ),

                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 52,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Positioned(
                          left: 16,
                          bottom: 18,
                          child: Text(
                            'Watch Product Video',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
