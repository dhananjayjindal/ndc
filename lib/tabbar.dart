import 'package:flutter/material.dart';

class HomeTabBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const HomeTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const List<TabData> tabs = [
    TabData(title: 'All', icon: Icons.grid_view_rounded),
    TabData(title: 'New', icon: Icons.auto_awesome_rounded),
    TabData(title: 'Trending', icon: Icons.local_fire_department_rounded),
    TabData(title: 'Sale', icon: Icons.sell_rounded),
  ];

  bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700;
  }

  @override
  Widget build(BuildContext context) {
    final web = isWeb(context);

    return SizedBox(
      height: web ? 74 : 52,

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),

        scrollDirection: Axis.horizontal,

        physics: const BouncingScrollPhysics(),

        itemCount: tabs.length,

        separatorBuilder: (_, _) => const SizedBox(width: 8),

        itemBuilder: (_, i) {
          final tab = tabs[i];

          final selected = selectedIndex == i;

          return _ModernTabItem(
            title: tab.title,
            icon: tab.icon,
            selected: selected,
            isWeb: web,
            onTap: () => onTap(i),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB DATA
// ─────────────────────────────────────────────

class TabData {
  final String title;
  final IconData icon;

  const TabData({required this.title, required this.icon});
}

// ─────────────────────────────────────────────
// MODERN TAB ITEM
// ─────────────────────────────────────────────

class _ModernTabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final bool isWeb;
  final VoidCallback onTap;

  const _ModernTabItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.isWeb,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),

      scale: selected ? 1 : 0.96,

      curve: Curves.easeOut,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(24),

          onTap: onTap,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),

            curve: Curves.easeOut,

            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 24 : 12,
              vertical: isWeb ? 16 : 12,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.92),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.07),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),

              border: Border.all(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.06),
              ),

              boxShadow: selected
                  ? [
                      BoxShadow(
                        blurRadius: 24,
                        spreadRadius: -8,
                        offset: const Offset(0, 10),
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ]
                  : [
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: -8,
                        offset: const Offset(0, 10),
                        color: Colors.black.withValues(alpha: 0.30),
                      ),
                    ],
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),

                  width: isWeb ? 38 : 34,
                  height: isWeb ? 38 : 34,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: selected
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.06),
                  ),

                  child: Icon(
                    icon,

                    size: isWeb ? 20 : 18,

                    color: selected ? Colors.black : Colors.white,
                  ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 220),

                  curve: Curves.easeOut,

                  child: Row(
                    children: [
                      const SizedBox(width: 4),

                      Text(
                        title,

                        style: TextStyle(
                          fontSize: isWeb ? 16 : 14,

                          fontWeight: FontWeight.w800,

                          letterSpacing: -0.2,

                          color: selected ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
