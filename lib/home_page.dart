import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'app_logger.dart';
import 'cart.dart';
import 'cart_screen.dart';
import 'core/core.dart';
import 'models/product.dart';
import 'product_tile.dart';
import 'search_delegate.dart';
import 'sheets_service.dart';
import 'tabbar.dart';

class HomePage
    extends
        StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<
    HomePage
  >
  createState() => _HomePageState();
}

class _HomePageState
    extends
        State<
          HomePage
        > {
  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  bool loading = true;

  bool useGrid = true;

  int selectedTab = 0;

  List<
    Product
  >
  products = [];

  List<
    Product
  >
  filtered = [];

  // ─────────────────────────────────────────────
  // SCROLL
  // ─────────────────────────────────────────────

  final ScrollController _scrollController = ScrollController();

  double scrollOffset = 0;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    AppLogger.i(
      '[HomePage] INIT',
    );

    _scrollController.addListener(
      _onScroll,
    );

    loadProducts();
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────

  @override
  void dispose() {
    AppLogger.w(
      '[HomePage] DISPOSE',
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SCROLL
  // ─────────────────────────────────────────────

  void _onScroll() {
    final offset = _scrollController.offset;

    if (offset ==
        scrollOffset) {
      return;
    }

    setState(
      () {
        scrollOffset = offset;
      },
    );
  }

  // ─────────────────────────────────────────────
  // LOAD PRODUCTS
  // ─────────────────────────────────────────────

  Future<void> loadProducts() async {
    AppLogger.i('[HomePage] Loading Products...');

    try {
      final fetched = await ProductRepository.getProducts();

      AppLogger.s('[HomePage] ${fetched.length} Products Loaded');

      fetched.sort((a, b) => b.id.compareTo(a.id));

      AppLogger.d('[HomePage] Products Sorted');

      if (!mounted) {
        AppLogger.w('[HomePage] Widget Unmounted During Load');

        return;
      }

      products = fetched;

      applyFilter();

      setState(() {
        loading = false;
      });

      AppLogger.s('[HomePage] UI Updated');
    } catch (e, stack) {
      AppLogger.e('[HomePage] loadProducts Error', e, stack);

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    }
  }

  // ─────────────────────────────────────────────
  // REFRESH
  // ─────────────────────────────────────────────

  Future<
    void
  >
  _refresh() async {
    AppLogger.i(
      '[HomePage] Refresh Triggered',
    );

    setState(
      () {
        loading = true;
      },
    );

    try {
      final refreshed = await ProductRepository.getProducts(
        forceRefresh: true,
      );

      AppLogger.s(
        '[HomePage] Refresh Success → ${refreshed.length} Products',
      );

      refreshed.sort(
        (
          a,
          b,
        ) => b.id.compareTo(
          a.id,
        ),
      );

      products = refreshed;

      applyFilter();

      if (!mounted) {
        return;
      }

      setState(
        () {
          loading = false;
        },
      );
    } catch (
      e,
      stack
    ) {
      AppLogger.e(
        '[HomePage] Refresh Error',
        e,
        stack,
      );

      if (!mounted) {
        return;
      }

      setState(
        () {
          loading = false;
        },
      );
    }
  }

  // ─────────────────────────────────────────────
  // FILTERS
  // ─────────────────────────────────────────────

  bool hasTag(
    Product product,
    String tag,
  ) {
    return product.tags.any(
      (
        e,
      ) =>
          e.trim().toLowerCase() ==
          tag.toLowerCase(),
    );
  }

  void applyFilter() {
    AppLogger.d(
      '[HomePage] Applying Filter → Tab $selectedTab',
    );

    switch (selectedTab) {
      case 1:
        filtered = products
            .where(
              (
                e,
              ) => hasTag(
                e,
                'new',
              ),
            )
            .toList();

        break;

      case 2:
        filtered = products
            .where(
              (
                e,
              ) => hasTag(
                e,
                'hot',
              ),
            )
            .toList();

        break;

      case 3:
        filtered = products
            .where(
              (
                e,
              ) => hasTag(
                e,
                'onsale',
              ),
            )
            .toList();

        break;

      default:
        filtered = products;
    }

    AppLogger.s(
      '[HomePage] Filtered Count → ${filtered.length}',
    );
  }

  String get sectionTitle {
    switch (selectedTab) {
      case 1:
        return '✨ New Arrivals';

      case 2:
        return '🔥 Trending Now';

      case 3:
        return '🏷️ On Sale';

      default:
        return '🛍️ All Products';
    }
  }

  // ─────────────────────────────────────────────
  // RESPONSIVE
  // ─────────────────────────────────────────────

  bool isWeb(
    BuildContext context,
  ) {
    return MediaQuery.of(
          context,
        ).size.width >=
        700;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(
    BuildContext context,
  ) {
    AppLogger.d(
      '[HomePage] BUILD',
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFF0C0F14,
      ),

      extendBodyBehindAppBar: true,

      appBar: _buildAppBar(
        context,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refresh,

              child: CustomScrollView(
                controller: _scrollController,

                physics: const BouncingScrollPhysics(),

                slivers: [
                  // HERO
                  SliverToBoxAdapter(
                    child: _buildHero(),
                  ),

                  // TAB BAR
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 12,
                      ),

                      child: HomeTabBar(
                        selectedIndex: selectedTab,

                        onTap:
                            (
                              i,
                            ) {
                              AppLogger.i(
                                '[HomePage] Tab Changed → $i',
                              );

                              setState(
                                () {
                                  selectedTab = i;

                                  applyFilter();
                                },
                              );
                            },
                      ),
                    ),
                  ),

                  // SECTION TITLE
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        18,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              sectionTitle,

                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,

                                    letterSpacing: -1,
                                  ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                18,
                              ),

                              color: Colors.white.withValues(
                                alpha: 0.06,
                              ),
                            ),

                            child: Text(
                              '${filtered.length} items',

                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // EMPTY
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  // PRODUCTS
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        120,
                      ),

                      sliver: useGrid
                          ? _buildGrid()
                          : _buildList(),
                    ),
                ],
              ),
            ),

      floatingActionButton: _buildFloatingButton(),
    );
  }

  // ─────────────────────────────────────────────
  // APPBAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    final bg = Color.lerp(
      Colors.transparent,
      const Color(
        0xFF0D1015,
      ),
      (scrollOffset /
              180)
          .clamp(
            0,
            1,
          ),
    );

    return AppBar(
      elevation: 0,

      backgroundColor: bg,

      leadingWidth: 72,

      titleSpacing: 0,

      leading: Padding(
        padding: const EdgeInsets.only(
          left: 16,
        ),

        child: GestureDetector(
          onTap: () {
            AppLogger.i(
              '[HomePage] About Popup Opened',
            );

            showAboutPopup(
              context,
            );
          },

          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
            ),

            padding: const EdgeInsets.all(
              10,
            ),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.white.withValues(
                alpha: 0.08,
              ),
            ),

            child: Image.asset(
              AppImages.logo,

              filterQuality: FilterQuality.low,
            ),
          ),
        ),
      ),

      actions: [
        _appBarButton(icon: Icons.camera_alt_outlined, onTap: () async {
          AppLogger.i(
            '[HomePage] Instagram Button Pressed',
          );

          final uri = Uri.parse(
            'https://www.instagram.com/navdurgacollections_bathinda',
          );

          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          }
        }),
        _appBarButton(
          icon: Icons.fact_check_outlined,

          onTap: () async {
            AppLogger.i(
              '[HomePage] Fetching Update Logs',
            );

            try {
              final logs = await fetchUpdateLogs();

              if (!context.mounted) {
                return;
              }

              showUpdateLogsPopup(
                context,
                logs,
              );
            } catch (
              e,
              stack
            ) {
              AppLogger.e(
                '[HomePage] Update Logs Error',
                e,
                stack,
              );
            }
          },
        ),

        _appBarButton(
          icon: Icons.search_rounded,

          onTap: () {
            AppLogger.i(
              '[HomePage] Search Opened',
            );

            showSearch(
              context: context,
              delegate: ProductSearchDelegate(
                allProducts: products,
              ),
            );
          },
        ),

        Selector<
          Cart,
          int
        >(
          selector:
              (
                _,
                cart,
              ) => cart.itemCount,

          builder:
              (
                _,
                count,
                _,
              ) {
                return Stack(
                  children: [
                    _appBarButton(
                      icon: Icons.shopping_bag_outlined,

                      onTap: () {
                        AppLogger.i(
                          '[HomePage] Cart Opened',
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  _,
                                ) => const CartScreen(),
                          ),
                        );
                      },
                    ),

                    if (count >
                        0)
                      Positioned(
                        top: 10,
                        right: 10,

                        child: Container(
                          width: 18,
                          height: 18,

                          alignment: Alignment.center,

                          decoration: const BoxDecoration(
                            color: Colors.redAccent,

                            shape: BoxShape.circle,
                          ),

                          child: Text(
                            count.toString(),

                            style: const TextStyle(
                              fontSize: 10,

                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
        ),

        _appBarButton(
          icon: Icons.qr_code_rounded,

          onTap: () {
            AppLogger.i(
              '[HomePage] QR Popup Opened',
            );

            showQrCodePopup(
              context,
            );
          },
        ),

        const SizedBox(
          width: 12,
        ),
      ],
    );
  }

  Widget _appBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isInstagram =
        icon ==
        Icons.camera_alt_outlined;

    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          18,
        ),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              18,
            ),
            gradient: isInstagram
                ? const LinearGradient(
                    colors: [
                      Color(
                        0xFFF58529,
                      ),
                      Color(
                        0xFFDD2A7B,
                      ),
                      Color(
                        0xFF8134AF,
                      ),
                    ],
                  )
                : null,
            color: isInstagram
                ? null
                : Colors.white.withValues(
                    alpha: 0.06,
                  ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HERO
  // ─────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      height: 280,

      padding: const EdgeInsets.fromLTRB(
        24,
        120,
        24,
        26,
      ),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [
            Colors.deepPurple.withValues(
              alpha: 0.18,
            ),

            const Color(
              0xFF0C0F14,
            ),
          ],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Nav Durga Collection',

            style:
                Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,

                  letterSpacing: -2,

                  height: 0.95,
                ),
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                22,
              ),

              color: Colors.white.withValues(
                alpha: 0.04,
              ),

              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.03,
                ),
              ),
            ),

            child: const Text(
              'Luxury products for every moment ✨',

              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GRID
  // ─────────────────────────────────────────────

  Widget _buildGrid() {
    final width = MediaQuery.sizeOf(
      context,
    ).width;

    final crossAxisCount =
        (width /
                220)
            .floor()
            .clamp(
              2,
              4,
            );

    const spacing = 16.0;
    const horizontalPadding = 32.0; // if your page has 16 left + 16 right padding

    final itemWidth =
        (width -
            horizontalPadding -
            ((crossAxisCount -
                    1) *
                spacing)) /
        crossAxisCount;

    // Dynamic height logic
    final itemHeight =
        itemWidth *
        1.75; // tweak multiplier for desired card height

    final aspectRatio =
        itemWidth /
        itemHeight;

    AppLogger.d(
      '[HomePage] Grid Build → Count: ${filtered.length}, Width: $itemWidth, AR: $aspectRatio',
    );

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (
          context,
          i,
        ) {
          final product = filtered[i];

          return RepaintBoundary(
            child: ProductGridCard(
              product: product,
            ),
          );
        },
        childCount: filtered.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LIST
  // ─────────────────────────────────────────────

  Widget _buildList() {
    AppLogger.d(
      '[HomePage] List Build → Count: ${filtered.length}',
    );

    return SliverList.separated(
      itemCount: filtered.length,

      itemBuilder:
          (
            _,
            i,
          ) {
            return RepaintBoundary(
              child: ProductListCard(
                product: filtered[i],
              ),
            );
          },

      separatorBuilder:
          (
            _,
            _,
          ) => const SizedBox(
            height: 14,
          ),
    );
  }

  // ─────────────────────────────────────────────
  // EMPTY
  // ─────────────────────────────────────────────

  Widget _buildEmptyState() {
    AppLogger.w(
      '[HomePage] Empty State',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              padding: const EdgeInsets.all(
                24,
              ),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),

              child: const Icon(
                Icons.inventory_2_outlined,

                size: 80,

                color: Colors.white70,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            Text(
              'Nothing found here.',

              textAlign: TextAlign.center,

              style:
                  Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FLOATING BUTTON
  // ─────────────────────────────────────────────

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      elevation: 0,

      backgroundColor: Colors.white,

      foregroundColor: Colors.black,

      onPressed: () {
        AppLogger.i(
          '[HomePage] Layout Toggle',
        );

        setState(
          () {
            useGrid = !useGrid;
          },
        );
      },

      child: Icon(
        useGrid
            ? Icons.view_list_rounded
            : Icons.grid_view_rounded,
      ),
    );
  }
}
// ─────────────────────────────────────────────
// UPDATE LOGS POPUP
// ─────────────────────────────────────────────

void
showUpdateLogsPopup(
  BuildContext context,
  String logs,
) {
  AppLogger.i(
    '[Popup] Opening Update Logs',
  );

  showDialog(
    context: context,

    builder:
        (
          _,
        ) {
          return Dialog(
            backgroundColor: const Color(
              0xFF171B22,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                30,
              ),
            ),

            child: Padding(
              padding: const EdgeInsets.all(
                22,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  // HEADER
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Text(
                        'Update Logs',

                        style:
                            Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // CONTENT
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                    ),

                    padding: const EdgeInsets.all(
                      18,
                    ),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        22,
                      ),

                      color: Colors.white.withValues(
                        alpha: 0.05,
                      ),
                    ),

                    child: SingleChildScrollView(
                      child: SelectableText(
                        logs,

                        style: const TextStyle(
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // CLOSE
                  SizedBox(
                    width: double.infinity,

                    child: FilledButton(
                      onPressed: () {
                        AppLogger.i(
                          '[Popup] Closing Update Logs',
                        );

                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Text(
                        'Close',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
  );
}

// ─────────────────────────────────────────────
// ABOUT POPUP
// ─────────────────────────────────────────────

Future<
  void
>
showAboutPopup(
  BuildContext context,
) async {
  AppLogger.i(
    '[Popup] Opening About Popup',
  );

  final theme = Theme.of(
    context,
  );

  String devName = '-';

  String lastUpdated = '-';

  String instaLink = '-';

  try {
    AppLogger.d(
      '[Popup] Fetching About Metadata',
    );

    final results = await Future.wait(
      [
        fetchAppMetaName(),
        fetchAppMetaDate(),
        fetchAppMetaLink(),
      ],
    );

    devName = results[0].toString();

    lastUpdated = results[1].toString();

    instaLink = results[2].toString();

    AppLogger.s(
      '[Popup] Metadata Loaded',
    );
  } catch (
    e,
    stack
  ) {
    AppLogger.e(
      '[Popup] About Metadata Error',
      e,
      stack,
    );
  }

  if (!context.mounted) {
    AppLogger.w(
      '[Popup] Context Unmounted',
    );

    return;
  }

  showDialog(
    context: context,

    barrierDismissible: true,

    builder:
        (
          _,
        ) {
          return Dialog(
            backgroundColor: const Color(
              0xFF171B22,
            ),

            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                32,
              ),
            ),

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    // LOGO
                    Container(
                      width: 90,
                      height: 90,

                      padding: const EdgeInsets.all(
                        18,
                      ),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          begin: Alignment.topLeft,

                          end: Alignment.bottomRight,

                          colors: [
                            Colors.white.withValues(
                              alpha: 0.12,
                            ),

                            Colors.white.withValues(
                              alpha: 0.04,
                            ),
                          ],
                        ),
                      ),

                      child: Image.asset(
                        AppImages.logo,

                        filterQuality: FilterQuality.low,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // TITLE
                    Text(
                      'Nav Durga Collection',

                      textAlign: TextAlign.center,

                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,

                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // SUBTITLE
                    Text(
                      'Luxury fashion shopping experience.',

                      textAlign: TextAlign.center,

                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,

                        height: 1.5,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // DEV
                    _aboutInfoTile(
                      icon: Icons.person_outline,

                      title: 'Developer',

                      value: devName,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // UPDATED
                    _aboutInfoTile(
                      icon: Icons.update_rounded,

                      title: 'Last Updated',

                      value: lastUpdated,
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // INSTAGRAM
                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.camera_alt_rounded,

                          color: Colors.pink.shade300,
                        ),

                        label: const Text(
                          'Visit Instagram',
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,

                          foregroundColor: Colors.black,

                          elevation: 0,

                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),

                        onPressed: () async {
                          if (instaLink.isEmpty) {
                            AppLogger.w(
                              '[Popup] Empty Instagram Link',
                            );

                            return;
                          }

                          try {
                            AppLogger.i(
                              '[Popup] Launching Instagram',
                            );

                            await launchUrlString(
                              instaLink,

                              mode: LaunchMode.externalApplication,
                            );
                          } catch (
                            e,
                            stack
                          ) {
                            AppLogger.e(
                              '[Popup] Instagram Launch Error',
                              e,
                              stack,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // CLOSE
                    SizedBox(
                      width: double.infinity,

                      child: FilledButton.tonal(
                        onPressed: () {
                          AppLogger.i(
                            '[Popup] Closing About Popup',
                          );

                          Navigator.pop(
                            context,
                          );
                        },

                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),

                        child: const Text(
                          'Close',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Text(
                      'Made with ❤️ in India',

                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
  );
}

// ─────────────────────────────────────────────
// ABOUT INFO TILE
// ─────────────────────────────────────────────

Widget
_aboutInfoTile({
  required IconData icon,
  required String title,
  required String value,
}) {
  AppLogger.d(
    '[Widget] AboutInfoTile → $title',
  );

  return Builder(
    builder:
        (
          context,
        ) {
          return Container(
            width: double.infinity,

            padding: const EdgeInsets.all(
              18,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                24,
              ),

              color: Colors.white.withValues(
                alpha: 0.05,
              ),

              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.05,
                ),
              ),
            ),

            child: Row(
              children: [
                // ICON
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      16,
                    ),

                    color: Colors.white.withValues(
                      alpha: 0.06,
                    ),
                  ),

                  child: Icon(
                    icon,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,

                        style:
                            Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        value,

                        style:
                            Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
  );
}
// ─────────────────────────────────────────────
// QR POPUP
// ─────────────────────────────────────────────

Future<
  void
>
showQrCodePopup(
  BuildContext context,
) async {
  AppLogger.i(
    '[Popup] Opening QR Popup',
  );

  String qrImage = '';

  String upiId = '';

  bool loading = true;

  showDialog(
    context: context,

    barrierDismissible: true,

    builder:
        (
          _,
        ) {
          return StatefulBuilder(
            builder:
                (
                  context,
                  setState,
                ) {
                  // INITIAL FETCH
                  if (loading) {
                    loading = false;

                    Future.microtask(
                      () async {
                        try {
                          AppLogger.d(
                            '[Popup] Fetching QR Data',
                          );

                          final data = await fetchUpiData();

                          qrImage = data.qrImageUrl;

                          upiId = data.upiId;

                          AppLogger.s(
                            '[Popup] QR Data Loaded',
                          );

                          if (context.mounted) {
                            setState(
                              () {},
                            );
                          }
                        } catch (
                          e,
                          stack
                        ) {
                          AppLogger.e(
                            '[Popup] QR Fetch Error',
                            e,
                            stack,
                          );
                        }
                      },
                    );
                  }

                  return Dialog(
                    backgroundColor: const Color(
                      0xFF171B22,
                    ),

                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),

                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          22,
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            // HEADER
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),

                                    color: Colors.white.withValues(
                                      alpha: 0.06,
                                    ),
                                  ),

                                  child: const Icon(
                                    Icons.qr_code_rounded,
                                  ),
                                ),

                                const SizedBox(
                                  width: 14,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        'Pay via UPI',

                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      const Text(
                                        'Fast & secure payment',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // QR IMAGE
                            // QR IMAGE
                            if (qrImage.isNotEmpty)
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      10,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.white,

                                      borderRadius: BorderRadius.circular(
                                        28,
                                      ),

                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 26,

                                          spreadRadius: 1,

                                          offset: const Offset(
                                            0,
                                            12,
                                          ),

                                          color: Colors.black.withValues(
                                            alpha: 0.16,
                                          ),
                                        ),
                                      ],
                                    ),

                                    child: SizedBox(
                                      width: 210,
                                      height: 210,

                                      child: appImage(
                                        qrImage,

                                        fit: BoxFit.contain,

                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 14,
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ),

                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),

                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner_rounded,
                                          size: 18,
                                          color: Colors.white70,
                                        ),

                                        SizedBox(
                                          width: 8,
                                        ),

                                        Text(
                                          'Scan & Pay',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            // LOADING
                            else
                              Container(
                                width: 210,
                                height: 210,

                                alignment: Alignment.center,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    28,
                                  ),

                                  color: Colors.white.withValues(
                                    alpha: 0.04,
                                  ),
                                ),

                                child: const SizedBox(
                                  width: 28,
                                  height: 28,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                ),
                              ),

                            const SizedBox(
                              height: 26,
                            ),

                            // UPI ID
                            if (upiId.isNotEmpty)
                              Container(
                                width: double.infinity,

                                padding: const EdgeInsets.all(
                                  18,
                                ),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    22,
                                  ),

                                  color: Colors.white.withValues(
                                    alpha: 0.05,
                                  ),

                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.05,
                                    ),
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      'UPI ID',

                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Colors.white60,
                                          ),
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    SelectableText(
                                      upiId,

                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(
                              height: 18,
                            ),

                            // COPY BUTTON
                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.copy,
                                ),

                                label: const Text(
                                  'Copy UPI ID',
                                ),

                                style: ElevatedButton.styleFrom(
                                  elevation: 0,

                                  backgroundColor: Colors.white,

                                  foregroundColor: Colors.black,

                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      22,
                                    ),
                                  ),
                                ),

                                onPressed: upiId.isEmpty
                                    ? null
                                    : () async {
                                        try {
                                          AppLogger.i(
                                            '[Popup] Copying UPI ID',
                                          );

                                          await Clipboard.setData(
                                            ClipboardData(
                                              text: upiId,
                                            ),
                                          );

                                          if (!context.mounted) {
                                            return;
                                          }

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              behavior: SnackBarBehavior.floating,

                                              content: const Text(
                                                'UPI ID Copied',
                                              ),
                                            ),
                                          );

                                          AppLogger.s(
                                            '[Popup] UPI Copied',
                                          );
                                        } catch (
                                          e,
                                          stack
                                        ) {
                                          AppLogger.e(
                                            '[Popup] Copy Error',
                                            e,
                                            stack,
                                          );
                                        }
                                      },
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // CLOSE
                            SizedBox(
                              width: double.infinity,

                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      22,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  AppLogger.i(
                                    '[Popup] Closing QR Popup',
                                  );

                                  Navigator.pop(
                                    context,
                                  );
                                },

                                child: const Text(
                                  'Close',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
          );
        },
  );
}
