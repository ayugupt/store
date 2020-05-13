import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Firestore_service {
  static final Firestore db = Firestore.instance;

  Future<void> Add_Item_Data(String ItemName, String ItemQuantity,String ItemCategory) async {
    //QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    //int itemnumber=querySnapshot.documents.length+1;
    db.collection('Shop Id').document()
        .setData({'Item Name': ItemName, 'Item Quantity': ItemQuantity,"Item Category":ItemCategory});
  }

  void Delete_Item(String ClickedItemName) async{
    db.collection("Shop Id").document(ClickedItemName).delete();
  }

  void Update_Item(String ClickedItemName,String Updates_Quantity) async{
    db.collection("Shop Id").document(ClickedItemName).updateData({"Item Quantity":Updates_Quantity});
  }
  /*Future<List> Get_Item_Name() async {
    List<String> itemname=new List();
    print("start");
    QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    querySnapshot.documents.forEach((element) {
        itemname.add(element["Item Name"]);
    });
    print(itemname);
    return itemname.toList();
  }


  Future<List> Get_Item_Quantity() async {
    List itemquantity=new List();
    print("start");
    QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    querySnapshot.documents.forEach((element) {
      itemquantity.add(element["Item Quantity"]);
    });
    print(itemquantity);
    return itemquantity.toList();
  }*/



}
