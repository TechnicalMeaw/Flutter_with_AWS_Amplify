import 'package:amplify_test/ListAllView.dart';
import 'package:amplify_test/create_post_screen.dart';
import 'package:amplify_test/login_screen.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:amplify_test/splash_screen.dart';
import 'package:amplify_test/verify_code_screen.dart';
import 'package:flutter/cupertino.dart';

class Routes{


  Routes._() ;

 static Map<String, Widget Function(BuildContext)>  get  routes =>{
    RouteConstants.login: (context) =>const  LoginScreen(),
    RouteConstants.viewAllList: (context) =>const ListAllView(),
    RouteConstants.createPost: (context) => const CreatePostScreen(),
    RouteConstants.splashScreen: (context) => const SplashScreen()
    // RouteConstants.verifyCode: (context) => const VerifyCodeScreen()
    // this is a Map<String,dynamic>
  };

}