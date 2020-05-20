import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/model/cloud_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_auth/pages/itemData.dart';

Firestore_service firestore_service = new Firestore_service();

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String Username;
  String Useremail;
  FirebaseUser loggedInUser;

  Future<File> takeItemImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    return image;
  }

  Future<void> getCurrentUser() async {
    FirebaseUser user;
    try {
      user = await _auth.currentUser();
      print(
          "user is ${user == null ? "null" : "User name-" + user.displayName}");

      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print('hi ' + e);
    }
    Firestore.instance
        .collection("Shops Details")
        .document(loggedInUser.displayName)
        .snapshots()
        .listen((shopData) {
      setState(() {
        var Shopdata = shopData.data;
        profileData["Shop Name"] = Shopdata["Shop Name"];
        profileData["Name"] = Shopdata["Name"];
        profileData["Number"] = Shopdata["Number"];
        profileData["Address"] = Shopdata["Address"];
      });
    });
    Username = loggedInUser.displayName;
    String UniqueiD = loggedInUser.uid;
    Firestore.instance
        .collection("Shopitems/$Username/$UniqueiD")
        .snapshots()
        .listen((data) {
      setState(() {
        itemData = data.documents;
        gotData = true;
      });
    });
  }

  Future<List> start() async {
    final Username = await loggedInUser.displayName;
    Useremail = await loggedInUser.email;
    setState(() {});
    return [Username, Useremail];
  }

  TabController tabController;

  List<DocumentSnapshot> itemData = new List<DocumentSnapshot>();

  bool gotData = false;

  String name, shopName, number, address;
  Map<String, String> profileData = new Map<String, String>();

  TextEditingController itemQuantity = new TextEditingController();
  TextEditingController itemName = new TextEditingController();
  TextEditingController itemExpiry = new TextEditingController();
  TextEditingController itemPrice = new TextEditingController();
  String selectedOption;

  TextEditingController searchController = new TextEditingController();
  FocusNode searchFocus = new FocusNode();

  List<String> categories = <String>[
    "General",
    "Groceries",
    "Electronics",
    "Add"
  ];

  List<DocumentSnapshot> searchResults;

  Add_ProfileData(String key, String addedtext) async {
    await getCurrentUser();
    await Firestore.instance
        .collection("Shops Details")
        .document(loggedInUser.displayName)
        .setData({
      key: addedtext,
    }, merge: true);
  }

  @override
  void initState() {
    getCurrentUser().then((_) {
      start();
    });
    Username = getCurrentUser().toString();
    tabController = new TabController(length: 2, initialIndex: 0, vsync: this);

    searchController.addListener(() {
      searchResults = new List<DocumentSnapshot>();
      setState(() {
        for (int i = 0; i < itemData.length; i++) {
          List<String> words = itemData[i]["Item Name"].split(" ");
          List<bool> equalDiff = new List<bool>(words.length);
          for (int k = 0; k < equalDiff.length; k++) {
            equalDiff[k] = true;
          }
          for (int l = 0; l < equalDiff.length; l++) {
            for (int j = 0;
                j <
                        (searchController.text.length > words[l].length
                            ? words[l].length
                            : searchController.text.length) &&
                    equalDiff[l];
                j++) {
              if (searchController.text[j].toLowerCase() !=
                  words[l][j].toLowerCase()) {
                equalDiff[l] = false;
              }
            }
          }
          bool equal = false;
          for (int m = 0; m < equalDiff.length && !equal; m++) {
            if (equalDiff[m]) {
              searchResults.add(itemData[i]);
              equal = true;
            }
          }
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    itemName.dispose();
    itemQuantity.dispose();
    itemExpiry.dispose();
    itemPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool inner) {
            return <Widget>[
              SliverAppBar(
                actions: <Widget>[searchField()],
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
                      width: MediaQuery.of(context).size.width * 0.4,
                    )),
                    Align(
                        child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage("assets/icons/shop.jpeg")),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: MediaQuery.of(context).size.width * 0.25))
                  ]),
                ),
                backgroundColor: kPrimaryLightColor,
                bottom: TabBar(
                  tabs: <Widget>[
                    Tab(
                      child: Text(
                        "Details",
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Stock",
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    )
                  ],
                  controller: tabController,
                  indicatorColor: kPrimaryColor,
                ),
                title: Text(
                  "My Profile",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.036),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: <Widget>[
              details(),
              gotData
                  ? gridItems()
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          )),
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
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
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.7),
      itemCount: searchController.text == ''
          ? itemData.length + 1
          : searchResults.length,
      itemBuilder: (context, index) {
        if (index == itemData.length) {
          return InkWell(
            child: Align(
                child: Container(
              child: Card(
                  child: Center(
                      child: Icon(
                Icons.add,
                size: MediaQuery.of(context).size.width * 0.25,
                color: Colors.grey,
              ))),
              width: MediaQuery.of(context).size.width * 0.5,
              //height: MediaQuery.of(context).size.width * 0.5,
            )),
            onTap: () {
              File itemImage;
              if (profileData["Shop Name"] != null &&
                  profileData["Name"] != null &&
                  profileData["Number"] != null &&
                  profileData["Address"] != null) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext c) {
                      return StatefulBuilder(builder: (context, setState) {
                        return SimpleDialog(
                          title: Text("Enter Details of item:"),
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Align(
                                    child: Container(
                                  child: TextField(
                                    controller: itemName,
                                    decoration: InputDecoration(
                                        hintText: "Item Name",
                                        hintStyle: TextStyle(
                                            fontSize:
                                                MediaQuery.of(c).size.width *
                                                    0.03),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                  width: MediaQuery.of(c).size.width * 0.35,
                                )),
                                Align(
                                    child: Container(
                                  child: TextField(
                                    controller: itemQuantity,
                                    decoration: InputDecoration(
                                        hintText: "Item Quantity",
                                        hintStyle: TextStyle(
                                            fontSize:
                                                MediaQuery.of(c).size.width *
                                                    0.03),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                  ),
                                  width: MediaQuery.of(c).size.width * 0.35,
                                ))
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            Row(
                              children: <Widget>[
                                Align(
                                    child: Container(
                                  child: TextField(
                                    controller: itemExpiry,
                                    decoration: InputDecoration(
                                        hintText: "Expiry Date",
                                        hintStyle: TextStyle(
                                            fontSize:
                                                MediaQuery.of(c).size.width *
                                                    0.03),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    keyboardType: TextInputType.datetime,
                                  ),
                                  width: MediaQuery.of(c).size.width * 0.35,
                                )),
                                Align(
                                    child: Container(
                                  child: TextField(
                                    controller: itemPrice,
                                    decoration: InputDecoration(
                                        hintText: "Item Price",
                                        hintStyle: TextStyle(
                                            fontSize:
                                                MediaQuery.of(c).size.width *
                                                    0.03),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    keyboardType: TextInputType.number,
                                  ),
                                  width: MediaQuery.of(c).size.width * 0.35,
                                ))
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                            SizedBox(
                              height: MediaQuery.of(c).size.height * 0.02,
                            ),
                            Center(
                              child: PopupMenuButton<String>(
                                initialValue: selectedOption,
                                onSelected: (selected) {
                                  if (selected == "Add") {
                                    final catCon = new TextEditingController();
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return SimpleDialog(
                                            title: Text("Enter New category:-"),
                                            children: <Widget>[
                                              Align(
                                                  child: Container(
                                                child: TextField(
                                                  controller: catCon,
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                              )),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      child: FlatButton(
                                                    child: Text(
                                                      "Done",
                                                      style: TextStyle(
                                                          color: kPrimaryColor),
                                                    ),
                                                    onPressed: () {
                                                      if (catCon.text != '') {
                                                        Navigator.pop(
                                                            context, true);
                                                      }
                                                    },
                                                  )),
                                                  Expanded(
                                                      child: FlatButton(
                                                    child: Text("Cancel",
                                                        style: TextStyle(
                                                            color:
                                                                kPrimaryColor)),
                                                    onPressed: () {
                                                      Navigator.pop(c, false);
                                                    },
                                                  ))
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                              )
                                            ],
                                          );
                                        }).then((p) {
                                      if (p) {
                                        categories.add(catCon.text);
                                        categories[categories.length - 2] =
                                            categories[categories.length - 1];
                                        categories[categories.length - 1] =
                                            "Add";
                                        catCon.text = '';
                                      }
                                    });
                                  }
                                  setState(() {
                                    selectedOption = selected;
                                  });
                                },
                                itemBuilder: (BuildContext cnt) {
                                  return categories.map((category) {
                                    return PopupMenuItem<String>(
                                      child: Text(category),
                                      value: category,
                                    );
                                  }).toList();
                                },
                                child: Text(selectedOption == null ||
                                        selectedOption == "Add"
                                    ? "Choose category"
                                    : selectedOption),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Center(
                              child: GestureDetector(
                                  child: Container(
                                    child: itemImage == null
                                        ? Center(
                                            child: Icon(
                                            Icons.add_a_photo,
                                          ))
                                        : Image.file(itemImage,
                                            fit: BoxFit.cover),
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height:
                                        MediaQuery.of(context).size.width * 0.3,
                                    color: kPrimaryLightColor,
                                  ),
                                  onTap: () {
                                    takeItemImage().then((img) {
                                      setState(() {
                                        itemImage = img;
                                      });
                                    });
                                  }),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: FlatButton(
                                  child: Text(
                                    "Done",
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                  onPressed: () async {
                                    if (itemName.text != '' &&
                                        itemQuantity.text != '' &&
                                        selectedOption != null &&
                                        selectedOption != "Add" &&
                                        itemImage != null) {
                                      Navigator.pop(context, true);
                                    }
                                  },
                                )),
                                Expanded(
                                    child: FlatButton(
                                  child: Text("Cancel",
                                      style: TextStyle(color: kPrimaryColor)),
                                  onPressed: () {
                                    Navigator.pop(c, false);
                                  },
                                ))
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            )
                          ],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          contentPadding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02,
                              right: MediaQuery.of(context).size.width * 0.02),
                        );
                      });
                    }).then((pop) async {
                  if (pop) {
                    setState(() {
                      gotData = false;
                    });
                    String url = await firestore_service.SaveImage(
                        itemImage, itemName.text);
                    firestore_service.Add_Item_Data(
                        itemName.text,
                        itemQuantity.text,
                        selectedOption,
                        itemPrice.text,
                        itemExpiry.text,
                        url);
                  }
                  itemName.text = '';
                  itemQuantity.text = '';
                  itemExpiry.text = '';
                  itemPrice.text = '';
                  selectedOption = null;
                });
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Please Complete your profile first"),
                ));
              }
            },
          );
        }
        return Align(
            child: Container(
          child: Card(
            child: Stack(children: <Widget>[
              GestureDetector(
                child: Hero(
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.53,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(itemData[index]["Item Image"]),
                            fit: BoxFit.cover)),
                  ),
                  tag: "item",
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return ItemData(
                        itemData[index]["Item Name"],
                        itemData[index]["Item Quantity"],
                        itemData[index]["Item Category"],
                        itemData[index]["Item Expiry"],
                        itemData[index]["Item Price"],
                        itemData[index]["Item Image"]);
                  }));
                },
              ),
              Padding(
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.15,
                  color: Colors.black.withOpacity(0.5),
                ),
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.38),
              ),
              Center(
                  child: Column(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.06,
                ),
                Text(
                  searchController.text == ''
                      ? itemData[index]["Item Name"]
                      : searchResults[index]["Item Name"],
                  style: TextStyle(
                      fontSize: fontSize * 1.2, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.27,
                ),
                Text(
                  searchController.text == ''
                      ? "Rs.${itemData[index]["Item Price"]}"
                      : "Rs.${searchResults[index]["Item Price"]}",
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  searchController.text == ''
                      ? itemData[index]["Item Expiry"]
                      : searchResults[index]["Item Expiry"],
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  searchController.text == ''
                      ? itemData[index]["Item Category"]
                      : searchResults[index]["Item Category"],
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.025,
                ),
                Text(
                  "Quantity",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontSize * 1.1),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.remove,
                          color: Colors.black,
                        ),
                        heroTag: "1_$index",
                        onPressed: () async {
                          String quantityString = searchController.text == ''
                              ? itemData[index]["Item Quantity"]
                              : searchResults[index]["Item Quantity"];
                          int currentQuantityInt = int.parse(quantityString);
                          currentQuantityInt != 0
                              ? currentQuantityInt--
                              : currentQuantityInt = currentQuantityInt;
                          quantityString = currentQuantityInt.toString();
                          await firestore_service.Update_Item(
                              searchController.text == ''
                                  ? itemData[index].documentID
                                  : searchResults[index].documentID,
                              quantityString);

                          searchController.notifyListeners();
                        },
                        backgroundColor: Colors.grey[100],
                        elevation: 2,
                      ),
                      width: MediaQuery.of(context).size.width * 0.06,
                      height: MediaQuery.of(context).size.width * 0.06,
                    ),
                    Text(
                      searchController.text == ''
                          ? itemData[index]["Item Quantity"]
                          : searchResults[index]["Item Quantity"],
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04),
                    ),
                    Container(
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        heroTag: "2_$index",
                        onPressed: () async {
                          String quantityString = searchController.text == ''
                              ? itemData[index]["Item Quantity"]
                              : searchResults[index]["Item Quantity"];
                          int currentQuantityInt = int.parse(quantityString);
                          currentQuantityInt != 0
                              ? currentQuantityInt++
                              : currentQuantityInt = currentQuantityInt;
                          quantityString = currentQuantityInt.toString();
                          await firestore_service.Update_Item(
                              searchController.text == ''
                                  ? itemData[index].documentID
                                  : searchResults[index].documentID,
                              quantityString);
                          searchController.notifyListeners();
                        },
                        backgroundColor: Colors.grey[100],
                        elevation: 2,
                      ),
                      width: MediaQuery.of(context).size.width * 0.06,
                      height: MediaQuery.of(context).size.width * 0.06,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                )
              ])),
              Padding(
                child: Align(
                  child: Container(
                    child: InkWell(
                      child: Icon(
                        Icons.close,
                        size: MediaQuery.of(context).size.width * 0.04,
                      ),
                      onTap: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext c) {
                              return AlertDialog(
                                title: Text(
                                    "Are you sure you want to delete this item?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "No",
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                  )
                                ],
                              );
                            }).then((pop) {
                          if (pop) {
                            firestore_service.Delete_Item(
                                searchController.text == ''
                                    ? itemData[index].documentID
                                    : searchResults[index].documentID);
                            if (searchController.text != '') {
                              setState(() {
                                searchResults.removeAt(index);
                              });
                            }
                          }
                        });
                      },
                    ),
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: MediaQuery.of(context).size.width * 0.05,
                    //color: Colors.white,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.005),
                  ),
                  alignment: Alignment.topLeft,
                ),
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.01,
                    top: MediaQuery.of(context).size.width * 0.01),
              ),
            ]),
          ),
          width: MediaQuery.of(context).size.width * 0.5,
          //height: MediaQuery.of(context).size.width * 0.6,
        ));
      },
    );
  }

  Widget tile(String key, String title, IconData icon) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        child: Text(profileData[key] == null ? "Add $title" : profileData[key], textAlign: TextAlign.right,),
        width: MediaQuery.of(context).size.width * 0.5,
      ),
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
                                          onPressed: () async {
                                            await Add_ProfileData(
                                                key, controller.text);
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

  Widget searchField() {
    return Padding(
      child: Align(
          child: Container(
        child: Row(
          children: <Widget>[
            Align(
                child: Container(
              child: TextField(
                focusNode: searchFocus,
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search Items",
                  contentPadding: EdgeInsets.only(
                      //top: MediaQuery.of(context).size.height * 0.012,
                      ),
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.45,
              //height: MediaQuery.of(context).size.height * 0.05,
            )),
            searchController.text != ''
                ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      searchController.text = '';
                      searchFocus.unfocus();
                    },
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        width: MediaQuery.of(context).size.width * 0.6,
        height: AppBar().preferredSize.height * 0.6,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
      )),
      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
    );
  }
}
