import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:flutter/material.dart';

import 'models/LoginData.dart';

class VerifyCodeScreen extends StatefulWidget {
  // const VerifyCodeScreen({Key? key}) : super(key: key);
  String username;
  String password;

  VerifyCodeScreen({super.key, required this.username, required this.password});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {

  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(10),
              child: Column(
                  children: [
                    const Text("Verify Code", textScaleFactor: 2,),
                    const SizedBox(height: 50,),
                    TextFormField(controller: codeController, decoration: const InputDecoration(hintText: "Code"),),
                    const SizedBox(height: 20,),
                    ElevatedButton(onPressed: (){
                      // signIn(emailController.text, passwordController.text);
                      _verifyCode(context, widget.username, widget.password, codeController.text.trim());
                    }, child: const Text("Verify")),
                ]
            ),
          ),
      ),
    )));
  }

  Future<void> _verifyCode(BuildContext context, username, password, String code) async {
    try{
      final res = await Amplify.Auth.confirmSignUp(username: username, confirmationCode: code);

      if (res.isSignUpComplete){
        await Amplify.Auth.signIn(username: username, password: password);
        Navigator.pushReplacementNamed(context, RouteConstants.viewAllList);
      }

    }catch(e){
      print(e);
    }
  }
}