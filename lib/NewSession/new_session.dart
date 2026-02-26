import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';
import 'package:todo_list/General/Variables/globalvariables';
import 'package:todo_list/General/Widgets/widgets.dart';
import 'package:todo_list/NewSession/Mobile/new_session_home.dart';

class NewSession extends StatefulWidget {
  const NewSession({super.key});
  
  @override
  State<NewSession> createState() => _NewSessionState();
}

class _NewSessionState extends State<NewSession> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
void initState() {
  super.initState();
  
  _fetchDataFuture = _fetchData();
}

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData() async {}

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
            return NewSessionHome();
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