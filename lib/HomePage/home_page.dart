import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/General/Providers/appuser_provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';
import 'package:todo_list/General/Variables/globalvariables';
import 'package:todo_list/General/Widgets/widgets.dart';
import 'package:todo_list/HomePage/Mobile/mobile_home_page.dart';
import 'package:todo_list/SigninSignupPage/signin_signup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void>? _fetchDataFuture;

  //----------------------------------------------------
  // initState load data when form is built
  @override
void initState() {
  super.initState();
  final appUserProvider = Provider.of<AppuserProvider>(context, listen: false);
  final sharedPreferences = SharedPreferences.getInstance();
    
  _fetchDataFuture = _fetchData(appUserProvider, sharedPreferences);
}

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(
    AppuserProvider appUserProvider,
    Future<SharedPreferences> sharedPreferences,
    ) async {
    final appUser = appUserProvider.appUser;

    if (appUser.isEmpty) {
      final prefs = await sharedPreferences;
      final userId = prefs.getString('auth_user_id');
      if (userId != null) {
        // Try to restore auth token into PocketBase client first so the
        // subsequent getUserRecord call is authenticated and can access
        // protected user records.
        await appUserProvider.restoreSession();
        await appUserProvider.getUserRecord(context, userId);
      }
    }

    await _checkExpiryDateOfSession(sharedPreferences);
  }

  //----------------------------------------------------
  // 14-day session check and platform detection logic moved to MyApp for better app flow control
  Future<void> _checkExpiryDateOfSession(Future<SharedPreferences> sharedPreferences) async {
    final appUserProvider = Provider.of<AppuserProvider>(context, listen: false);
    final prefs = await sharedPreferences;
    final startTimeStr = prefs.getString('auth_session_start');
    final expiryDate = startTimeStr != null ? DateTime.parse(startTimeStr).add(const Duration(days: 3)) : null;
    
    if (startTimeStr != null && expiryDate != null) {
      if (DateTime.now().isAfter(expiryDate)) {
      
        // Sign out of PocketBase and clear local session data
        await appUserProvider.userSignout(context);
        
        // Navigate back to Landing/Login page
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SigninSignup()),
            (route) => false,
          );
        }
      }
    }
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
            return MobileHome();
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