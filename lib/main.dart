import 'dart:async';

import 'package:amplify_test/ListAllView.dart';
import 'package:amplify_test/login_screen.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:amplify_test/routes/routes.dart';
import 'package:amplify_test/signup_screen.dart';
import 'package:flutter/material.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';

// Generated in previous step
import 'models/ModelProvider.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: RouteConstants.splashScreen,
      routes: Routes.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}












class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  bool _amplifyConfigured = false;
  StreamSubscription? subscription;
  ValueNotifier<List<Post>> posts = ValueNotifier([]);
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _configureAmplify();
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
      try{
        setState(() {
          _amplifyConfigured = true;
        });
        subscribe();
      }catch(e){
        print(e);
      }
    } on AmplifyAlreadyConfiguredException {
      print('Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
    }
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
                child: Column(
                    children: [TextFormField(controller: titleController, decoration: const InputDecoration(hintText: "title"),),
                      TextFormField(controller: contentController, decoration: const InputDecoration(hintText: "content"),),
                      ElevatedButton(onPressed: (){
                        addData();
                      }, child: const Text("Submit"))
                ]),

                ),
                ElevatedButton(onPressed: (){

                updateData();

              }, child: const Text("Fetch")),
                  const SizedBox(height: 20,),

                   ValueListenableBuilder<List<Post>>(
                        valueListenable: posts, builder: (BuildContext context, value, Widget? child){
                          return ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: posts.value.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _controller,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Center(child: Column(children:
                              [Text("Title : ${posts.value[index].title}"),
                              Text("Content : ${posts.value[index].content}"),
                              ElevatedButton(onPressed: (){
                                deleteData(posts.value[index]);
                              }, child: const Text("Delete"))],)
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) => const Divider(),
                          );
                    }),


            ]
            ),
          ),
        ),
      ),
    );
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
          posts.value.add(event.data?? Post(title: "Loading..."));
        });
      },
      onError: (Object e) => print('Error in subscription stream: $e'),
    );
  }

  void unsubscribe() {
    subscription?.cancel();
  }


  Future<void> addData() async {
    final item = Post(
        title: titleController.text,
        comments: [],
        content: contentController.text);
    await Amplify.DataStore.save(item);

    titleController.clear();
    contentController.clear();
  }

  Future<void> deleteData(Post post) async {
    await Amplify.DataStore.delete(post);
    updateData();
  }

  Future<void> updateData() async {
    await Amplify.DataStore.start();

    try {
      posts.value = await Amplify.DataStore.query(Post.classType);
      print(posts.value);
    } catch (e) {
      print("Could not query DataStore: $e");
    }

  }

}
