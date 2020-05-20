import 'package:flutter/material.dart';

import 'dart:io';

class ItemData extends StatelessWidget {
  String name, quantity, category, expiry, price, image;

  ItemData(this.name, this.quantity, this.category, this.expiry, this.price,
      this.image);

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.05;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
            child: Container(
              child: Image.network(image),
            ),
            tag: "item",
          ),
          Padding(
            child: Align(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Text(name,
                        style:
                            TextStyle(color: Colors.white, fontSize: fontSize)),
                    Text("Rs." + price,
                        style:
                            TextStyle(color: Colors.white, fontSize: fontSize)),
                    Text(expiry,
                        style:
                            TextStyle(color: Colors.white, fontSize: fontSize)),
                    Text(category,
                        style:
                            TextStyle(color: Colors.white, fontSize: fontSize)),
                    Text(quantity + " units",
                        style:
                            TextStyle(color: Colors.white, fontSize: fontSize))
                  ],
                ),
                color: Colors.black.withOpacity(0.5),
              ),
              alignment: Alignment.bottomCenter,
            ),
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.8),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
