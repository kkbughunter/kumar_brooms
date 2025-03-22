import 'package:kumar_brooms/models/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAllItems();
  Future<void> addItem(Item item);
  Future<void> updateItem(String itemId, Item item);
  Future<void> deleteItem(String itemId);
}