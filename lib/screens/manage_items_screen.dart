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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDelete(FoodItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      widget.appState.deleteItem(item.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${item.name}" deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final categories = widget.appState.categories;
        final query = _searchController.text.trim().toLowerCase();
        final filteredItems = widget.appState.items.where((item) {
          final matchesQuery =
              query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);
          final matchesCategory =
              _selectedCategoryId == null ||
              item.categoryId == _selectedCategoryId;
          final matchesAvailability =
              _availabilityFilter == null ||
              item.isAvailable == _availabilityFilter;
          return matchesQuery && matchesCategory && matchesAvailability;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Items'),
            actions: [
              IconButton(
                tooltip: 'Clear filters',
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedCategoryId = null;
                    _availabilityFilter = null;
                  });
                },
                icon: const Icon(Icons.filter_alt_off_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openItemForm,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by item name or description',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        isExpanded: true,
                        key: ValueKey<int?>(_selectedCategoryId),
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.map(
                            (category) => DropdownMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        isExpanded: true,
                        key: ValueKey<bool?>(_availabilityFilter),
                        initialValue: _availabilityFilter,
                        decoration: const InputDecoration(
                          labelText: 'Availability',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Available'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Out of Stock'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _availabilityFilter = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredItems.isEmpty
                      ? EmptyState(
                          title: 'No Items Found',
                          message:
                              query.isNotEmpty ||
                                  _selectedCategoryId != null ||
                                  _availabilityFilter != null
                              ? 'Try changing search or filters.'
                              : 'Add your first item using the button below.',
                          icon: Icons.fastfood_outlined,
                          actionLabel: 'Add Item',
                          onActionTap: _openItemForm,
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return ItemCard(
                              item: item,
                              categoryName: widget.appState.categoryNameById(
                                item.categoryId,
                              ),
                              onEdit: () => _openItemForm(item),
                              onDelete: () => _confirmDelete(item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
