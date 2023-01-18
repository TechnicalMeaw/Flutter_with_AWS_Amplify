import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_test/routes/route_contants.dart';
import 'package:flutter/material.dart';

import 'models/Post.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

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
                          const Text("Create Post", textScaleFactor: 2,),
                          const SizedBox(height: 50,),
                          TextFormField(controller: titleController, decoration: const InputDecoration(hintText: "title"),),
                          TextFormField(controller: contentController, decoration: const InputDecoration(hintText: "content"),),
                          const SizedBox(height: 20,),
                          ElevatedButton(onPressed: (){
                            addData();
                          }, child: const Text("Create Post")),

                        ]),

                  ),

                ]
            ),
          ),
        ),
      ),
    );
  }


  Future<void> addData() async {
    final item = Post(
        title: titleController.text,
        comments: [],
        content: contentController.text);
    await Amplify.DataStore.save(item).then((value) => {
    titleController.clear(), contentController.clear(),
    Navigator.pushReplacementNamed(context, RouteConstants.viewAllList)
    });
  }
}
