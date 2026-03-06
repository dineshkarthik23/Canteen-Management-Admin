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
        actionLabel: isEdit ? 'Save Changes' : 'Add Category',
        initialName: category?.name ?? '',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Category name is required';
          }
          if (widget.appState.categoryNameExists(value, excludingId: category?.id)) {
            return 'Category already exists';
          }
          return null;
        },
      ),
    );

    if (categoryName == null || !mounted) return;
    await Future<void>.delayed(kThemeAnimationDuration);
    if (!mounted) return;

    final success = isEdit
        ? widget.appState.updateCategory(category.id, categoryName)
        : widget.appState.addCategory(categoryName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (isEdit ? 'Category updated.' : 'Category added.')
            : 'Unable to save. Please check input.'),
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Delete "${category.name}"?\n\nItems under this category will move to "Uncategorized".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    await Future<void>.delayed(kThemeAnimationDuration);
    if (!mounted) return;

    widget.appState.deleteCategory(category.id);
    if (_filteredCategoryId == category.id) {
      setState(() => _filteredCategoryId = null);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${category.name}" deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final categories = widget.appState.categories;
        final items = widget.appState.itemsForCategory(_filteredCategoryId);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text('Categories'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Manage Categories',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${categories.length} categor${categories.length == 1 ? 'y' : 'ies'} · ${widget.appState.totalItems} total items',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category list
                    if (categories.isEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1830) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.08), width: 1.5),
                        ),
                        child: const EmptyState(
                          title: 'No Categories',
                          message: 'Add categories to organize your menu items.',
                          icon: Icons.category_outlined,
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1830) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.08), width: 1.5),
                        ),
                        child: Column(
                          children: categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            final count = widget.appState.itemCountsByCategory[category.id] ?? 0;
                            final isLast = index == categories.length - 1;

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              cs.primary.withValues(alpha: 0.15),
                                              cs.primary.withValues(alpha: 0.06),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          category.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$count item${count == 1 ? '' : 's'}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: cs.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _ActionBtn(
                                        icon: Icons.edit_rounded,
                                        color: cs.primary,
                                        tooltip: 'Edit',
                                        onTap: () => _openCategoryDialog(category: category),
                                      ),
                                      const SizedBox(width: 6),
                                      _ActionBtn(
                                        icon: Icons.delete_rounded,
                                        color: const Color(0xFFEF4444),
                                        tooltip: 'Delete',
                                        onTap: () => _deleteCategory(category),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    indent: 14,
                                    endIndent: 14,
                                    color: cs.primary.withValues(alpha: 0.06),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Filter section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.filter_list_rounded, size: 16, color: cs.primary),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Filter Items by Category',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1830) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.08), width: 1.5),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          DropdownButtonFormField<int?>(
                            key: ValueKey<int?>(_filteredCategoryId),
                            initialValue: _filteredCategoryId,
                            decoration: InputDecoration(
                              labelText: 'Select Category',
                              prefixIcon: Icon(Icons.filter_list_rounded, color: cs.primary),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.map(
                                (c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _filteredCategoryId = v),
                          ),
                          const SizedBox(height: 14),
                          if (items.isEmpty)
                            const EmptyState(
                              title: 'No Items Found',
                              message: 'No items are available for the selected category.',
                              icon: Icons.fastfood_outlined,
                            )
                          else
                            ...items.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : cs.primary.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  leading: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.fastfood_rounded,
                                      size: 18,
                                      color: cs.primary,
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    widget.appState.categoryNameById(item.categoryId),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rs. ${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: cs.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.isAvailable
                                              ? const Color(0xFFD1FAE5)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          item.isAvailable ? 'Available' : 'Out of Stock',
                                          style: TextStyle(
                                            color: item.isAvailable
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openCategoryDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
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
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Breakfast Combos',
            prefixIcon: Icon(Icons.category_rounded),
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