import 'package:flutter/material.dart';
import 'package:fluttergram/widgets/header.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(title: 'Profile'),
      body: Text("profile"),
    );
  }
}
