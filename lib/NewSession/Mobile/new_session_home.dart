import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/AudioRecording/audio_recording.dart';
import 'package:todo_list/General/Providers/todo_list_provider.dart';
import 'package:todo_list/General/Widgets/widgets.dart';
import 'package:todo_list/HomePage/home_page.dart';
import 'package:uuid/uuid.dart';

import '../../General/Providers/appuser_provider.dart';
import '../../General/Providers/internal_app_providers.dart';
import '../../General/Variables/globalvariables.dart';
import 'edit_todo_popup.dart';

class NewSessionHome extends StatefulWidget {
  const NewSessionHome({super.key});

  @override
  State<NewSessionHome> createState() => _NewSessionHomeState();
}

class _NewSessionHomeState extends State<NewSessionHome> {
  final AudioRecorderService _audioRecorderService = AudioRecorderService();
  bool _isRecording = false;

  // --------------------------------------------------------------
  // Function to handle audio blocks
  Future<void> _handleAudioBlock(Uint8List audioBlock) async {
    final todoListProvider = Provider.of<TodoListProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppuserProvider>(context, listen: false);
    final userID = appUserProvider.appUser['id'];

    if (audioBlock.isEmpty) return;

    try {
      // No setState here. The provider will handle notifying the UI.
      await todoListProvider.processAudio(userID, audioBlock, internalStatusProvider);
      debugPrint('Audio block processed successfully.');
    } catch (e) {
      debugPrint('Error processing audio block: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error processing audio: $e')));
      }
    }
  }

  // --------------------------------------------------------------
  // Function to generate a new UID with uuid package
  Future<void> _generateUID() async {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    final uuid = Uuid();

    await internalStatusProvider.setRecordingSessionUID(uuid.v4());
  }

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
  // Dispose method to stop recording when the widget is disposed
  @override
  void dispose() {
    if (_isRecording) {
      _audioRecorderService.toggleRecording(
        onAudioBlockReady: _handleAudioBlock,
      );
    }
    super.dispose();
  }

  // --------------------------------------------------------------
  // Build Method
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final todoListProvider = Provider.of<TodoListProvider>(context, listen: true,);
    final isProcessing = todoListProvider.isProcessing;
    final recordingUID = internalStatusProvider.recordingSessionUID;
    final audioScript = todoListProvider.audioScripts.firstWhere(
          (script) => script['recordingUID'] == recordingUID,
          orElse: () => <String, dynamic>{},
    );

    //final audioScript = todoListProvider.audioScript;
    final todoListFull = todoListProvider.todoList;
    final todoList = todoListFull.where((todo) => todo['recordingUID'] == recordingUID).toList();

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
                imagePath: 'images/newsession.png',
                context: context,
                toolTip: '',
                userProfileToShow: {},
                pageTitle: 'NEW SESSION'
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
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
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                          children: [
                            Center(
                              child: IconButton(
                                  icon: imageDisplay(
                                      imagePath: _isRecording
                                      ? 'images/takingNotesActive.png'
                                      : 'images/takingNotesInactive.png',
                                      width: MediaQuery.of(context).size.height * 0.15,
                                      height: MediaQuery.of(context).size.height * 0.15,
                                      context: context
                                  ),
                                  onPressed: () async {
                                    //Generate UID at start of recording
                                    if(!_isRecording) {
                                      await _generateUID();
                                    }

                                    //Toggle recording
                                    _audioRecorderService.toggleRecording(
                                      onAudioBlockReady: _handleAudioBlock,
                                    );
                                    setState(() {
                                      _isRecording = !_isRecording;
                                    });
                                  },
                                ),
                            ),
                            Visibility(
                              visible: isProcessing,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.height * 0.15,
                                      height: MediaQuery.of(context).size.height * 0.15,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Center(
                                    child: CircularProgressIndicator(
                                      color:
                                      localAppTheme['anchorColors']['primaryColor'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: localAppTheme['anchorColors']['primaryColor'],
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(
                      header: 'NOTES FROM THE SESSION:',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: todoList.isNotEmpty
                      ? ListView.builder(
                        itemCount: todoList.length,
                        itemBuilder: (context, index) {
                          final item = todoList[index];
                          return ListTile(
                            //title: Text(item['task'] ?? 'No task'),
                            title: header3(
                              header: item['task'],
                              context: context,
                              color:
                                  localAppTheme['anchorColors']['primaryColor'],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                body(
                                  header: item['owner'] ?? 'Unassigned',
                                  color:
                                      localAppTheme['anchorColors']['primaryColor'],
                                  context: context,
                                ),
                                body(
                                  header: item['deadline'].toString() ?? 'None',
                                  color:
                                      localAppTheme['anchorColors']['primaryColor'],
                                  context: context,
                                ),
                              ],
                            ),
                            trailing:SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        internalStatusProvider.setSelectedToDo(item);
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false, // User must tap button to dismiss
                                          builder: (BuildContext context) {
                                            return EditTodoPopup();
                                          },
                                        );
                                      },
                                      icon: Icon(
                                          Icons.edit_document,
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          size:30,
                                      ),
                                  ),
                                  IconButton(
                                    onPressed: (){
                                      //Delete task
                                      todoListProvider.deleteTodoItem(item['todoUID']);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: localAppTheme['anchorColors']['primaryColor'],
                                      size:30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      : SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: localAppTheme['anchorColors']['primaryColor'],
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(
                      header: 'TRANSCRIPT:',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10,
                          ),
                          child: body(
                            header: audioScript['audioTranscript'] ?? '',
                            color:
                                localAppTheme['anchorColors']['primaryColor'],
                            context: context,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !_isRecording && todoList.isNotEmpty,
                      child: Container(
                        height: 70,
                        width: double.infinity,
                        margin: EdgeInsetsGeometry.directional(
                          top: 10,
                        ),
                        padding: EdgeInsetsGeometry.directional(
                          top: 8.00
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: localAppTheme['anchorColors']['primaryColor'],
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: elevatedButton(
                            label: 'SUBMIT FOR PROCESSING',
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final authToken = prefs.getString('auth_token') ?? '';
                              final transcript = audioScript['audioTranscript'] ?? '';
                              final todoItems = todoListFull.where((todo) => todo['recordingUID'] == recordingUID).toList();

                              await todoListProvider.processTodoItems(recordingUID ?? '', authToken, transcript, todoItems);

                              _resetAndNavigateBack();
                              },
                            backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                            labelColor: localAppTheme['anchorColors']['secondaryColor'],
                            leadingIcon: null,
                            trailingIcon: null,
                            context: context,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
