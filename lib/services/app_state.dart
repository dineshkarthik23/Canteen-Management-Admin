import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:clg_admin/models/category.dart';
import 'package:clg_admin/models/food_item.dart';

class AppState extends ChangeNotifier {
  final List<CategoryModel> _categories = <CategoryModel>[];
  final List<FoodItem> _items = <FoodItem>[];
  Future<void> Function(Map<String, dynamic>)? _persistStateCallback;

  int _nextCategoryId = 1;
  int _nextItemId = 1;

  AppState() {
    resetData(notify: false);
  }

  void setPersistStateCallback(
    Future<void> Function(Map<String, dynamic>) callback,
  ) {
    _persistStateCallback = callback;
  }

  Map<String, dynamic> toJsonMap() {
    return <String, dynamic>{
      'nextCategoryId': _nextCategoryId,
      'nextItemId': _nextItemId,
      'categories': _categories
          .map(
            (category) => <String, dynamic>{
              'id': category.id,
              'name': category.name,
              'createdAt': category.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'items': _items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'name': item.name,
              'categoryId': item.categoryId,
              'price': item.price,
              'description': item.description,
              'isAvailable': item.isAvailable,
              'imageUrl': item.imageUrl,
              'createdAt': item.createdAt.toIso8601String(),
              'updatedAt': item.updatedAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  bool hydrateFromJsonMap(Map<String, dynamic> json) {
    try {
      final rawCategories = json['categories'];
      final rawItems = json['items'];
      if (rawCategories is! List || rawItems is! List) {
        return false;
      }

      final parsedCategories = rawCategories
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .map(
            (entry) => CategoryModel(
              id: entry['id'] as int,
              name: entry['name'] as String,
              createdAt: DateTime.parse(entry['createdAt'] as String),
            ),
          )
          .toList();

      final parsedItems = rawItems
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .map(
            (entry) => FoodItem(
              id: entry['id'] as int,
              name: entry['name'] as String,
              categoryId: entry['categoryId'] as int,
              price: (entry['price'] as num).toDouble(),
              description: entry['description'] as String,
              isAvailable: entry['isAvailable'] as bool,
              imageUrl: entry['imageUrl'] as String?,
              createdAt: DateTime.parse(entry['createdAt'] as String),
              updatedAt: DateTime.parse(entry['updatedAt'] as String),
            ),
          )
          .toList();

      _categories
        ..clear()
        ..addAll(parsedCategories);
      _items
        ..clear()
        ..addAll(parsedItems);

      _nextCategoryId =
          json['nextCategoryId'] as int? ??
          (_categories.map((category) => category.id).fold<int>(0, _max) + 1);
      _nextItemId =
          json['nextItemId'] as int? ??
          (_items.map((item) => item.id).fold<int>(0, _max) + 1);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<CategoryModel> get categories {
    final sorted = List<CategoryModel>.from(_categories)
      ..sort((a, b) => a.name.compareTo(b.name));
    return UnmodifiableListView<CategoryModel>(sorted);
  }

  List<FoodItem> get items {
    final sorted = List<FoodItem>.from(_items)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return UnmodifiableListView<FoodItem>(sorted);
  }

  int get totalItems => _items.length;
  int get totalCategories => _categories.length;
  int get availableItemsCount =>
      _items.where((item) => item.isAvailable).length;
  int get outOfStockItemsCount =>
      _items.where((item) => !item.isAvailable).length;

  FoodItem? get mostExpensiveItem {
    if (_items.isEmpty) {
      return null;
    }
    FoodItem current = _items.first;
    for (final item in _items.skip(1)) {
      if (item.price > current.price) {
        current = item;
      }
    }
    return current;
  }

  FoodItem? get recentlyAddedItem {
    if (_items.isEmpty) {
      return null;
    }
    FoodItem current = _items.first;
    for (final item in _items.skip(1)) {
      if (item.createdAt.isAfter(current.createdAt)) {
        current = item;
      }
    }
    return current;
  }

  double get totalRevenueEstimate {
    return _items.fold<double>(
      0,
      (sum, item) => sum + item.price * (item.isAvailable ? 40 : 8),
    );
  }

  Map<int, int> get itemCountsByCategory {
    final counts = <int, int>{
      for (final category in _categories) category.id: 0,
    };
    for (final item in _items) {
      counts[item.categoryId] = (counts[item.categoryId] ?? 0) + 1;
    }
    return counts;
  }

  CategoryModel? categoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  String categoryNameById(int id) {
    return categoryById(id)?.name ?? 'Unknown';
  }

  bool categoryNameExists(String name, {int? excludingId}) {
    final normalized = name.trim().toLowerCase();
    return _categories.any((category) {
      if (excludingId != null && category.id == excludingId) {
        return false;
      }
      return category.name.toLowerCase() == normalized;
    });
  }

  bool addCategory(String name) {
    final clean = name.trim();
    if (clean.isEmpty || categoryNameExists(clean)) {
      return false;
    }
    _categories.add(
      CategoryModel(
        id: _nextCategoryId++,
        name: clean,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    _persistState();
    return true;
  }

  bool updateCategory(int id, String name) {
    final clean = name.trim();
    if (clean.isEmpty || categoryNameExists(clean, excludingId: id)) {
      return false;
    }
    final index = _categories.indexWhere((category) => category.id == id);
    if (index == -1) {
      return false;
    }
    _categories[index] = _categories[index].copyWith(name: clean);
    notifyListeners();
    _persistState();
    return true;
  }

  void deleteCategory(int id) {
    if (_categories.every((category) => category.id != id)) {
      return;
    }

    final fallback = _ensureUncategorized(excludingId: id);
    _items.replaceRange(
      0,
      _items.length,
      _items.map((item) {
        if (item.categoryId == id) {
          return item.copyWith(
            categoryId: fallback.id,
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }),
    );
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
    _persistState();
  }

  List<FoodItem> itemsForCategory(int? categoryId) {
    if (categoryId == null) {
      return items;
    }
    return items.where((item) => item.categoryId == categoryId).toList();
  }

  void addItem({
    required String name,
    required int categoryId,
    required double price,
    required String description,
    required bool isAvailable,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    _items.add(
      FoodItem(
        id: _nextItemId++,
        name: name.trim(),
        categoryId: categoryId,
        price: price,
        description: description.trim(),
        isAvailable: isAvailable,
        imageUrl: imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
    notifyListeners();
    _persistState();
  }

  void updateItem(FoodItem item) {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return;
    }
    _items[index] = item.copyWith(updatedAt: DateTime.now());
    notifyListeners();
    _persistState();
  }

  void deleteItem(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    _persistState();
  }

  void resetData({bool notify = true}) {
    _categories
      ..clear()
      ..addAll(_defaultCategories());

    _items
      ..clear()
      ..addAll(_defaultItems(_categories));

    _nextCategoryId =
        (_categories.map((category) => category.id).fold<int>(0, _max)) + 1;
    _nextItemId = (_items.map((item) => item.id).fold<int>(0, _max)) + 1;

    if (notify) {
      notifyListeners();
    }
    _persistState();
  }

  CategoryModel _ensureUncategorized({int? excludingId}) {
    for (final category in _categories) {
      if (excludingId != null && category.id == excludingId) {
        continue;
      }
      if (category.name.toLowerCase() == 'uncategorized') {
        return category;
      }
    }
    final uncategorized = CategoryModel(
      id: _nextCategoryId++,
      name: 'Uncategorized',
      createdAt: DateTime.now(),
    );
    _categories.add(uncategorized);
    return uncategorized;
  }

  static int _max(int a, int b) => a > b ? a : b;

  void _persistState() {
    final callback = _persistStateCallback;
    if (callback == null) {
      return;
    }
    unawaited(callback(toJsonMap()));
  }

  List<CategoryModel> _defaultCategories() {
    final now = DateTime.now();
    return <CategoryModel>[
      CategoryModel(id: 1, name: 'Breads', createdAt: now),
      CategoryModel(id: 2, name: 'Curries', createdAt: now),
      CategoryModel(id: 3, name: 'Beverages', createdAt: now),
      CategoryModel(id: 4, name: 'Snacks', createdAt: now),
      CategoryModel(id: 5, name: 'Desserts', createdAt: now),
    ];
  }

  List<FoodItem> _defaultItems(List<CategoryModel> categories) {
    final now = DateTime.now();
    int categoryId(String name) {
      return categories
          .firstWhere(
            (category) => category.name.toLowerCase() == name.toLowerCase(),
          )
          .id;
    }

    return <FoodItem>[
      FoodItem(
        id: 1,
        name: 'Paneer Butter Masala',
        categoryId: categoryId('Curries'),
        price: 130.0,
        description: 'Rich tomato gravy with paneer cubes.',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      FoodItem(
        id: 2,
        name: 'Masala Dosa',
        categoryId: categoryId('Breads'),
        price: 55.0,
        description: 'Crispy dosa served with chutney and sambar.',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      FoodItem(
        id: 3,
        name: 'Cold Coffee',
        categoryId: categoryId('Beverages'),
        price: 60.0,
        description: 'Freshly blended chilled coffee.',
        isAvailable: false,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      FoodItem(
        id: 4,
        name: 'Veg Sandwich',
        categoryId: categoryId('Snacks'),
        price: 50.0,
        description: 'Toasted bread with mixed vegetable filling.',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      FoodItem(
        id: 5,
        name: 'Gulab Jamun',
        categoryId: categoryId('Desserts'),
        price: 35.0,
        description: 'Warm syrup-soaked dumplings.',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(hours: 9)),
      ),
    ];
  }
}
