import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Firestore_service {
  String Username;
  FirebaseUser loggeduser;
  String UniqueiD;
  static final Firestore db = Firestore.instance;

  Future<FirebaseUser> getusername() async {
    final FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<void> Add_Item_Data(
      String ItemName,
      String ItemQuantity,
      String ItemCategory,
      String ItemPrice,
      String ItemExpiry,
      String ItemUrl) async {
    loggeduser = await getusername();
    Username = loggeduser.displayName;
    UniqueiD = loggeduser.uid;

    //QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    //int itemnumber=querySnapshot.documents.length+1;
    db.collection("Shopitems/$Username/$UniqueiD").document().setData({
      'Item Name': ItemName,
      'Item Quantity': ItemQuantity,
      "Item Category": ItemCategory,
      "Item Price": ItemPrice,
      "Item Expiry": ItemExpiry,
      "Item Image": ItemUrl
    });
  }

  void Delete_Item(String ClickedItemName) async {
    loggeduser = await getusername();
    Username = loggeduser.displayName;
    db
        .collection("Shopitems/$Username/$UniqueiD")
        .document(ClickedItemName)
        .delete();
  }

  Future<void> Update_Item(
      String ClickedItemName, String Updates_Quantity) async {
    loggeduser = await getusername();
    Username = loggeduser.displayName;
    await db
        .collection("Shopitems/$Username/$UniqueiD")
        .document(ClickedItemName)
        .updateData({"Item Quantity": Updates_Quantity});
  }

  Future<String> SaveImage(File image, String Itemname) async {
    loggeduser = await getusername();
    Username = loggeduser.displayName;
    StorageReference ref =
        FirebaseStorage.instance.ref().child("Image/$Username/$Itemname.jpg");

    StorageUploadTask uploadTask = ref.putFile(image);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = (await downloadUrl.ref.getDownloadURL());
    print(url);
    return url;
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
