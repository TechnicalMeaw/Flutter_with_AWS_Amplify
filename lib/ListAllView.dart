import 'dart:async';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
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

  List<Post> entries = <Post>[];
  Post? post;

  @override
  void initState() {
    _configureAmplify();

    super.initState();
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
        subscribe() ;
      } catch (e) {
        print(e);
      }
    } on AmplifyAlreadyConfiguredException {
      print(
          'Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
    }
  }

  // Stream<GraphQLResponse<Post>>? subscribe() {
  //   final subscriptionRequest = ModelSubscriptions.onCreate(Post.classType);
  //   final Stream<GraphQLResponse<Post>> operation = Amplify.API
  //       .subscribe(
  //     subscriptionRequest,
  //     onEstablished: () => print('Subscription established'),
  //   )
  //   // Listens to only 5 elements
  //       .take(2)
  //       .handleError(
  //         (error) {
  //       print('Error in subscription stream: $error');
  //     },
  //   );
  //   return operation;
  // }

  void subscribe() {
    final subscriptionRequest = ModelSubscriptions.onCreate(Post.classType);
    final Stream<GraphQLResponse<Post>> operation = Amplify.API.subscribe(
      subscriptionRequest,
      onEstablished: () {
      print('Subscription established');
      getData();
      }
    );
    subscription = Amplify.DataStore.observe(Post.classType).listen(
          (event) {
        print('Subscription event data received: ${event.item}');
        print("subscription event is :: ${event.item.title}");
      },
      onError: (Object e) => print('Error in subscription stream: $e'),
    );
  }

  // void unsubscribe() {
  //   subscription?.cancel();
  // }

  void getData() {
    print("inside get data");
    subscription?.onData((data) {
      print(data);
      setState(() {
        entries.add(data.data!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Center(child: Text(entries[index].title.toString()));
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
