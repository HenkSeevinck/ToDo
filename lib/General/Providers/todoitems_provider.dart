import 'package:flutter/cupertino.dart';
import 'package:pocketbase/pocketbase.dart';

class TodoItemsProvider with ChangeNotifier {
  final pb = PocketBase('https://pocketbase.seevinckserver.com');

  List<Map<String, dynamic>> _processedToDoList = [];
  List<Map<String, dynamic>> get processedToDoList => _processedToDoList;

  // -----------------------------------------------------
  // Fetch To Do Items for Current User
  Future<void> getToDoItemsForCurrentUser(String userID) async {

    // you can also fetch all records at once via getFullList
    final records = await pb.collection('ToDoItems').getFullList(
      filter: 'userID = "$userID"',
      sort: 'created'
    );

    _processedToDoList = records.map((record) => record.data).toList();
    notifyListeners();
  }

  // -----------------------------------------------------
  // Delete To Do Item
  Future<void> deleteToDoItem (String id) async {
    await pb.collection('ToDoItems').delete(id);
    _processedToDoList.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  // ----------------------------------------------------
  // Update To Do Items
  Future<void> updateToDoItem (String id, Map<String, dynamic> toDoItem) async {
    await pb.collection('ToDoItems').update(id, body: toDoItem);
    final index = _processedToDoList.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      _processedToDoList[index] = toDoItem;
      notifyListeners();
    }
  }
}
