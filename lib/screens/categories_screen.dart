import 'package:flutter/material.dart';

import 'package:clg_admin/models/category.dart';
import 'package:clg_admin/services/app_state.dart';
import 'package:clg_admin/widgets/empty_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int? _filteredCategoryId;

  Future<void> _openCategoryDialog({CategoryModel? category}) async {
    final isEdit = category != null;
    final categoryName = await showDialog<String>(
      context: context,
      builder: (context) => _CategoryInputDialog(
        title: isEdit ? 'Edit Category' : 'Add Category',
        actionLabel: isEdit ? 'Save' : 'Add',
        initialName: category?.name ?? '',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Category name is required';
          }
          if (widget.appState.categoryNameExists(
            value,
            excludingId: category?.id,
          )) {
            return 'Category already exists';
          }
          return null;
        },
      ),
    );

    if (categoryName == null || !mounted) {
      return;
    }

    await Future<void>.delayed(kThemeAnimationDuration);
    if (!mounted) {
      return;
    }

    final success = isEdit
        ? widget.appState.updateCategory(category.id, categoryName)
        : widget.appState.addCategory(categoryName);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isEdit
                    ? 'Category updated successfully.'
                    : 'Category added successfully.')
              : 'Unable to save category. Please check input.',
        ),
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Delete "${category.name}"? Items under this category will move to "Uncategorized".',
        ),
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

    if (shouldDelete != true) {
      return;
    }
    await Future<void>.delayed(kThemeAnimationDuration);
    if (!mounted) {
      return;
    }

    widget.appState.deleteCategory(category.id);
    if (_filteredCategoryId == category.id) {
      setState(() {
        _filteredCategoryId = null;
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${category.name}" deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final categories = widget.appState.categories;
        final items = widget.appState.itemsForCategory(_filteredCategoryId);

        return Scaffold(
          appBar: AppBar(title: const Text('Categories')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.category,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Categories',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${categories.length} category${categories.length == 1 ? '' : 'ies'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (categories.isEmpty)
                const Card(
                  child: EmptyState(
                    title: 'No Categories',
                    message: 'Add categories to organize items.',
                    icon: Icons.category_outlined,
                  ),
                )
              else
                ...categories.map((category) {
                  final count =
                      widget.appState.itemCountsByCategory[category.id] ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        child: Text(
                          category.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(category.name),
                      subtitle: Text('$count item${count == 1 ? '' : 's'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit category',
                            onPressed: () =>
                                _openCategoryDialog(category: category),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete category',
                            onPressed: () => _deleteCategory(category),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Items by Category',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        key: ValueKey<int?>(_filteredCategoryId),
                        initialValue: _filteredCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                          prefixIcon: Icon(Icons.filter_list),
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
                            _filteredCategoryId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        const EmptyState(
                          title: 'No Items Found',
                          message:
                              'No items are available for the selected category.',
                          icon: Icons.fastfood_outlined,
                        )
                      else
                        ...items.map((item) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                widget.appState.categoryNameById(
                                  item.categoryId,
                                ),
                              ),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rs. ${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    item.isAvailable
                                        ? 'Available'
                                        : 'Out of Stock',
                                    style: TextStyle(
                                      color: item.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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

class _CategoryInputDialog extends StatefulWidget {
  const _CategoryInputDialog({
    required this.title,
    required this.actionLabel,
    required this.initialName,
    required this.validator,
  });

  final String title;
  final String actionLabel;
  final String initialName;
  final String? Function(String?) validator;

  @override
  State<_CategoryInputDialog> createState() => _CategoryInputDialogState();
}

class _CategoryInputDialogState extends State<_CategoryInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'Example: Breakfast Combos',
          ),
          validator: widget.validator,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
      ],
    );
  }
}
