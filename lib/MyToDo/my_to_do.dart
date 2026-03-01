import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/MyToDo/Mobile/my_to_do_home.dart';

import '../General/Providers/appuser_provider.dart';
import '../General/Providers/internal_app_providers.dart';
import '../General/Providers/todoitems_provider.dart';
import '../General/Variables/globalvariables.dart';
import '../General/Widgets/widgets.dart';

class MyToDo extends StatefulWidget {
  const MyToDo({super.key});

  @override
  State<MyToDo> createState() => _MyToDoState();
}

class _MyToDoState extends State<MyToDo> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final appUserProvider = Provider.of<AppuserProvider>(context, listen: false);
    final todoItemsProvider = Provider.of<TodoItemsProvider>(context, listen: false);
    _fetchDataFuture = _fetchData(appUserProvider, todoItemsProvider);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(AppuserProvider appUserProvider, TodoItemsProvider todoItemsProvider) async {
    final userID = appUserProvider.appUser['id'];
    await todoItemsProvider.getToDoItemsForCurrentUser(userID);
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopHomePage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackHomePage() {
    return Scaffold(body: const Center(child: Text('Landing Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        final localAppTheme = ResponsiveTheme(context).theme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error fetching data: ${snapshot.error}');
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final platform = internalStatusProvider.platform;

          if (platform == 'MobileWeb' || platform == 'Mobile') {
            return TodoHome();
          } else if (platform == 'ComputerWeb' || platform == 'Computer') {
            return _buildDesktopHomePage();
          } else {
            return _buildFallbackHomePage();
          }
        }
      },
    );
  }
}
