import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';
import 'package:todo_list/SigninSignupPage/Mobile/mobile_signin_signup_page.dart';

class SigninSignup extends StatefulWidget {
  const SigninSignup({super.key});

  @override
  State<SigninSignup> createState() => _SigninSignupState();
}

class _SigninSignupState extends State<SigninSignup> {

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackLayout() {
    return Scaffold(body: const Center(child: Text('Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Desktop Layout
  Widget _desktopLayout() {
    return Scaffold(body: const Center(child: Text('Desktop Layout Coming Soon')));
  }

  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final platform = internalStatusProvider.platform;

    if (platform == 'MobileWeb' || platform == 'Mobile') {
      return MobileSigninSignupPage();
    } else if (platform == 'ComputerWeb' || platform == 'Computer') {
      return _desktopLayout();
    } else {
      return _buildFallbackLayout();
    }
  }
}