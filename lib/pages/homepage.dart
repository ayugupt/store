import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_auth/Screens/Login/login_screen.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/pages/profilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_auth/pages/orderDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  //bool showMore = false;
  List<bool> showMore = new List<bool>();

  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  Tween<double> tween;

  int orders = 0;
  FirebaseUser user;
  QuerySnapshot users;
  var allUsers;
  bool isPacked;
  List<AnimationController> controllers = new List<AnimationController>();
  List<Animation> animations = new List<Animation>();

  Map<String, bool> filterVars = new Map<String, bool>();

  List<String> categories = ["Cash", "Netbanking", "UPI", "Cheque"];

  List<bool> ordersPacked = new List<bool>();

  bool gotLength = false;

  Future<String> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    print(email);
    return email;
  }

  Future getUser() async {
    user = await _auth.currentUser();
    //print(user.email);
  }

  Future setContent() async {
    users = await _fireStore.collection('Buy').getDocuments();
    setState(() {
      var len = users.documents.length;
      gotLength = true;
      orders = len;
    });
  }

  initialWork() {
    categories.forEach((category) {
      filterVars[category] = false;
    });
    tween = new Tween<double>(begin: 0, end: 0.15);

    for (int i = 0; i < orders; i++) {
      showMore.add(false);
    }

    for (int i = 0; i < orders; i++) {
      controllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)));
    }

    for (int i = 0; i < orders; i++) {
      animations.add(tween.animate(controllers[i]));
    }
    for (int i = 0; i < animations.length; i++) {
      animations[i].addListener(() {
        setState(() {});
      });
    }

    for (int j = 0; j < orders; j++) {
      ordersPacked.add(false);
    }
  }

  @override
  void initState() {
    if (checkLoggedIn() == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    getUser().then((value) => setContent().then((_) => initialWork()));
    super.initState();
  }

  @override
  void dispose() {
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gotLength
          ? StreamBuilder(
              stream: _fireStore.collection('Buy').snapshots(),
              builder: (context, buySnapshots) {
                //print(buySnapshots.data.documents.length);
                return StreamBuilder(
                  stream: _fireStore.collection('Items').snapshots(),
                  builder: (context, itemSnapshots) {
                    return StreamBuilder(
                      stream: _fireStore.collection('users').snapshots(),
                      builder: (context, userSnapshots) {
                        if (!userSnapshots.hasData ||
                            !itemSnapshots.hasData ||
                            !buySnapshots.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlueAccent,
                            ),
                          );
                        }
                        List<Map> containers = [];
                        for (var userSnap in userSnapshots.data.documents) {
                          for (var buy in buySnapshots.data.documents) {
                            if (buy.data['userId'].toString().trim() ==
                                userSnap.data['email'].toString().trim()) {
                              for (var item in itemSnapshots.data.documents) {
                                if (buy.data['Item name'].toString().trim() ==
                                    item.data['name'].toString().trim()) {
                                  Map<String, String> container = {
                                    'name': userSnap.data['name'],
                                    'address': userSnap.data['address'],
                                    'email': userSnap.data['email'],
                                    'number': userSnap.data['phone_no'],
                                    'pinCode': userSnap.data['pincode'],
                                    'itemName': item.data['name'],
                                    'quantity': buy.data['quantity'],
                                    'totalPrice': (int.parse(buy
                                                .data['quantity']
                                                .toString()) *
                                            int.parse(
                                                item.data['price'].toString()))
                                        .toString(),
                                    'isPacked': buy.data['isPacked'].toString(),
                                    'ID': buy.documentID,
                                  };
                                  containers.add(container);
                                }
                              }
                            }
                          }
                        }
                        containers = containers.toSet().toList();
                        containers.remove(null);
                        allUsers = groupBy(containers, (obj) => obj['pinCode'])
                            .values
                            .toList();
                        print(containers);

                        if (buySnapshots.data.documents.length > orders) {
                          for (int i = orders;
                              i < buySnapshots.data.documents.length;
                              i++) {
                            showMore.add(false);
                            controllers.add(AnimationController(
                                vsync: this,
                                duration: Duration(milliseconds: 200)));
                            animations.add(tween.animate(controllers[i]));
                            animations[i].addListener(() {
                              setState(() {});
                            });
                          }
                          ordersPacked.add(false);
                          orders = buySnapshots.data.documents.length;
                        }

                        return CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              title: Text("Orders"),
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.tune,
                                  ),
                                  onPressed: () {
                                    double headingSize =
                                        MediaQuery.of(context).size.width *
                                            0.05;
                                    double leftPadding =
                                        MediaQuery.of(context).size.width *
                                            0.02;
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return Wrap(children: <Widget>[
                                              Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                insetPadding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.1,
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.05,
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05),
                                                child: Column(
                                                  children: <Widget>[
                                                    SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.02),
                                                    Text(
                                                      "Filter Options",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              headingSize),
                                                    ),
                                                    Padding(
                                                      child: Align(
                                                        child: Text(
                                                          "Mode of payment:",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  headingSize),
                                                        ),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          left: leftPadding,
                                                          top: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.03),
                                                    ),
                                                    GridView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          categories.length,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 2,
                                                              childAspectRatio:
                                                                  3),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                            child:
                                                                checkBoxWithTitle(
                                                                    categories[
                                                                        index],
                                                                    setState));
                                                      },
                                                      shrinkWrap: true,
                                                    )
                                                  ],
                                                ),
                                              )
                                            ]);
                                          });
                                        });
                                  },
                                )
                              ],
                              floating: true,
                            ),
                            SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                                if (orders == 0) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          'No Orders Yet',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return orderCard(index, containers[index]);
                                }
                              }, childCount: orders),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      backgroundColor: Colors.grey[200],
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              color: kPrimaryColor,
            ),
            ListTile(
                leading: Icon(Icons.person),
                title: Text("My Shop Profile"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return Profile();
                  }));
                }),
            ListTile(
                leading: Icon(Icons.arrow_back_ios),
                title: Text("Logout"),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('email');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return LoginScreen();
                  }));
                })
          ],
        ),
      ),
    );
  }

  Widget orderCard(int index, Map<String, String> details) {
    return Column(children: <Widget>[
      InkWell(
        child: Align(
          child: Container(
            child: Card(
              child: Stack(children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      child: Align(
                        child: Text(details["name"]),
                        alignment: Alignment.centerLeft,
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                    Padding(
                      child: Align(
                        child: Text(
                          details["address"] != null
                              ? details["address"]
                              : "Address",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                    Padding(
                      child: Align(
                          child: Text(
                            "Order Status",
                          ),
                          alignment: Alignment.centerLeft),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                    Padding(
                      child: Align(
                          child: Text(
                            "Payment Method",
                          ),
                          alignment: Alignment.centerLeft),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                    Padding(
                      child: Row(
                        children: <Widget>[
                          Text("Order Packed"),
                          Checkbox(
                            value: details['isPacked'] == 'true' ? true : false,
                            onChanged: (val) {
                              _fireStore
                                  .collection('Buy')
                                  .document(details['ID'])
                                  .updateData({
                                'isPacked': '$val',
                              });
                            },
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.02,
                          bottom: MediaQuery.of(context).size.height * 0.01),
                    )
                  ],
                ),
                Align(
                  child: IconButton(
                    icon: Icon(!showMore[index]
                        ? Icons.arrow_drop_down
                        : Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        showMore[index] = !showMore[index];
                        if (showMore[index] == true) {
                          controllers[index].forward();
                        } else {
                          controllers[index].reverse();
                        }
                      });
                    },
                  ),
                  alignment: Alignment.bottomRight,
                )
              ]),
            ),
            width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height * 0.2,
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OrderDetails(details);
          }));
        },
      ),
      showMore[index] || animations[index].value != 0
          ? Align(
              child: Container(
                color: Colors.grey[100],
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height *
                    animations[index].value,
                child: showMore[index] && controllers[index].isCompleted
                    ? Column(children: <Widget>[
                        ListTile(
                          title: Text("Total Items"),
                          trailing: Text(details["quantity"]),
                          dense: true,
                        ) /*Align(
                            child: Text("Total Items"),
                            alignment: Alignment.centerLeft,
                          )*/
                        ,
                        ListTile(
                          title: Text("Total Price"),
                          trailing: Text(details["totalPrice"]),
                          dense: true,
                        ),
                      ])
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ),
            )
          : SizedBox(
              height: 0,
              width: 0,
            ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.01,
      )
    ]);
  }

  Widget checkBoxWithTitle(String title, StateSetter setState) {
    return Row(
      children: <Widget>[
        Text(title),
        Checkbox(
          value: filterVars[title],
          onChanged: (change) {
            setState(() {
              if (change) {
                categories.forEach((category) {
                  if (title != category && filterVars[category] == true) {
                    filterVars[category] = false;
                  }
                });
              }
              filterVars[title] = change;
            });
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
