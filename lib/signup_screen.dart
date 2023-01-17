import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_test/ListAllView.dart';
import 'package:amplify_test/login_screen.dart';
import 'package:amplify_test/verify_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  @override
  void initState() {
    _configureAmplify();
    super.initState();
  }

  bool _amplifyConfigured = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isSignUpComplete = false;
  bool isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Padding(padding: const EdgeInsets.all(10),
                    child: Column(
                        children: [
                          const Text("Sign Up", textScaleFactor: 2,),
                          const SizedBox(height: 50,),
                          TextFormField(controller: nameController, decoration: const InputDecoration(hintText: "name"),),
                          TextFormField(controller: emailController, decoration: const InputDecoration(hintText: "email"),),
                          TextFormField(controller: phoneController, decoration: const InputDecoration(hintText: "phone"),),
                          TextFormField(controller: passwordController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(hintText: "password"),),
                          const SizedBox(height: 20,),
                          ElevatedButton(onPressed: (){
                            signUp();
                          }, child: const Text("Sign Up")),
                          const SizedBox(height: 20,),
                          TextButton(onPressed: (){
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              SystemNavigator.pop();
                            }
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));

                            Navigator.pushNamedAndRemoveUntil(context, "/login" ,
                                (route)=> false);
                          }, child: const Text("Already a user? Sign in"))
                        ]),

                  ),

                ]
            ),
          ),
        ),
      ),
    );
  }


  void _configureAmplify() async {
    final datastorePlugin = AmplifyDataStore(
      modelProvider: ModelProvider.instance,
    );
    // Add the following line and update your function call with `addPlugins`
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    final auth = AmplifyAuthCognito();

    await Amplify.addPlugins([datastorePlugin, api, auth]);
    try {
      await Amplify.configure(amplifyconfig);
      try{
        setState(() {
          _amplifyConfigured = true;
        });
      }catch(e){
        print(e);
      }
    } on AmplifyAlreadyConfiguredException {
      print('Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
    }
  }


  Future<void> signUp() async{
    try {
      Map<String, dynamic> userAttributes = {
        "email": emailController.text,
        "phone_number": "+91${phoneController.text}",
        // additional attributes as needed
      };

      SignUpResult res = await Amplify.Auth.signUp(
          username: emailController.text,
          password: passwordController.text,
          options: CognitoSignUpOptions(
              userAttributes: {CognitoUserAttributeKey.email : emailController.text,
              CognitoUserAttributeKey.phoneNumber : "+91${phoneController.text}",
              CognitoUserAttributeKey.name : nameController.text})
      );
      setState(() {
        isSignUpComplete = res.isSignUpComplete;
        if (res.isSignUpComplete){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => VerifyCodeScreen(username: emailController.text.toString(), password: passwordController.text.toString(),)));
        }
      });
    } catch (e) {
      print(e);
    }
  }


  Future<void> signIn(username, password) async{
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      setState(() {
        isSignedIn = res.isSignedIn;
        if (res.isSignedIn){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ListAllView()));
        }
      });
    } catch (e) {
      print(e);
    }
  }

}
