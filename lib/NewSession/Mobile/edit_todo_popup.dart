import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/General/Providers/todo_list_provider.dart';
import '../../General/Providers/internal_app_providers.dart';
import '../../General/Variables/globalvariables';
import '../../General/Widgets/widgets.dart';

class EditTodoPopup extends StatefulWidget {
  const EditTodoPopup({super.key});

  @override
  State<EditTodoPopup> createState() => _EditTodoPopupState();
}

class _EditTodoPopupState extends State<EditTodoPopup> {
  final TextEditingController todoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController responsiblePersonController = TextEditingController();
  late final GlobalKey<FormState> formKey;
  late final Map<String, dynamic> selectedToDo;

  //----------------------------------------------------
  // Initialize state
  @override
  void initState() {
    super.initState();
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    formKey = GlobalKey<FormState>();
    selectedToDo = {...internalStatusProvider.selectedToDo!};
    todoController.text = selectedToDo['task'].toString();
    responsiblePersonController.text = selectedToDo['owner'].toString();
  }

  //----------------------------------------------------
  // Submit Button


  //----------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final todoListProvider = Provider.of<TodoListProvider>(context, listen: true);

    return AlertDialog(
      backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
      title: header1(header: 'Edit Todo:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setStateDialog) {
              return Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.0),
                    FormInputField(
                      label: 'ToDo Item:',
                      errorMessage: 'Please enter a valid ToDo item.',
                      isMultiline: true,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid ToDo item.';
                        }
                        return null;
                      },
                      //initialValue: draftGoal['title'],
                      onChanged: (value) {
                        selectedToDo['task'] = value;
                      },
                      controller: todoController,
                    ),
                    SizedBox(height: 10.0),
                    DatePicker(
                      buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                      label: 'Date:',
                      buttonVisibility: true,
                      enabled: true,
                      initialDate: (() {
                        DateTime.now();
                      })(),
                      validator: (date) {
                        if (date == null) {
                          return 'Please select a valid date.';
                        }
                        return null;
                      },
                      controller: dateController,
                      onChanged: (value) {
                        selectedToDo['deadline'] = value;
                        dateController.text = DateFormat.yMd().format(value);
                      },
                    ),
                    SizedBox(height: 10.0),
                    FormInputField(
                      label: 'Responsible Person:',
                      errorMessage: 'Please enter a valid Responsible Person.',
                      isMultiline: false,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid Responsible Person.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        selectedToDo['owner'] = value;
                      },
                      controller: responsiblePersonController,
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        textButton(
                            label: "SUBMIT",
                            onPressed: () async {
                              if (selectedToDo['deadline'] is DateTime) {
                                selectedToDo['deadline'] = (selectedToDo['deadline'] as DateTime).toIso8601String();
                              }
                              await todoListProvider.replaceTodoItem(selectedToDo['todoUID'], selectedToDo);
                              Navigator.of(context).pop();
                            },
                            labelColor: localAppTheme['anchorColors']['primaryColor'],
                            leadingIcon: null,
                            trailingIcon: null,
                            context: context,
                        ),
                        textButton(
                          label: "CANCEL",
                          onPressed: (){Navigator.of(context).pop();},
                          labelColor: localAppTheme['anchorColors']['primaryColor'],
                          leadingIcon: null,
                          trailingIcon: null,
                          context: context,
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
