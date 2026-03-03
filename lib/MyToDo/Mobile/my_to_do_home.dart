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
    final internalStatusProvider = Provider.of<InternalStatusProvider>(
      context,
      listen: false,
    );
    internalStatusProvider.setRecordingSessionUID(null);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // --------------------------------------------------------------
  // To-Do Item Card
  Widget resolvedToDoItemCard({
    required BuildContext context,
    required Map<String, dynamic> todoItem,
  }) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final todoItemsProvider = Provider.of<TodoItemsProvider>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
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
                  header3(
                    header: 'RECORDING UID:',
                    color: localAppTheme['anchorColors']['primaryColor'],
                    context: context,
                  ),
                  body(
                    header: todoItem['recordingUID'],
                    context: context,
                    color: localAppTheme['anchorColors']['primaryColor'],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              child: header3(
                header: todoItem['task'],
                context: context,
                color: localAppTheme['anchorColors']['primaryColor'],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      header3(
                        header: 'OWNER:',
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                      body(
                        header: todoItem['owner'],
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      header3(
                        header: 'DEADLINE:',
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                      body(
                        header: todoItem['deadline'],
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // To-Do Item Card
  Widget todoItemCard({
    required BuildContext context,
    required Map<String, dynamic> todoItem,
  }) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final todoItemsProvider = Provider.of<TodoItemsProvider>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
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
                  header3(
                    header: 'RECORDING UID:',
                    color: localAppTheme['anchorColors']['primaryColor'],
                    context: context,
                  ),
                  body(
                    header: todoItem['recordingUID'],
                    context: context,
                    color: localAppTheme['anchorColors']['primaryColor'],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              child: header3(
                header: todoItem['task'],
                context: context,
                color: localAppTheme['anchorColors']['primaryColor'],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      header3(
                        header: 'OWNER:',
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                      body(
                        header: todoItem['owner'],
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      header3(
                        header: 'DEADLINE:',
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                      body(
                        header: todoItem['deadline'],
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header3(
                    header: 'PRIORITY:',
                    color: localAppTheme['anchorColors']['primaryColor'],
                    context: context,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 150,
                        child: elevatedButton(
                          label: 'HIGHER',
                          onPressed: () async {
                            try {
                              // Only perform the action if priority is greater than 0
                              if (todoItem['priority'] < 3) {
                                // Decrement the value directly.
                                todoItem['priority']++;

                                // Now update the item via the provider
                                await todoItemsProvider.updateToDoItem(todoItem['id'], todoItem);
                              }
                            } catch(e) {
                              snackbar(context: context, header: e.toString());
                            }
                          },
                          backgroundColor:
                          localAppTheme['utilityColorPair1']['color1'],
                          labelColor:
                          localAppTheme['anchorColors']['secondaryColor'],
                          leadingIcon: Icons.arrow_upward,
                          trailingIcon: null,
                          context: context,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: elevatedButton(
                          label: 'LOWER',
                          onPressed: () async {
                            try {
                              // Only perform the action if priority is greater than 0
                              if (todoItem['priority'] > 0) {
                                // Decrement the value directly.
                                todoItem['priority']--;

                                // Now update the item via the provider
                                await todoItemsProvider.updateToDoItem(todoItem['id'], todoItem);
                              }
                            } catch(e) {
                              snackbar(context: context, header: e.toString());
                            }
                          },
                          backgroundColor:
                          localAppTheme['utilityColorPair3']['color1'],
                          labelColor:
                          localAppTheme['anchorColors']['secondaryColor'],
                          leadingIcon: Icons.arrow_downward,
                          trailingIcon: null,
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                  bottom: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: elevatedButton(
                      label: 'COMPLETE',
                      onPressed: () async {
                        try{
                          todoItem['todoResolved'] = true;
                          await todoItemsProvider.updateToDoItem(todoItem['id'], todoItem);
                        } catch(e) {
                          snackbar(context: context, header: e.toString());
                        }
                      },
                      backgroundColor:
                      localAppTheme['anchorColors']['primaryColor'],
                      labelColor:
                      localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: Icons.done,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: elevatedButton(
                      label: null,
                      onPressed: () {},
                      backgroundColor:
                      localAppTheme['anchorColors']['primaryColor'],
                      labelColor:
                      localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: Icons.edit_document,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: elevatedButton(
                      label: null,
                      onPressed: () async {
                        try {
                          await todoItemsProvider.deleteToDoItem(todoItem['id']);
                        } catch(e) {
                          snackbar(context: context, header: e.toString());
                        }
                      },
                      backgroundColor:
                      localAppTheme['anchorColors']['primaryColor'],
                      labelColor:
                      localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: Icons.delete,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                ],
              ),
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
    final todoItemsProvider = Provider.of<TodoItemsProvider>(context, listen: true,);
    final noPriorityToDoItems = todoItemsProvider.processedToDoList.where((todo) => todo['todoResolved'] == false && todo['priority'] == 0).toList();
    final lowPriorityToDoItems = todoItemsProvider.processedToDoList.where((todo) => todo['todoResolved'] == false && todo['priority'] == 1).toList();
    final mediumPriorityToDoItems = todoItemsProvider.processedToDoList.where((todo) => todo['todoResolved'] == false && todo['priority'] == 2).toList();
    final highPriorityToDoItems = todoItemsProvider.processedToDoList.where((todo) => todo['todoResolved'] == false && todo['priority'] == 3).toList();
    final resolvedToDoItems = todoItemsProvider.processedToDoList.where((todo) => todo['todoResolved'] == true).toList();

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pageHeaderImage(
                imagePath: 'images/todo.png',
                context: context,
                toolTip: '',
                userProfileToShow: {},
                pageTitle: 'MY TO-DO LIST',
              ),
              SizedBox(height: 10),
              // High Priority To-Do Items
              Visibility(
                visible: highPriorityToDoItems.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(
                      header: 'HIGH PRIORITY',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: highPriorityToDoItems.length,
                      itemBuilder: (context, index) {
                        final todoItem = highPriorityToDoItems[index];
                        return todoItemCard(context: context, todoItem: todoItem);
                      },
                    ),
                  ],
                ),
              ),
              // Medium Priority To-Do Items
              Visibility(
                visible: mediumPriorityToDoItems.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(
                      header: 'MEDIUM PRIORITY',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mediumPriorityToDoItems.length,
                      itemBuilder: (context, index) {
                        final todoItem = mediumPriorityToDoItems[index];
                        return todoItemCard(context: context, todoItem: todoItem);
                      },
                    ),
                  ],
                ),
              ),
              // Low Priority To-Do Items
              Visibility(
                visible: lowPriorityToDoItems.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(
                      header: 'LOW PRIORITY',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lowPriorityToDoItems.length,
                      itemBuilder: (context, index) {
                        final todoItem = lowPriorityToDoItems[index];
                        return todoItemCard(context: context, todoItem: todoItem);
                      },
                    ),
                  ],
                ),
              ),
              // No Priority To-Do Items
              Visibility(
                visible: noPriorityToDoItems.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(
                      header: 'NO PRIORITY',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: noPriorityToDoItems.length,
                      itemBuilder: (context, index) {
                        final todoItem = noPriorityToDoItems[index];
                        return todoItemCard(context: context, todoItem: todoItem);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Resolved To Do Items
              ExpansionTile(
                collapsedShape: BorderDirectional(
                  top: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                  bottom: BorderSide(
                    color: localAppTheme['anchorColors']['primaryColor'],
                    width: 1.0,
                  ),
                ),
                  title: header2(
                      header: 'RESOLVED TO-DO ITEMS',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor']),
                  children:[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      //itemCount: todoItemsProvider.processedToDoList.length,
                      itemCount: resolvedToDoItems.length,
                      //itemCount: resolvedToDoItems.length,
                      itemBuilder: (context, index) {
                        final todoItem = resolvedToDoItems[index];
                        return resolvedToDoItemCard(context: context, todoItem: todoItem);
                      },
                    )
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
