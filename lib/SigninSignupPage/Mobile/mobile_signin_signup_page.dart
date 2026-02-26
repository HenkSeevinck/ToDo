import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';
import 'package:todo_list/SigninSignupPage/General/resetpassword.dart';
import 'package:todo_list/SigninSignupPage/General/usersignin_page.dart';
import 'package:todo_list/SigninSignupPage/General/usersignup_page.dart';

class MobileSigninSignupPage extends StatefulWidget {
  const MobileSigninSignupPage({super.key});

  @override
  State<MobileSigninSignupPage> createState() => _MobileSigninSignupPageState();
}

class _MobileSigninSignupPageState extends State<MobileSigninSignupPage> {
  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final signInsignUpStatus = internalStatusProvider.signInsignUpStatus;

    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          top: true,
          child: Center(
            child: Image.asset(
              'images/agendaflowlogo.png', 
              height: 70, 
              width: 70, 
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(),
              child: Center(
                child: SizedBox(
                  child: signInsignUpStatus == 'SignIn' 
                  ? UserSignIn(width: 0.8, height: 0.4) 
                  : signInsignUpStatus == 'SignUp' 
                  ? UserSignUp(width: 0.8, height: 0.8) 
                  : ResetPassword(width: 0.8, height: 0.27),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}