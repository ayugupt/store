import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/pages/profilepage.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  //bool showMore = false;
  List<bool> showMore = new List<bool>();

  Tween<double> tween;

  int orders = 6;
  List<AnimationController> controllers = new List<AnimationController>();
  List<Animation> animations = new List<Animation>();

  @override
  void initState() {
    tween = new Tween<double>(begin: 0, end: 0.1);

    for (int i = 0; i < orders; i++) {
      showMore.add(false);
    }

    for (int i = 0; i < orders; i++) {
      controllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)));
    }

    for (int i = 0; i < orders; i++) {
      animations.add(tween.animate(controllers[i]));
    }
    for (int i = 0; i < animations.length; i++) {
      animations[i].addListener(() {
        setState(() {});
      });
    }

    super.initState();
  }

  @override 
  void dispose(){
    for(int i = 0; i < controllers.length; i++){
      controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("Orders"),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.tune,
                ),
                onPressed: () {},
              )
            ],
            floating: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return orderCard(index);
            }, childCount: orders),
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              color: kPrimaryColor,
            ),
            ListTile(
                leading: Icon(Icons.person),
                title: Text("My Shop Profile"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return Profile();
                  }));
                })
          ],
        ),
      ),
    );
  }

  Widget orderCard(int index) {
    return Column(children: <Widget>[
      InkWell(
        child: Align(
          child: Container(
            child: Card(
              child: Stack(children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      child: Align(
                        child: Text("Customer Name"),
                        alignment: Alignment.centerLeft,
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                    Padding(
                      child: Align(
                        child: Text(
                          "Address",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                    Padding(
                      child: Align(
                          child: Text(
                            "Order Status",
                          ),
                          alignment: Alignment.centerLeft),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03,
                          left: MediaQuery.of(context).size.width * 0.02),
                    ),
                  ],
                ),
                Align(
                  child: IconButton(
                    icon: Icon(!showMore[index]
                        ? Icons.arrow_drop_down
                        : Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        showMore[index] = !showMore[index];
                        if (showMore[index] == true) {
                          controllers[index].forward();
                        } else {
                          controllers[index].reverse();
                        }
                      });
                    },
                  ),
                  alignment: Alignment.bottomRight,
                )
              ]),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
          ),
        ),
      ),
      showMore[index] || animations[index].value != 0
          ? Align(
              child: Container(
                color: Colors.grey[100],
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height *
                    animations[index].value,
                child: showMore[index] && controllers[index].isCompleted
                    ? Column(children: <Widget>[
                        Padding(
                          child: Align(
                            child: Text("Total Items"),
                            alignment: Alignment.centerLeft,
                          ),
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01,
                              left: MediaQuery.of(context).size.width * 0.02),
                        ),
                        Padding(
                          child: Align(
                            child: Text("Total Price"),
                            alignment: Alignment.centerLeft,
                          ),
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01,
                              left: MediaQuery.of(context).size.width * 0.02),
                        )
                      ])
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ),
            )
          : SizedBox(
              height: 0,
              width: 0,
            ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.01,
      )
    ]);
  }
}
