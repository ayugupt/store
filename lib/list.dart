import 'package:flutter/material.dart';

import 'package:flutter_auth/constants.dart';

class ItemList extends StatefulWidget {
  ItemListState createState() => ItemListState();
}

class ItemListState extends State<ItemList> {
  List<String> itemNameList = new List<String>();
  List<String> itemQuantityList = new List<String>();
  List<String> itemCategory = new List<String>();

  String selectedOption;

  List<int> searchIndices;

  List<String> categories = <String>["General", "Groceries", "Electronics"];

  TextEditingController itemName = new TextEditingController();
  TextEditingController itemQuantity = new TextEditingController();

  TextEditingController searchController = new TextEditingController();
  FocusNode searchFocus = new FocusNode();

  final listKey = GlobalKey<AnimatedListState>();

  @override
  void initState(){
    searchController.addListener(() {
      searchIndices = new List<int>();
      setState(() {
        for (int i = 0; i < itemNameList.length; i++) {
          List<String> words = itemNameList[i].split(" ");
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
              searchIndices.add(i);
              equal = true;
            }
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: searchController.text == ''
          ? AnimatedList(
              key: listKey,
              initialItemCount: itemNameList.length,
              itemBuilder: (BuildContext cntxt, index, animation) {
                return ScaleTransition(
                  child: Padding(
                    child: Container(
                      child: ListTile(
                        leading: Text("${index + 1}"),
                        title: Text(itemNameList[index]),
                        trailing: Column(
                          children: <Widget>[
                            Text(itemQuantityList[index]),
                            Text(itemCategory[index])
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        onTap: () {
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
                                          width: MediaQuery.of(ct).size.width *
                                              0.6,
                                        )),
                                        Row(
                                          children: <Widget>[
                                            FlatButton(
                                              child: Text(
                                                "Done",
                                                style: TextStyle(
                                                    color: kPrimaryColor),
                                              ),
                                              onPressed: () {
                                                if (qControl.text != '') {
                                                  Navigator.pop(ct, true);
                                                }
                                              },
                                            ),
                                            FlatButton(
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: kPrimaryColor),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(ct, false);
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
                                    itemQuantityList[index] = qControl.text;
                                  });
                                }
                              });
                            } else if (choice == 1) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext c) {
                                    return AlertDialog(
                                      title: Text(
                                          "Are you sure you want to delete this item?"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            "Yes",
                                            style:
                                                TextStyle(color: kPrimaryColor),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(c, true);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text(
                                            "No",
                                            style:
                                                TextStyle(color: kPrimaryColor),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(c, false);
                                          },
                                        )
                                      ],
                                    );
                                  }).then((pop) {
                                if (pop) {
                                  listKey.currentState.removeItem(index,
                                      (cnt, animation) {
                                    return SizedBox(height: 0, width: 0);
                                  });
                                  setState(() {
                                    itemNameList.removeAt(index);
                                    itemQuantityList.removeAt(index);
                                    itemCategory.removeAt(index);
                                  });
                                }
                              });
                            }
                          });
                        },
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.005),
                  ),
                  scale: animation,
                );
              },
            )
          : ListView.builder(
              itemCount: searchIndices.length,
              itemBuilder: (BuildContext ctxt, index) {
                return Padding(
                  child: Container(
                    child: ListTile(
                      leading: Text("${index + 1}"),
                      title: Text(itemNameList[searchIndices[index]]),
                      trailing: Column(
                        children: <Widget>[
                          Text(itemQuantityList[searchIndices[index]]),
                          Text(itemCategory[searchIndices[index]])
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      onTap: () {
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
                                        width:
                                            MediaQuery.of(ct).size.width * 0.6,
                                      )),
                                      Row(
                                        children: <Widget>[
                                          FlatButton(
                                            child: Text(
                                              "Done",
                                              style: TextStyle(
                                                  color: kPrimaryColor),
                                            ),
                                            onPressed: () {
                                              if (qControl.text != '') {
                                                Navigator.pop(ct, true);
                                              }
                                            },
                                          ),
                                          FlatButton(
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: kPrimaryColor),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(ct, false);
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
                                  itemQuantityList[searchIndices[index]] =
                                      qControl.text;
                                });
                              }
                            });
                          } else if (choice == 1) {
                            showDialog(
                                context: context,
                                builder: (BuildContext c) {
                                  return AlertDialog(
                                    title: Text(
                                        "Are you sure you want to delete this item?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          "Yes",
                                          style:
                                              TextStyle(color: kPrimaryColor),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(c, true);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text(
                                          "No",
                                          style:
                                              TextStyle(color: kPrimaryColor),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(c, false);
                                        },
                                      )
                                    ],
                                  );
                                }).then((pop) {
                              if (pop) {
                                setState(() {
                                  itemNameList.removeAt(searchIndices[index]);
                                  itemQuantityList
                                      .removeAt(searchIndices[index]);
                                  itemCategory.removeAt(searchIndices[index]);
                                  searchIndices.removeAt(index);
                                });
                              }
                            });
                          }
                        });
                      },
                    ),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.005),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            searchController.text = '';
          });
          showDialog(
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
                                            MediaQuery.of(c).size.width * 0.03),
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
                                            MediaQuery.of(c).size.width * 0.03),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
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
                            child: Text(selectedOption == null
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
                                  Navigator.pop(c, true);
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
            if (pop == true) {
              listKey.currentState.insertItem(itemNameList.length);
              itemCategory.add(selectedOption);
              itemNameList.add(itemName.text);
              itemQuantityList.add(itemQuantity.text);
            }
            selectedOption = null;
            itemName.text = '';
            itemQuantity.text = '';
          });
        },
        backgroundColor: kPrimaryColor,
      ),
      appBar: AppBar(
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
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02),
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
