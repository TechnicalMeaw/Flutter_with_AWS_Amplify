import 'dart:async';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';
import 'models/Post.dart';

class ListAllView extends StatefulWidget {
  const ListAllView({Key? key}) : super(key: key);

  @override
  State<ListAllView> createState() => _ListAllViewState();
}

class _ListAllViewState extends State<ListAllView> {
  bool _amplifyConfigured = false;
  StreamSubscription? subscription;
  ValueNotifier<List<Post>> allPosts = ValueNotifier([]);
  final ScrollController _controller = ScrollController();
  ValueNotifier<bool> _isLogOutEnabled = ValueNotifier(false);

  Post? post;

  @override
  void initState() {
    if (!Amplify.isConfigured){
      _configureAmplify();
    }else{
      getData();
      subscribe();
      checkUserSignedIn();
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getData();
    }
  }

  void _configureAmplify() async {
    final datastorePlugin = AmplifyDataStore(
      modelProvider: ModelProvider.instance,
    );
    // Add the following line and update your function call with `addPlugins`
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    await Amplify.addPlugins([datastorePlugin, api]);
    try {
      await Amplify.configure(amplifyconfig);
      try {
        setState(() {
          _amplifyConfigured = true;
        });
        getData();
        subscribe();
        checkUserSignedIn();
      } catch (e) {
        print(e);
      }
    } on AmplifyAlreadyConfiguredException {
      print(
          'Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ValueListenableBuilder<List<Post>>(
            valueListenable: allPosts, builder: (BuildContext context, posts, Widget? child){
          return SingleChildScrollView(
            child: Column(
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [ElevatedButton(onPressed: (){
                  checkCurrentUser();
                }, child: const Text("Create Post")),
                  ValueListenableBuilder(valueListenable: _isLogOutEnabled, builder: (BuildContext context, isEnabled, Widget? child){
                    return MaterialButton(onPressed: isEnabled ? (){
                      signOut();
                      } : null,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        disabledColor: Colors.black12,
                        child: const Text("Log out"));
                  })

                  ],)
               ,
                ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: posts.length,
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Center(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children:
                  [const SizedBox(height: 20,),
                    Text("Title : ${posts[index].title}", style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,

                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,),
                    const SizedBox(height: 10,),
                    Text("Content : ${posts[index].content}"),
                    const SizedBox(height: 20,),
                    // ElevatedButton(onPressed: (){
                    //   deleteData(posts[index]);
                    // }, child: const Text("Delete"))
                  ],)
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ]),
          );
        }),
      ),
    );
  }

  void checkUserSignedIn() async {
    try {
      final awsUser = await Amplify.Auth.getCurrentUser();
      //send user to dashboard
      _isLogOutEnabled.value = true;
    } on AuthException catch (e) {
      //send user to login
      _isLogOutEnabled.value = false;
      print(e);
    }
  }


  void checkCurrentUser() async {
    try {
      final awsUser = await Amplify.Auth.getCurrentUser();
      //send user to dashboard
      Navigator.pushNamedAndRemoveUntil(context, RouteConstants.createPost ,
              (route)=> true);
    } on AuthException catch (e) {
      //send user to login
      Navigator.pushReplacementNamed(context, RouteConstants.login);
      print(e);
    }
  }

  Future<void> getData() async {
    await Amplify.DataStore.start();
    try {
      allPosts.value = await Amplify.DataStore.query(Post.classType);
      print(allPosts.value);
    } catch (e) {
      print("Could not query DataStore: $e");
    }
  }

  Future<void> deleteData(Post post) async {
    await Amplify.DataStore.delete(post);
    getData();
  }

  void subscribe() {
    final subscriptionRequest = ModelSubscriptions.onCreate(Post.classType);
    final Stream<GraphQLResponse<Post>> operation = Amplify.API.subscribe(
      subscriptionRequest,
      onEstablished: () => print('Subscription established'),
    );
    subscription = operation.listen(
          (event) {
        print('Subscription event data received: ${event.data}');

        setState(() {
          allPosts.value.add(event.data?? Post(title: "Loading..."));
        });

      },
      onError: (Object e) => print('Error in subscription stream: $e'),
    );
  }

  void unsubscribe() {
    subscription?.cancel();
  }

  Future<void> signOut() async{
    try {
      Amplify.Auth.signOut();
      //send user to login
      Navigator.pushReplacementNamed(context, RouteConstants.login);
    } catch (e) {
      print(e);
    }
  }
}
