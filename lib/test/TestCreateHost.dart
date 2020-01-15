import 'package:bachelor/test/TestPaint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class TestCreateHost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {

    return TestCreateHostState();
  }
}

class TestCreateHostState extends State<TestCreateHost>{

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.center,
        child: CustomPaint(
          painter: TestPainter(),
          child: Container(
            height: height/2,
            width: width/2,
            child: Column(
              children: <Widget>[
                Container(
                  height: height/4,
                  width: width/2,
                  color: Colors.redAccent,
                ),
                Container(
                  height: height/4,
                  width: width/2,
                  color: Colors.blueAccent,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}