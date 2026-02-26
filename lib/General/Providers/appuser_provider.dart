import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/General/Widgets/widgets.dart';
import 'package:todo_list/HomePage/home_page.dart';

class AppuserProvider with ChangeNotifier {
  final pb = PocketBase('https://pocketbase.seevinckserver.com');

  Map<String, dynamic> _appUser = {};
  Map<String, dynamic> get appUser => _appUser;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------
  // Pocketbase User Signup
  Future<void> userSignup(BuildContext context, Map<String, dynamic> userSignUpData) async {
    final body = <String, dynamic>{
      "email": userSignUpData['email'],
      "emailVisibility": true,
      "name": userSignUpData['name'],
      "password": userSignUpData['password'],
      "passwordConfirm": userSignUpData['passwordConfirm'],
    };

    _isLoading = true;
    notifyListeners();

    try {
      final record = await pb.collection('users').create(body: body);

      // request email verification (may throw)
      await pb.collection('users').requestVerification(userSignUpData['email']);

      _appUser = record.data;
      notifyListeners();

      // Automatically sign in after signup — await to ensure completion
      await userSignin(context, userSignUpData);
    } catch (e) {
      snackbar(context: context, header: 'Signup failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // Pocketbase User Signin
  Future<void> userSignin(BuildContext context, Map<String, dynamic> userSignInData) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoading = true;
    notifyListeners();

    try {
      final authData = await pb.collection('users').authWithPassword(userSignInData['email'], userSignInData['password']);

      // authData.record usually contains id and data
      _appUser = authData.record.data;

      // Persist some minimal session info locally
      await prefs.setString('auth_session_start', DateTime.now().toIso8601String());
      try {
        await prefs.setString('auth_token', authData.token);
        await prefs.setString('auth_user_id', authData.record.id);
      } catch (_) {}

      // Save into PocketBase authStore if available so pb client persists session
      try {
        pb.authStore.save(authData.token, authData.record);
      } catch (_) {}

      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } catch (e) {
      snackbar(context: context, header: 'Signin failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // Pocketnase Get User Record (for session persistence)
  Future<void> getUserRecord(BuildContext context, String userId) async {
    try {
      final record = await pb.collection('users').getOne(userId);
      _appUser = record.data;
      notifyListeners();
    } catch (e) {
      if (ScaffoldMessenger.maybeOf(context) != null) {
        snackbar(context: context, header: 'Failed to get user record: ${e.toString()}');
      }
    }
  }

  // ---------------------------------------------------------------------
  // Restore PocketBase authStore from SharedPreferences (if a token exists)
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('auth_user_id');
      if (token != null && token.isNotEmpty) {
        try {
          pb.authStore.save(token, null);
          debugPrint('AppuserProvider: restored auth token into pb.authStore for userId: $userId');
          return true;
        } catch (e) {
          debugPrint('AppuserProvider: failed to save token into pb.authStore: $e');
        }
      }
    } catch (e) {
      debugPrint('AppuserProvider: error reading SharedPreferences: $e');
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // Pocketbase Signout
  Future<void> userSignout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Clear PocketBase authStore if available
      try {
        pb.authStore.clear();
      } catch (_) {}

      // Clear local session info
      await prefs.clear();

      _appUser = {};
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } catch (e) {
      snackbar(context: context, header: 'Signout failed: ${e.toString()}');
    }
  }
}
