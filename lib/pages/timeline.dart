import 'package:flutter/material.dart';
import 'package:fluttergram/widgets/header.dart';
import 'package:fluttergram/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    // TODO: implement initState
 //createUser();
  // updateUser();
  deleteUser();
    super.initState();

  }

  createUser() async{
    await usersRef.document("ssadasd").setData({
      "username":"Elon",
      "postsCount":0,
      "isAdmin" : false
    });
  }

  updateUser() async{
     final doc = await usersRef.document("ssadasd").get();

     if(doc.exists){
       doc.reference.updateData({
         "username":"Elon Musk",
         "postsCount":0,
         "isAdmin" : false
       });
     }
  }

  deleteUser() async{
   final doc =await usersRef.document("ssadasd").get();
   if(doc.exists){
     doc.reference.delete();
   }
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(isAppTitle: true),
        body: StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return linearProgress();
            }
            final List<Text> children = snapshot.data.documents
                .map((user) => Text(user['username']))
                .toList();
            return Container(
              child: ListView(
                children: children,
              ),
            );
          },
        ));
  }
}
