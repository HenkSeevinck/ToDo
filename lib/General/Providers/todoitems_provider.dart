import 'package:flutter/cupertino.dart';
import 'package:pocketbase/pocketbase.dart';

class TodoItemsProvider with ChangeNotifier {
  final pb = PocketBase('https://pocketbase.seevinckserver.com');

  List<Map<String, dynamic>> _processedToDoList = [];
  List<Map<String, dynamic>> get processedToDoList => _processedToDoList;

  Future<void> getToDoItemsForCurrentUser(String userID) async {

    // you can also fetch all records at once via getFullList
    final records = await pb.collection('ToDoItems').getFullList(
      filter: 'userID = "$userID"',
      sort: 'created'
    );

    _processedToDoList = records.map((record) => record.data).toList();
    notifyListeners();

  }
}
