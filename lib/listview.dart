/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/cloud_firebase.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth/constants.dart';

import 'dart:io';

Firestore_service firestore_service = new Firestore_service();

//OTHER UI WITH LISTVIEW TO TRANSFER DATA IN REALTIME

class Listv extends StatefulWidget {
  @override
  _ListvState createState() => _ListvState();
}

class _ListvState extends State<Listv> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name;
  String email;
  FirebaseUser loggedInUser;

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
    email = loggedInUser.email;
    setState(() {});
    return [name, email];
  }

  TextEditingController itemName = new TextEditingController();
  String selectedOption;

  List<String> categories = <String>[
    "General",
    "Groceries",
    "Electronics",
    "Add"
  ];
  TextEditingController itemQuantity = new TextEditingController();
  TextEditingController searchController = new TextEditingController();
  TextEditingController itemExpiry = new TextEditingController();
  TextEditingController itemPrice = new TextEditingController();

  FocusNode searchFocus = new FocusNode();

  List<DocumentSnapshot> allItems = new List<DocumentSnapshot>();
  bool gotInitialItems = false;
  final listKey = new GlobalKey<AnimatedListState>();

  List<DocumentSnapshot> searchResults;

  void initState() {
    getCurrentUser().then((_) {
      start();
    });
    searchController.addListener(() {
      searchResults = new List<DocumentSnapshot>();
      setState(() {
        for (int i = 0; i < allItems.length; i++) {
          List<String> words = allItems[i]["Item Name"].split(" ");
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
              searchResults.add(allItems[i]);
              equal = true;
            }
          }
        }
      });
    });

    Firestore.instance.collection("Shop Id").snapshots().listen((data) {
      setState(() {
        if (!gotInitialItems) {
          gotInitialItems = true;
          allItems = data.documents;
        } else if (gotInitialItems) {
          if (data.documents.length > allItems.length) {
            bool found = false;
            for (int i = 0; i < data.documents.length && !found; i++) {
              bool foundIt = false;
              for (int j = 0; j < allItems.length && !foundIt; j++) {
                if (data.documents[i]["Item Name"] ==
                    allItems[j]["Item Name"]) {
                  foundIt = true;
                }
              }
              if (foundIt == false) {
                found = true;
                listKey.currentState.insertItem(allItems.length);
                allItems.add(data.documents[i]);
              }
            }
          } else if (data.documents.length < allItems.length) {
            bool found = false;
            for (int i = 0; i < allItems.length && !found; i++) {
              bool foundIt = false;
              for (int j = 0; j < data.documents.length && !foundIt; j++) {
                if (data.documents[j]["Item Name"] ==
                    allItems[i]["Item Name"]) {
                  foundIt = true;
                }
              }
              if (foundIt == false) {
                found = true;
                if (searchController.text == '') {
                  listKey.currentState.removeItem(i, (context, animation) {
                    return SizedBox(
                      height: 0,
                      width: 0,
                    );
                  });
                }
                allItems.removeAt(i);
              }
            }
          } else {
            bool done = false;
            for (int i = 0; i < data.documents.length && !done; i++) {
              bool found = false;
              for (int j = 0; j < allItems.length && !found; j++) {
                if (data.documents[i]["Item Name"] ==
                    allItems[j]["Item Name"]) {
                  found = true;
                  if (data.documents[i]["Item Quantity"] !=
                      allItems[j]["Item Quantity"]) {
                    allItems[j] = data.documents[i];
                    done = true;
                  }
                }
              }
            }
          }
        }
      });
    });
    super.initState();
  }

  void dispose() {
    searchController.dispose();
    itemName.dispose();
    itemQuantity.dispose();
    itemExpiry.dispose();
    itemPrice.dispose();

    super.dispose();
  }

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    if (document['Item Name'] != null ||
        document['Item Quantity'] != null ||
        document['Item Category'] != null ||
        document['Item Price'] != null ||
        document['Item Expiry'] != null) {
      return Padding(
        child: Container(
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Item name-" + document.data["Item Name"]),
                  Text("Price Rs-" + document.data["Item Price"]),
                  Text("Expiry Date-" + document.data["Item Expiry"]),
                ],
              ),
              trailing: Column(
                children: <Widget>[
                  Text("Quantity-  " + document['Item Quantity']),
                  Text("Category- " + document['Item Category']),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              onTap: () {
                String ClickedItemDocumentId = document.documentID;
                int choice = -1;
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext cn) {
                      return Wrap(children: <Widget>[
                        BottomSheet(
                          builder: (c) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Change Quantity"),
                                    leading: Icon(Icons.edit),
                                    onTap: () {
                                      choice = 0;
                                      Navigator.pop(c);
                                    },
                                  ),
                                  ListTile(
                                    title: Text("Delete Item"),
                                    leading: Icon(Icons.delete),
                                    onTap: () {
                                      choice = 1;
                                      Navigator.pop(c);
                                    },
                                  )
                                ],
                              ),
                            );
                          },
                          onClosing: () {},
                        )
                      ]);
                    }).then((_) {
                  final qControl = new TextEditingController();
                  if (choice == 0) {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext ct) {
                          return SimpleDialog(
                            title: Text("Enter new Quantity"),
                            children: <Widget>[
                              Align(
                                  child: Container(
                                child: TextField(
                                  controller: qControl,
                                ),
                                width: MediaQuery.of(ct).size.width * 0.6,
                              )),
                              Row(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "Done",
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                    onPressed: () {
                                      if (qControl.text != '') {
                                        Navigator.pop(context, true);
                                      }
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: kPrimaryColor),
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
                        firestore_service.Update_Item(
                            ClickedItemDocumentId, qControl.text);
                        qControl.text = "";
                        setState(() {
                          searchController.text = '';
                        });
                      }
                    });
                  } else if (choice == 1) {
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
                        firestore_service.Delete_Item(ClickedItemDocumentId);
                        if (searchController.text != '') {
                          setState(() {
                            bool done = false;
                            for (int i = 0;
                                i < searchResults.length && !done;
                                i++) {
                              if (searchResults[i]["Item Name"] ==
                                  document["Item Name"]) {
                                searchResults.removeAt(i);
                                done = true;
                              }
                            }
                          });
                        }
                      }
                    });
                  }
                });
              },
            ),
            color: Colors.white,
            width: MediaQuery.of(context).size.width),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appbar(),
        body: gotInitialItems
            ? searchController.text == ''
                ? AnimatedList(
                    key: listKey,
                    initialItemCount: allItems.length,
                    itemBuilder: (context, index, animation) {
                      return ScaleTransition(
                        child: _buildList(context, allItems[index]),
                        scale: animation,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (c, index) {
                      return _buildList(c, searchResults[index]);
                    },
                  )
            : Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            searchController.text = '';
            setState(() {});
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext c) {
                  return StatefulBuilder(builder: (context, setState) {
                    return SimpleDialog(
                        title: Text("Enter Name and Quantity of item:"),
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
                                                  MainAxisAlignment.spaceEvenly,
                                            )
                                          ],
                                        );
                                      }).then((p) {
                                    if (p) {
                                      categories.add(catCon.text);
                                      categories[categories.length - 2] =
                                          categories[categories.length - 1];
                                      categories[categories.length - 1] = "Add";
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
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: FlatButton(
                                child: Text(
                                  "Done",
                                  style: TextStyle(color: kPrimaryColor),
                                ),
                                onPressed: () {
                                  if (itemName.text != '' &&
                                      itemQuantity.text != '' &&
                                      selectedOption != null) {
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
                            borderRadius: BorderRadius.circular(20)));
                  });
                }).then((pop) {
              if (pop) {
                firestore_service.Add_Item_Data(
                    itemName.text,
                    itemQuantity.text,
                    selectedOption,
                    itemPrice.text,
                    itemExpiry.text,
                    File(""));
              }
              itemName.text = '';
              itemQuantity.text = '';
              itemExpiry.text = '';
              itemPrice.text = '';
              selectedOption = null;
            });
          },
          backgroundColor: kPrimaryColor,
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget appbar() {
    return AppBar(
      title: Text("Stock"),
      actions: <Widget>[
        Padding(
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
                borderRadius: BorderRadius.circular(20),
                color: kPrimaryLightColor),
          )),
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
        )
      ],
    );
  }
}
*/