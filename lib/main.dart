import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/General/Providers/appuser_provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';
import 'package:todo_list/General/Widgets/widgets.dart';
import 'package:todo_list/HomePage/home_page.dart';
import 'package:todo_list/SigninSignupPage/signin_signup.dart';
import 'General/DevicePermissions/devicepermissions.dart';
import 'General/Providers/todo_list_provider.dart';
import 'General/Variables/globalvariables';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // final todoListProvider = TodoListProvider();
  // await todoListProvider.loadFromStorage();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppInfo>(create: (_) => AppInfo(appInfo)),
        ChangeNotifierProvider(create: (_) => InternalStatusProvider()),
        ChangeNotifierProvider(create: (_) => AppuserProvider()),
        ChangeNotifierProvider(create: (_) =>  TodoListProvider()),
        //ChangeNotifierProvider.value(value: todoListProvider),
      ],
      child: const MyApp(),
    ),
  );
}

//-----------------------------------------------------------
// Main App
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkPermissionsOnStart();
    _detectAndSetPlatform(context);
  }

  //-----------------------------------------------------------
  // Checking if the app has Audio Recording Permissions
  Future<void> _checkPermissionsOnStart() {
    return DevicePermissions.requestAudioPermission();
  }

  //-----------------------------------------------------------
  // Keep your existing _detectAndSetPlatform logic...
  String _detectAndSetPlatform(BuildContext context) {
    final internalStatusProvider =
        Provider.of<InternalStatusProvider>(context, listen: false);
    String platform;
    if (kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        platform = 'MobileWeb';
      } else {
        platform = 'ComputerWeb';
      }
    } else {
      platform = 'Unknown';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.fuchsia:
          platform = 'Mobile';
          break;
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          platform = 'Computer';
          break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      internalStatusProvider.setPlatform(platform);
    });
    return platform;
  }

  //-----------------------------------------------------------
  // Logic to check if the session is still valid
  Future<bool> _isSessionValid() async {
    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final startTimeStr = prefs.getString('auth_session_start');

    if (startTimeStr == null) return false;

    //final startTime = DateTime.parse(startTimeStr);
    //final expiryTime = startTime.add(const Duration(days: 14));

    // if (DateTime.now().isAfter(expiryTime)) {
    //   await FirebaseAuth.instance.signOut();
    //   await prefs.remove('auth_session_start');
    //   return false;
    // }
    return true;
  }

  //-----------------------------------------------------------
  // Build Main App
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: Colors.white,
        ),
      ),
      navigatorKey: navigatorKey,
      title: 'TODO List',
      home: FutureBuilder<bool>(
        future: _isSessionValid(),
        builder: (context, snapshot) {
          // While checking storage, show a loader
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          // If session is valid, go Home. Otherwise, go to SigninSignup (Login)
          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const SigninSignup();
          }
        },
      ),
    );
  }
}
