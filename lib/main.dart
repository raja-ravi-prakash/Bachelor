import 'dart:developer';
import 'package:bachelor/Auth/Auth.dart';
import 'package:bachelor/Components.dart';
import 'package:bachelor/Screen/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///this class is the main one which decides if user logged in or not
///if not it routes to a login page i.e Auth()
///if user is logged in it routes to home page Home()


void main(){

  runApp(MyApp());

}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: MaterialMyApp(),
    );
  }
}

class MaterialMyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {

    return MyAppState();
  }
}

class MyAppState extends State<MaterialMyApp>{

  ///Just a log on how many times this method is called
  int i=0;

  ///at initial stage it is a loading page
  Widget _state = CircularProgressIndicator();

  ///this method checks whether user logged in or not
  getState()async{

    //printing hoy many times this method is called == how many times user signed in
    i = i+1;
    log('main: get State called $i');

    //this returns a future of the user
    await FirebaseAuth.instance.currentUser()
        .then((user){

          //if user object is null user is not logged in
          if(user == null)

            //changing the widget state to Auth()
            setState(() {
              log('main: user is not logged in setting authentication state to SignIN');
              print(user);
              log('$user');
              _state = Auth();
            });

          //if user logged in user object is not null
          else
            //changing the widget state to Home()
            setState(() {
              log('main: user logged in saving user Object');
              Components.user = user;
              _state = Home();
            });
    });

  }



  @override
  void initState() {

    //calling getState to check user state
    log('main: checking user state');
    getState();

    log('main: saving parent object');
    Components.parent = this;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    log('main: getting dimensions of devise');
    //saving screenHeight and screenWidth
    Components.screenHeight = MediaQuery.of(context).size.height;
    Components.screenWidth = MediaQuery.of(context).size.width;
    print('screenHeight: '+ Components.screenHeight.toString());
    print('screenWidth: '+Components.screenWidth.toString());

    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.redAccent,
        accentColor: Colors.white,
        cursorColor: Colors.redAccent,
        splashColor: Colors.redAccent,
      ),
        home: _state,
    );
  }
}