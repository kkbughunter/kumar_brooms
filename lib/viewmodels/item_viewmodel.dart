import 'package:flutter/material.dart';
import 'package:kumar_brooms/model/item.dart';
import 'package:kumar_brooms/repositorys/item_repo.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  ItemViewModel(this._itemRepository);

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _itemRepository.getAllItems();
      print('Fetched items: ${_items.length}'); // Debug log
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch items: $e';
      print('Fetch error: $e'); // Debug log
      notifyListeners();
    }
  }

  Future<void> addItem(Item item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemRepository.addItem(item);
      await fetchAllItems(); // Refresh after adding
      print('Item added, refreshed list: ${_items.length}'); // Debug log
    } catch (e) {
      _errorMessage = 'Failed to add item: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItem(String itemId, Item item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemRepository.updateItem(itemId, item);
      await fetchAllItems();
    } catch (e) {
      _errorMessage = 'Failed to update item: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemRepository.deleteItem(itemId);
      await fetchAllItems();
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
