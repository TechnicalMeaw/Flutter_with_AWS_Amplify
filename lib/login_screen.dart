import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_test/ListAllView.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:amplify_test/signup_screen.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _amplifyConfigured = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    _configureAmplify();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Padding(padding: const EdgeInsets.all(10),
                    child: isLoading
                        ? const Center(
                          child: CircularProgressIndicator(),)
                        : Column(
                        children: [
                          const Text("Sign In", textScaleFactor: 2,),
                          const SizedBox(height: 50,),
                          TextFormField(controller: emailController, decoration: const InputDecoration(hintText: "email"),),
                          TextFormField(controller: passwordController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(hintText: "password", ),),
                          const SizedBox(height: 20,),
                          ElevatedButton(onPressed: (){
                            signIn(emailController.text.trim(), passwordController.text);
                          }, child: const Text("Sign In")),
                          const SizedBox(height: 20,),
                          TextButton(onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
                          }, child: const Text("New user? Sign up")),

                          TextButton(onPressed: (){
                            Navigator.pushReplacementNamed(context, RouteConstants.viewAllList);
                          }, child: const Text("Skip login >>")),
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


  Future<void> signIn(username, password) async{
    setState(() {
      isLoading = true;
    });
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      setState(() {
        if (res.isSignedIn){
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ListAllView()));
          isLoading = false;
          Navigator.pushReplacementNamed(context, RouteConstants.viewAllList);
        }
      });
    } catch (e) {

      _showToast(context, e.toString());
      setState(() {
        isLoading = false;
      });
      print("Error on signin: $e");
    }
  }


  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
