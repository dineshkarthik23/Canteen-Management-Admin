import 'package:flutter/material.dart';

import 'package:clg_admin/models/food_item.dart';
import 'package:clg_admin/services/app_state.dart';

class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, required this.appState, this.item});

  final AppState appState;
  final FoodItem? item;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  int? _categoryId;
  bool _isAvailable = true;

  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.item;
    if (existing != null) {
      _nameController.text = existing.name;
      _priceController.text = existing.price.toStringAsFixed(2);
      _descriptionController.text = existing.description;
      _imageController.text = existing.imageUrl ?? '';
      _categoryId = existing.categoryId;
      _isAvailable = existing.isAvailable;
    } else if (widget.appState.categories.isNotEmpty) {
      _categoryId = widget.appState.categories.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be a valid number above 0.')),
      );
      return;
    }

    if (_isEditMode) {
      widget.appState.updateItem(
        widget.item!.copyWith(
          name: _nameController.text.trim(),
          categoryId: _categoryId,
          price: price,
          description: _descriptionController.text.trim(),
          isAvailable: _isAvailable,
          imageUrl: _imageController.text.trim().isEmpty
              ? null
              : _imageController.text.trim(),
        ),
      );
      Navigator.of(context).pop('Item updated successfully.');
      return;
    }

    widget.appState.addItem(
      name: _nameController.text.trim(),
      categoryId: _categoryId!,
      price: price,
      description: _descriptionController.text.trim(),
      isAvailable: _isAvailable,
      imageUrl: _imageController.text.trim().isEmpty
          ? null
          : _imageController.text,
    );
    Navigator.of(context).pop('Item added successfully.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = widget.appState.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Item' : 'Add New Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isEditMode
                          ? [const Color(0xFF0891B2), const Color(0xFF06B6D4)]
                          : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_isEditMode
                                ? const Color(0xFF06B6D4)
                                : const Color(0xFF7C3AED))
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isEditMode ? Icons.edit_rounded : Icons.add_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditMode ? 'Update Item Details' : 'Create New Item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _isEditMode
                                  ? 'Modify the existing menu item'
                                  : 'Fill in the details for a new menu item',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Main form card
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Basic Information', icon: Icons.info_outline_rounded),
                      const SizedBox(height: 14),
                      _FormField(
                        controller: _nameController,
                        label: 'Item Name',
                        hint: 'e.g. Paneer Butter Masala',
                        icon: Icons.fastfood_rounded,
                        action: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Item name is required';
                          if (v.trim().length < 2) return 'At least 2 characters required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        key: ValueKey<int?>(_categoryId),
                        initialValue: _categoryId,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_rounded, color: cs.primary),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _categoryId = v),
                        validator: (v) => v == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 14),
                      _FormField(
                        controller: _priceController,
                        label: 'Price (Rs.)',
                        hint: '0.00',
                        icon: Icons.currency_rupee_rounded,
                        action: TextInputAction.next,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Price is required';
                          final p = double.tryParse(v.trim());
                          if (p == null || p <= 0) return 'Enter a valid price above 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Description', icon: Icons.description_rounded),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Item Description',
                          alignLabelWithHint: true,
                          hintText: 'Describe the item...',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.notes_rounded, color: cs.primary),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Description is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Media', icon: Icons.image_rounded),
                      const SizedBox(height: 14),
                      _FormField(
                        controller: _imageController,
                        label: 'Image URL (optional)',
                        hint: 'https://example.com/image.jpg',
                        icon: Icons.link_rounded,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_imageController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _imageController.text.trim(),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_rounded, color: cs.onSurfaceVariant),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Image preview unavailable',
                                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Availability toggle
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1830) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (_isAvailable
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (_isAvailable
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444))
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isAvailable
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _isAvailable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Availability Status',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                _isAvailable ? 'This item is available' : 'Out of Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _isAvailable
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isAvailable,
                          onChanged: (v) => setState(() => _isAvailable = v),
                          activeColor: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Save button
                FilledButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditMode ? Icons.save_rounded : Icons.add_circle_rounded),
                  label: Text(_isEditMode ? 'Save Changes' : 'Add Item'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: cs.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: cs.primary.withValues(alpha: 0.12), thickness: 1),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.action = TextInputAction.next,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputAction action;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      textInputAction: action,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: cs.primary),
      ),
      validator: validator,
    );
  }
}