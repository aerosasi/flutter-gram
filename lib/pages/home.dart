import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttergram/models/user.dart';
import 'package:fluttergram/pages/activity_feed.dart';
import 'package:fluttergram/pages/create_account.dart';
import 'package:fluttergram/pages/profile.dart';
import 'package:fluttergram/pages/search.dart';
import 'package:fluttergram/pages/timeline.dart';
import 'package:fluttergram/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final timeStamp = DateTime.now();
User currentUser;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when the user is signed in
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        if (account != null) {
          createUserInFirestore();
          setState(() {
            isAuth = true;
          });
        } else {
          setState(() {
            isAuth = false;
          });
        }
      },
      onError: (error) {
        print('Error Signed in: $error');
      },
    );
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      if (account != null) {
        print('User signed in is  : $account');
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    }).catchError((err) {
      print('Error Signed in: $err');
    });
  }


  createUserInFirestore() async{
    // check if user exists in user collection deatabase (acc to ther id)
    final user=googleSignIn.currentUser;
    DocumentSnapshot doc= await usersRef.document(user.id).get();

    //if user does not exist we need to take them to create account page
    if(!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      //get username from create account and use it to make new user document in yser colllection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": " ",
        "Timestamp": timeStamp,

      });
      doc = await usersRef.document(user.id).get();
    }
  currentUser =  User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);

  }


// controllers needs to be disposed
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void onTap(int pageIndex) {
    print(pageIndex);
    print(pageIndex.toDouble());
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
        //  Timeline(),
          RaisedButton(
            child: Text('Logout'),
            onPressed: logout,
          ),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap:onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35.0,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Flutter-Gram',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90.0, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => login(),
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/google_signin_button.png'),
                  fit: BoxFit.cover,
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
