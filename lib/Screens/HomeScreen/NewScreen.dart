import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Signup/components/body.dart';

class NewScreen extends StatefulWidget {
  @override
  _NewScreenState createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser loggedInUser;
  String name;
  String imageUrl;
  String email;

  @override
  void initState() {
    super.initState();

    getCurrentUser().then((_) {
      start();
    });
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      print("user is ${user == null ? "null" : "Not null"}");

      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print('hi ' + e);
    }
  }

  List start() {
    name = loggedInUser.displayName;
    //email = loggedInUser.email;
    setState(() {});
    return [name, email];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100], Colors.blue[400]],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
//              CircleAvatar(
//                backgroundImage: NetworkImage(
//                  imageUrl,
//                ),
//                radius: 60,
//                backgroundColor: Colors.transparent,
//              ),
              SizedBox(height: 40),
              Text(
                'NAME',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                name != null ? name : 'NUll',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'EMAIL',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                email != null ? email : 'Null',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              RaisedButton(
                onPressed: () {
//                  signOutGoogle();
//                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
