import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/repositorys/item_repo.dart';
import 'package:kumar_brooms/services/item_service.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemService _itemService;

  ItemRepositoryImpl(this._itemService);

  @override
  Future<List<Item>> getAllItems() async {
    return await _itemService.getAllItems();
  }

  @override
  Future<void> addItem(Item item) async {
    await _itemService.addItem(item);
  }

  @override
  Future<void> updateItem(String itemId, Item item) async {
    await _itemService.updateItem(itemId, item);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _itemService.deleteItem(itemId);
  }
}