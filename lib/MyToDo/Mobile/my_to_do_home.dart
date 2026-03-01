import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../General/Providers/internal_app_providers.dart';
import '../../General/Providers/todo_list_provider.dart';
import '../../General/Providers/todoitems_provider.dart';
import '../../General/Variables/globalvariables.dart';
import '../../General/Widgets/widgets.dart';
import '../../HomePage/home_page.dart';

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {

  // --------------------------------------------------------------
  // Reset and Navigate back
  Future<void> _resetAndNavigateBack() async {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    internalStatusProvider.setRecordingSessionUID(null);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // --------------------------------------------------------------
  // To-Do Item Card
  Widget todoItemCard({
    required BuildContext context,
    required Map<String, dynamic> todoItem,
  }) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final todoListProvider = Provider.of<TodoListProvider>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            header3(
                header: todoItem['task'],
                context: context,
                color: localAppTheme['anchorColors']['primaryColor']
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final todoItemsProvider = Provider.of<TodoItemsProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context,
          automaticallyImplyLeading: true,
          onPressed: () {
            _resetAndNavigateBack();
          },
          isAdmin: false,
          isModerator: false,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              body(
                header: '© ${DateTime.now().year} seevinckserver.com',
                color: localAppTheme['anchorColors']['primaryColor'],
                context: context,
              ),
              body(
                header: appInfo['version'] != null
                    ? 'v${appInfo['version']}'
                    : '',
                color: localAppTheme['anchorColors']['primaryColor'],
                context: context,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            pageHeaderImage(
                imagePath: 'images/todo.png',
                context: context,
                toolTip: '',
                userProfileToShow: {},
                pageTitle: 'MY TO-DO LIST'
            ),
            Container(
              width: double.infinity,
              //height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todoItemsProvider.processedToDoList.length,
                    itemBuilder: (context, index) {
                      final todoItem = todoItemsProvider.processedToDoList[index];
                      return todoItemCard(
                        context: context,
                        todoItem: todoItem,
                      );
                    }
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
