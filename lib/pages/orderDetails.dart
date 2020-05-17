import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  Map<String, String> details;
  OrderDetails(this.details);

  OrderDetailsState createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails> {
  Color headingColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    double leftPadding = MediaQuery.of(context).size.width * 0.03;
    double headingTextSize = MediaQuery.of(context).size.width * 0.05;
    double addressDetailsFontSize = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              child: Text(
                "Items",
                style:
                    TextStyle(fontSize: headingTextSize, color: headingColor),
              ),
              padding: EdgeInsets.only(
                  left: leftPadding,
                  top: MediaQuery.of(context).size.height * 0.05),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: leftPadding,
                  top: MediaQuery.of(context).size.height * 0.02,
                  right: leftPadding),
              child: Container(
                //height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width - 2 * leftPadding,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(widget.details["itemName"] +
                            " x " +
                            widget.details["quantity"]),
                        Text(widget.details["totalPrice"])
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    )
                  ],
                  //crossAxisAlignment: CrossAxisAlignment.start,
                ),
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              ),
            ),
            Padding(
              child: Text(
                "Address",
                style:
                    TextStyle(fontSize: headingTextSize, color: headingColor),
              ),
              padding: EdgeInsets.only(
                  left: leftPadding,
                  top: MediaQuery.of(context).size.height * 0.05),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: leftPadding,
                  top: MediaQuery.of(context).size.height * 0.02,
                  right: leftPadding),
              child: Container(
                //height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width - 2 * leftPadding,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.details["name"],
                      style: TextStyle(fontSize: addressDetailsFontSize),
                    ),
                    Padding(
                      child: Text(
                        widget.details["address"] != null
                            ? widget.details["address"] +
                                "\n" +
                                widget.details["pinCode"]
                            : "Address\n" + widget.details["pinCode"],
                        style: TextStyle(fontSize: addressDetailsFontSize),
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03),
                    ),
                    Padding(
                      child: Text(
                        widget.details["number"] != null
                            ? widget.details["number"]
                            : "Phone Number",
                        style: TextStyle(fontSize: addressDetailsFontSize),
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03),
                    ),
                    Padding(
                      child: Text(
                        widget.details["email"],
                        style: TextStyle(fontSize: addressDetailsFontSize),
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03,
                    top: MediaQuery.of(context).size.height * 0.03,
                    bottom: MediaQuery.of(context).size.height * 0.03),
              ),
            )
          ],
          //crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Order Details"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
