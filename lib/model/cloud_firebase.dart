
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore_service {
  int itemmnumber = 1;
  static final Firestore db = Firestore.instance;

  void Add_Item_Data(String ItemName, String ItemQuantity) {
    db.collection('Shop 1').document('Item $itemmnumber')
        .setData({ 'Item Name': ItemName, 'Item Quantity': ItemQuantity});
    itemmnumber++;
  }

  Future<List<String>> Get_Item_Name() async {
    List<String> itemname=new List();
    print("start");
    QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    querySnapshot.documents.forEach((element) {
        itemname.add(element["Item Name"]);
    });
    print(itemname);
    return itemname;
  }

  Future<List> Get_Item_Quantity() async {
    List itemquantity=new List();
    print("start");
    QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    querySnapshot.documents.forEach((element) {
      itemquantity.add(element["Item Quantity"]);
    });
    print(itemquantity);
    return itemquantity;
  }
}