import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool _amplifyConfigured = false;

  @override
  void initState() {
    _configureAmplify();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.yellow,
          child:FlutterLogo(size:MediaQuery.of(context).size.height)
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
        checkCurrentUser();
      }catch(e){
        print(e);
      }
    } on AmplifyAlreadyConfiguredException {
      print('Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
    }
  }

  void checkCurrentUser() async {
    try {
      final awsUser = await Amplify.Auth.getCurrentUser();
      //send user to dashboard
      Navigator.pushReplacementNamed(context, RouteConstants.viewAllList);
    } on AuthException catch (e) {
      //send user to login
      Navigator.pushReplacementNamed(context, RouteConstants.login);
      print(e);
    }
  }
}

