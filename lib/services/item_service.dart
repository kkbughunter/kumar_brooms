import 'package:kumar_brooms/model/item.dart';

abstract class ItemService {
  Future<List<Item>> getAllItems();
  Future<void> addItem(Item item);
  Future<void> updateItem(String itemId, Item item);
  Future<void> deleteItem(String itemId);
}