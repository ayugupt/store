import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/listview.dart';
import 'package:flutter_auth/model/cloud_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Firestore_service firestore_service = new Firestore_service();

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  TabController tabController;

  List<DocumentSnapshot> itemData = new List<DocumentSnapshot>();
  bool gotData = false;

  String name, shopName, number, address;
  Map<String, String> profileData = new Map<String, String>();

  @override
  void initState() {
    profileData["Shop Name"] = null;
    profileData["Name"] = null;
    profileData["Number"] = null;
    profileData["Address"] = null;

    tabController = new TabController(length: 2, initialIndex: 0, vsync: this);

    Firestore.instance.collection("Shop Id").snapshots().listen((data) {
      setState(() {
        itemData = data.documents;
        gotData = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool inner) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Stack(children: <Widget>[
                    Align(
                        child: Container(
                      child: Image.asset("assets/icons/border.png"),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                    )),
                    Align(
                        child: Container(
                      child: Image.asset("assets/icons/circular.png"),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      width: MediaQuery.of(context).size.width * 0.3,
                    ))
                  ]),
                ),
                backgroundColor: kPrimaryLightColor,
                bottom: TabBar(
                  tabs: <Widget>[
                    Tab(
                      child: Text(
                        "Stock",
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Details",
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    )
                  ],
                  controller: tabController,
                  indicatorColor: kPrimaryColor,
                ),
                title: Text(
                  "My Profile",
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: <Widget>[gridItems(), details()],
          )),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget details() {
    return Container(
        child: Column(
      children: <Widget>[
        tile("Shop Name", "Shop Name", Icons.home),
        Divider(
          thickness: 1,
          indent: MediaQuery.of(context).size.width * 0.05,
          endIndent: MediaQuery.of(context).size.width * 0.05,
        ),
        tile("Address", "Address of the shop", Icons.mail),
        Divider(
          thickness: 1,
          indent: MediaQuery.of(context).size.width * 0.05,
          endIndent: MediaQuery.of(context).size.width * 0.05,
        ),
        tile("Number", "Phone Number", Icons.phone),
        Divider(
          thickness: 1,
          indent: MediaQuery.of(context).size.width * 0.05,
          endIndent: MediaQuery.of(context).size.width * 0.05,
        ),
        tile("Name", "Name of manager", Icons.person),
        Divider(
          thickness: 1,
          indent: MediaQuery.of(context).size.width * 0.05,
          endIndent: MediaQuery.of(context).size.width * 0.05,
        )
      ],
    ));
  }

  Widget gridItems() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 1),
      itemCount: itemData.length,
      itemBuilder: (context, index) {
        return Align(
            child: Container(
          child: Card(
            child: Center(
                child: Column(children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                itemData[index]["Item Name"],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Text(
                itemData[index]["Item Category"],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Text(
                itemData[index]["Item Quantity"],
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ])),
          ),
          width: MediaQuery.of(context).size.width * 0.33,
          height: MediaQuery.of(context).size.width * 0.33,
        ));
      },
    );
  }

  Widget tile(String key, String title, IconData icon) {
    return ListTile(
      title: Text(title),
      trailing:
          Text(profileData[key] == null ? "Add $title" : profileData[key]),
      leading: Icon(icon),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (cntxt) {
              return Wrap(
                children: <Widget>[
                  BottomSheet(
                    onClosing: () {},
                    builder: (c) {
                      return ListTile(
                        title: Text("Edit $title"),
                        leading: Icon(Icons.edit),
                        onTap: () {
                          final controller = new TextEditingController();
                          showDialog(
                              context: c,
                              builder: (ct) {
                                return SimpleDialog(
                                  title: Text("Type the new data:-"),
                                  children: <Widget>[
                                    Align(
                                      child: Container(
                                        width:
                                            MediaQuery.of(ct).size.width * 0.6,
                                        child: TextField(
                                          controller: controller,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            "Done",
                                            style:
                                                TextStyle(color: kPrimaryColor),
                                          ),
                                          onPressed: () {
                                            if (controller.text != '') {
                                              Navigator.pop(context, true);
                                            }
                                          },
                                        ),
                                        FlatButton(
                                          child: Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: kPrimaryColor),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                    )
                                  ],
                                );
                              }).then((pop) {
                            if (pop) {
                              setState(() {
                                profileData[key] = controller.text;
                                controller.text = '';
                              });
                              Navigator.pop(context);
                            }
                          });
                        },
                      );
                    },
                  )
                ],
              );
            });
      },
    );
  }
}
