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

        return Scaffold(
          appBar: AppBar(title: const Text('Admin Dashboard')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 170,
                    child: SummaryCard(
                      title: 'Total Items',
                      value: '${appState.totalItems}',
                      icon: Icons.fastfood,
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: SummaryCard(
                      title: 'Categories',
                      value: '${appState.totalCategories}',
                      icon: Icons.category,
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: SummaryCard(
                      title: 'Available',
                      value: '${appState.availableItemsCount}',
                      icon: Icons.check_circle,
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: SummaryCard(
                      title: 'Out of Stock',
                      value: '${appState.outOfStockItemsCount}',
                      icon: Icons.error_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Insights',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _InsightRow(
                        label: 'Most Expensive',
                        value: expensiveItem == null
                            ? 'No items'
                            : '${expensiveItem.name} (₹${expensiveItem.price.toStringAsFixed(2)})',
                        icon: Icons.local_fire_department_outlined,
                      ),
                      const SizedBox(height: 8),
                      _InsightRow(
                        label: 'Recently Added',
                        value: recentItem == null
                            ? 'No items'
                            : recentItem.name,
                        icon: Icons.new_releases_outlined,
                      ),
                      const SizedBox(height: 8),
                      _InsightRow(
                        label: 'Revenue Estimate',
                        value:
                            '₹${appState.totalRevenueEstimate.toStringAsFixed(2)}',
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (appState.totalItems == 0)
                const Card(
                  child: EmptyState(
                    title: 'No Food Items Yet',
                    message:
                        'Add your first menu item from the Manage Items tab to see analytics.',
                    icon: Icons.fastfood_outlined,
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category Distribution',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        ...appState.categories.map((category) {
                          final count = categoryCounts[category.id] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(category.name)),
                                Text(
                                  '$count item${count == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
