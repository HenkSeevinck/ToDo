import 'package:flutter/material.dart';
import 'package:todo_list/NewSession/Mobile/new_session_home.dart';

//Form Status Provider
class InternalStatusProvider with ChangeNotifier {
  String signInsignUpStatus = 'SignIn';
  String platform = '';
  String userUIDToShow = '';
  String? homePageSelectedOption;
  String? recordingSessionUID;

  List<Map<String, dynamic>> homePageOptions = [
    {'selection': 'todo', 'pageName': 'MY TO-DO', 'icon': Icons.today, 'navigateTo': SizedBox(), 'image': 'images/todo.png'},
    {'selection': 'search', 'pageName': 'SEARCH', 'icon': Icons.search, 'navigateTo': SizedBox(), 'image': 'images/search.png'},
    {'selection': 'newsession', 'pageName': 'NEW SESSION', 'icon': Icons.add, 'navigateTo': NewSessionHome(), 'image': 'images/newsession.png'},
    {'selection': 'pastsessions', 'pageName': 'PAST SESSIONS', 'icon': Icons.history, 'navigateTo': SizedBox(), 'image': 'images/pastsessions.png'}
  ];

  void setSignInSignUpStatus(String status) {
    signInsignUpStatus = status;
    notifyListeners();
  }

  Future<void> setPlatform(String value) async {
    platform = value;
    notifyListeners();
  }

  Future<void> setRecordingSessionUID(String? value) async {
    recordingSessionUID = value;
    notifyListeners();
  }

  Future<void> setHomePageSelectedOption(String? homePageSelection) async {
    homePageSelectedOption = homePageSelection;
    notifyListeners();
  }

  Future<void> setUserUIDToShow(String value) async {
    userUIDToShow = value;
    notifyListeners();
  }
}
