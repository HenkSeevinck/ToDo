import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/AudioRecording/audio_recording.dart';
import 'package:todo_list/General/Providers/todo_list_provider.dart';
import 'package:todo_list/General/Widgets/widgets.dart';
import 'package:todo_list/HomePage/home_page.dart';
import 'package:uuid/uuid.dart';

import '../../General/Providers/internal_app_providers.dart';
import '../../General/Variables/globalvariables';

class NewSessionHome extends StatefulWidget {
  const NewSessionHome({super.key});

  @override
  State<NewSessionHome> createState() => _NewSessionHomeState();
}

class _NewSessionHomeState extends State<NewSessionHome> {
  final AudioRecorderService _audioRecorderService = AudioRecorderService();
  bool _isRecording = false;
  bool _isProcessing = false;

  // --------------------------------------------------------------
  // Function to handle audio blocks
  Future<void> _handleAudioBlock(Uint8List audioBlock) async {
    final todoListProvider = Provider.of<TodoListProvider>(context, listen: false);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: false);
    if (audioBlock.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await todoListProvider.processAudio(audioBlock, internalStatusProvider);
      debugPrint('Audio block processed successfully.');
    } catch (e) {
      debugPrint('Error processing audio block: $e');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing audio: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
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
    final todoListProvider = Provider.of<TodoListProvider>(
      context,
      listen: true,
    );
    final audioScript = todoListProvider.audioScript;
    final todoList = todoListProvider.todoList;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appheader(
          context: context,
          automaticallyImplyLeading: true,
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
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
                  child: _isProcessing
                      ? Center(
                          child: CircularProgressIndicator(
                            color:
                                localAppTheme['anchorColors']['primaryColor'],
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: _isRecording
                                ? Colors.red
                                : localAppTheme['anchorColors']['primaryColor'],
                            size: 150,
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
                      header: 'ACTIONS FROM THE SESSION:',
                      context: context,
                      color: localAppTheme['anchorColors']['primaryColor'],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
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
                                  header: item['deadline'] ?? 'None',
                                  color:
                                      localAppTheme['anchorColors']['primaryColor'],
                                  context: context,
                                ),
                              ],
                            ),
                            trailing:SizedBox(
                              width: 92,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        //Edit task
                                      },
                                      icon: Icon(
                                          Icons.edit_document,
                                          color: localAppTheme['anchorColors']['primaryColor'],
                                          size:30,
                                      ),
                                  ),
                                  IconButton(
                                    onPressed: (){
                                      //Edit task
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
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
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: body(
                            header: audioScript['audioTranscript'] ?? '',
                            color:
                                localAppTheme['anchorColors']['primaryColor'],
                            context: context,
                          ),
                        ),
                      ),
                    ),
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
