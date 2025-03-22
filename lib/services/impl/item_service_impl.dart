import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/services/item_service.dart';

class ItemServiceImpl implements ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'items';

  @override
  Future<List<Item>> getAllItems() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final item = Item.fromJson(doc.data());
        item.id = doc.id;
        return item;
      }).toList();
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  @override
  Future<void> addItem(Item item) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      int nextId = snapshot.docs.length + 1;
      String itemId = 'i$nextId';

      await _firestore.collection(_collection).doc(itemId).set(item.toJson());
      item.id = itemId;
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateItem(String itemId, Item item) async {
    try {
      await _firestore.collection(_collection).doc(itemId).update(item.toJson());
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection(_collection).doc(itemId).delete();
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }
}