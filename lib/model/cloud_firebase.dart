import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

class Firestore_service {
  String Username;
  static final Firestore db = Firestore.instance;

  Future<String> getusername() async{
   final FirebaseUser user = await _auth.currentUser();
   final FirebaseUser loggedInUser = user;
   return user.displayName;
  }


  Future<void> Add_Item_Data(String ItemName, String ItemQuantity,
      String ItemCategory, String ItemPrice, String ItemExpiry) async {
    Username=await getusername();
    //QuerySnapshot querySnapshot = await db.collection("Shop 1").getDocuments();
    //int itemnumber=querySnapshot.documents.length+1;
   db.collection(Username).document().setData({
      'Item Name': ItemName,
      'Item Quantity': ItemQuantity,
      "Item Category": ItemCategory,
      "Item Price": ItemPrice,
      "Item Expiry": ItemExpiry,
    });
  }

  void Delete_Item(String ClickedItemName) async {
    Username=await getusername();
    db.collection(Username).document(ClickedItemName).delete();
  }

  Future<void> Update_Item(

      String ClickedItemName, String Updates_Quantity) async {
    Username=await getusername();
    await db
        .collection(Username)
        .document(ClickedItemName)
        .updateData({"Item Quantity": Updates_Quantity});
  }
   Future<String> SaveImage(File image,String Itemname) async {
     Username=await getusername();
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
