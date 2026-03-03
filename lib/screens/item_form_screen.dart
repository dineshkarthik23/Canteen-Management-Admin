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
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
      final item = widget.item!;
      widget.appState.updateItem(
        item.copyWith(
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
    final categories = widget.appState.categories;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Item' : 'Add Item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
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
                  child: Text(
                    _isEditMode
                        ? 'Update item details'
                        : 'Create a new canteen item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            prefixIcon: Icon(Icons.fastfood_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Item name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Item name should be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          key: ValueKey<int?>(_categoryId),
                          initialValue: _categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _categoryId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a category' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceController,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Price (Rs.)',
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Price is required';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid price above 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _imageController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Image URL (optional)',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_imageController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageController.text.trim(),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Image preview unavailable'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                    title: const Text('Availability Status'),
                    subtitle: Text(_isAvailable ? 'Available' : 'Out of Stock'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(_isEditMode ? Icons.save : Icons.add_circle),
                    label: Text(_isEditMode ? 'Save Changes' : 'Add Item'),
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
