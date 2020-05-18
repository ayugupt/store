import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Login/login_screen.dart';
import 'package:flutter_auth/pages/pdfViewer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderDetails extends StatefulWidget {
  Map<String, String> details;
  OrderDetails(this.details);

  OrderDetailsState createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails> {
  Color headingColor = Colors.grey;

  Future<String> checkLoggedIn () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    print(email);
    return email;
  }

  _generatePdfAndView(context) async {
    final pdfLib.Document pdf = pdfLib.Document(deflate: zlib.encode);

    pdf.addPage(pdfLib.MultiPage(
      build: (context) => [
        pdfLib.Column(
          mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
          children: [
            pdfLib.Padding(
              padding: pdfLib.EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: pdfLib.Text(
                  'Items',
                  style: pdfLib.TextStyle(
                    fontSize: 50.0,
                    color: PdfColors.grey,
                  )
              ),
            ),
            pdfLib.Padding(
                padding: pdfLib.EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: pdfLib.Container(
                  child: pdfLib.Column(
                      children: [
                        pdfLib.Row(
                            mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
                            children: [
                              pdfLib.Text(
                                  widget.details["itemName"] +
                                      " x " +
                                      widget.details["quantity"],
                                  style: pdfLib.TextStyle(
                                    fontSize: 25.0,
                                  )
                              ),
                              pdfLib.Text(
                                  widget.details['totalPrice'],
                                  style: pdfLib.TextStyle(
                                    fontSize: 25.0,
                                  )
                              ),
                            ]
                        )
                      ]
                  )
              ),
            ),
            pdfLib.Padding(
                padding: pdfLib.EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: pdfLib.Text(
                  'Address',
                  style: pdfLib.TextStyle(
                    fontSize: 50.0,
                    color: PdfColors.grey,
                  )
              )
            ),
            pdfLib.Padding(
                padding: pdfLib.EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: pdfLib.Container(
                child: pdfLib.Column(
                  crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                  children: [
                    pdfLib.Text(
                        widget.details["name"],
                        style: pdfLib.TextStyle(
                          fontSize: 25.0,
                        )
                    ),
                    pdfLib.Text(
                        widget.details["address"] != null
                            ? widget.details["address"] +
                            "\n" +
                            widget.details["pinCode"]
                            : "Address\n" + widget.details["pinCode"],
                        style: pdfLib.TextStyle(
                          fontSize: 25.0,
                        )
                    ),
                    pdfLib.Text(
                        widget.details["number"] != null
                            ? widget.details["number"]
                            : "Phone Number",
                        style: pdfLib.TextStyle(
                          fontSize: 25.0,
                        )
                    ),
                    pdfLib.Text(
                        widget.details["email"],
                        style: pdfLib.TextStyle(
                          fontSize: 25.0,
                        )
                    )
                  ],
                ),
              ),
            ),
          ]
        )]
    ));

    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/sample.pdf';
    final File file = File(path);
    await file.writeAsBytes(pdf.save());
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
    //Navigator.of(context).push(MaterialPageRoute(
      //builder: (_) => PdfViewerPage(path: path),
    //));
  }

  @override
  void initState() {
    super.initState();
    if(checkLoggedIn() == null){
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ));
    }
  }

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
            onPressed: () {
              _generatePdfAndView(context);
            },
          )
        ],
      ),
    );
  }
}
