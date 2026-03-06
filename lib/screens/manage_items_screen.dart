import 'package:flutter/material.dart';

import 'package:clg_admin/models/food_item.dart';
import 'package:clg_admin/screens/item_form_screen.dart';
import 'package:clg_admin/services/app_state.dart';
import 'package:clg_admin/widgets/empty_state.dart';
import 'package:clg_admin/widgets/item_card.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  final _searchController = TextEditingController();
  int? _selectedCategoryId;
  bool? _availabilityFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openItemForm([FoodItem? item]) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(appState: widget.appState, item: item),
      ),
    );
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _confirmDelete(FoodItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        title: 'Delete Item',
        message: 'Are you sure you want to delete "${item.name}"?',
        confirmLabel: 'Delete',
        isDangerous: true,
      ),
    );
    if (shouldDelete == true) {
      widget.appState.deleteItem(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${item.name}" deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final categories = widget.appState.categories;
        final query = _searchController.text.trim().toLowerCase();
        final filteredItems = widget.appState.items.where((item) {
          final matchesQuery = query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);
          final matchesCategory =
              _selectedCategoryId == null || item.categoryId == _selectedCategoryId;
          final matchesAvailability =
              _availabilityFilter == null || item.isAvailable == _availabilityFilter;
          return matchesQuery && matchesCategory && matchesAvailability;
        }).toList();

        final hasFilters = query.isNotEmpty ||
            _selectedCategoryId != null ||
            _availabilityFilter != null;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text('Menu Items'),
                actions: [
                  if (hasFilters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _selectedCategoryId = null;
                          _availabilityFilter = null;
                        }),
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 16, color: Colors.white),
                        label: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      // Search & Filters Card
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1830) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Search bar
                            TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Search items...',
                                hintStyle: const TextStyle(fontWeight: FontWeight.w400),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: cs.primary,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () => setState(() => _searchController.clear()),
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Filter row
                            Row(
                              children: [
                                Expanded(
                                  child: _FilterDropdown<int?>(
                                    value: _selectedCategoryId,
                                    label: 'Category',
                                    icon: Icons.category_outlined,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('All'),
                                      ),
                                      ...categories.map(
                                        (c) => DropdownMenuItem<int?>(
                                          value: c.id,
                                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _FilterDropdown<bool?>(
                                    value: _availabilityFilter,
                                    label: 'Status',
                                    icon: Icons.inventory_2_outlined,
                                    items: const [
                                      DropdownMenuItem<bool?>(value: null, child: Text('All')),
                                      DropdownMenuItem<bool?>(value: true, child: Text('Available')),
                                      DropdownMenuItem<bool?>(value: false, child: Text('Out of Stock')),
                                    ],
                                    onChanged: (v) => setState(() => _availabilityFilter = v),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Result count bar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${filteredItems.length} result${filteredItems.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              // Items list
              filteredItems.isEmpty
                  ? SliverFillRemaining(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          title: 'No Items Found',
                          message: hasFilters
                              ? 'Try changing your search or filters.'
                              : 'Add your first menu item using the button below.',
                          icon: Icons.fastfood_outlined,
                          actionLabel: hasFilters ? null : 'Add Item',
                          onActionTap: hasFilters ? null : _openItemForm,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (_, index) {
                          final item = filteredItems[index];
                          return ItemCard(
                            item: item,
                            categoryName: widget.appState.categoryNameById(item.categoryId),
                            onEdit: () => _openItemForm(item),
                            onDelete: () => _confirmDelete(item),
                          );
                        },
                      ),
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openItemForm,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w700)),
            elevation: 6,
          ),
        );
      },
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String label;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDangerous = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isDangerous ? const Color(0xFFEF4444) : cs.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}