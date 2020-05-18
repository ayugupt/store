import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Login/login_screen.dart';

class MiddleScreen extends StatefulWidget {
  @override
  _MiddleScreenState createState() => _MiddleScreenState();
}

class _MiddleScreenState extends State<MiddleScreen> {

  Future<SharedPreferences> checkLoggedIn () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }
  getEmail () {
    checkLoggedIn().then((prefs) {
      var email = prefs.getString('email');
      if(email == null){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => WelcomeScreen()));
      }
      else{
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
        ),
      ),
    );
  }
}

