import 'package:flutter/material.dart';

import 'package:clg_admin/services/app_state.dart';
import 'package:clg_admin/widgets/empty_state.dart';
import 'package:clg_admin/widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final expensiveItem = appState.mostExpensiveItem;
        final recentItem = appState.recentlyAddedItem;
        final categoryCounts = appState.itemCountsByCategory;
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero App Bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E1B4B), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          right: -20,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: 20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'Canteen Overview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Track items, categories & analytics',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 430;
                        final w = isNarrow
                            ? (constraints.maxWidth - 12) / 2
                            : (constraints.maxWidth - 36) / 4;

                        final cards = [
                          SummaryCard(
                            title: 'Total Items',
                            value: '${appState.totalItems}',
                            icon: Icons.fastfood_rounded,
                            gradientColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                            accentColor: const Color(0xFF7C3AED),
                          ),
                          SummaryCard(
                            title: 'Categories',
                            value: '${appState.totalCategories}',
                            icon: Icons.category_rounded,
                            gradientColors: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
                            accentColor: const Color(0xFF06B6D4),
                          ),
                          SummaryCard(
                            title: 'Available',
                            value: '${appState.availableItemsCount}',
                            icon: Icons.check_circle_rounded,
                            gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
                            accentColor: const Color(0xFF10B981),
                          ),
                          SummaryCard(
                            title: 'Out of Stock',
                            value: '${appState.outOfStockItemsCount}',
                            icon: Icons.remove_shopping_cart_rounded,
                            gradientColors: const [Color(0xFFDC2626), Color(0xFFF87171)],
                            accentColor: const Color(0xFFF87171),
                          ),
                        ];

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: cards
                              .map((c) => SizedBox(width: w, child: c))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Quick Insights
                    _SectionHeader(title: 'Quick Insights', icon: Icons.insights_rounded),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1830) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _InsightTile(
                            label: 'Most Expensive',
                            value: expensiveItem == null
                                ? 'No items yet'
                                : '${expensiveItem.name}  •  Rs. ${expensiveItem.price.toStringAsFixed(2)}',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            iconBg: const Color(0xFFFEF3C7),
                          ),
                          _Divider(),
                          _InsightTile(
                            label: 'Recently Added',
                            value: recentItem?.name ?? 'No items yet',
                            icon: Icons.new_releases_rounded,
                            iconColor: const Color(0xFF4F46E5),
                            iconBg: const Color(0xFFEDE9FE),
                          ),
                          _Divider(),
                          _InsightTile(
                            label: 'Revenue Estimate',
                            value: 'Rs. ${appState.totalRevenueEstimate.toStringAsFixed(2)}',
                            icon: Icons.payments_rounded,
                            iconColor: const Color(0xFF10B981),
                            iconBg: const Color(0xFFD1FAE5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Category Distribution
                    _SectionHeader(
                      title: 'Category Distribution',
                      icon: Icons.pie_chart_rounded,
                    ),
                    const SizedBox(height: 12),
                    if (appState.totalItems == 0)
                      const EmptyState(
                        title: 'No Food Items Yet',
                        message: 'Add your first menu item from the Items tab to see analytics.',
                        icon: Icons.fastfood_outlined,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1830) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: appState.categories.map((category) {
                            final count = categoryCounts[category.id] ?? 0;
                            final total = appState.totalItems;
                            final percent = total == 0 ? 0.0 : count / total;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: cs.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '$count item${count == 1 ? '' : 's'}',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      minHeight: 6,
                                      backgroundColor: cs.primary.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
    );
  }
}
