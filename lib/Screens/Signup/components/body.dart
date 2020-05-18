import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Login/login_screen.dart';
import 'package:flutter_auth/Screens/Signup/components/background.dart';
import 'package:flutter_auth/Screens/Signup/components/or_divider.dart';
import 'package:flutter_auth/Screens/Signup/components/social_icon.dart';
import 'package:flutter_auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_input_field.dart';
import 'package:flutter_auth/components/rounded_password_field.dart';
import 'package:flutter_auth/pages/homepage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String name;
  String email;
  String imageUrl;
  var user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  getCurrentUser() async{
    user = await _auth.currentUser();
  }

  // ignore: missing_return
  Future<FirebaseUser> _signIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final AuthResult authResult =
          await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoUrl != null);

      name = user.displayName;
      email = user.email;
      imageUrl = user.photoUrl;

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return authResult.user;
    } catch (e) {
      print(e);
    }
  }

  Future<int> getUser() async{
    var isThere = await Firestore.instance.collection('users').where('email', isEqualTo: user.email).getDocuments();
    var num = isThere.documents.length;
    return num;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP USING GOOGLE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedButton(
              text: "SIGNUP",
              press: () {},
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {
                    try{
                      _signIn().whenComplete(() async{
                        var num = await getUser();
                        if(num == 0) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString('email', user.email);
                          Firestore.instance.collection('users').add({
                            'name': name,
                            'email': user.email,
                            'pincode': null,
                            "address": null,
                            'phone_no': null,
                          });
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return (HomePage());
                          }));
                        }
                        else{
                          googleSignIn.signOut();
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.remove('email');
                          Alert(
                            context: context,
                            title: 'Error',
                            desc: 'Account already exists, please LogIn.',
                            buttons: [
                              DialogButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple[800],
                                    Colors.purple
                                  ]
                                ),
                              ),
                            ]
                          ).show();
                          print('Account Already Exists');
                        }
                      });
                    }catch(e){
                      print(e);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
