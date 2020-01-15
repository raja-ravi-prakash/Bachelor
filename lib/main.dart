import 'package:bachelor/Auth/Auth.dart';
import 'package:bachelor/Screen/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


main()=>runApp(MyApp());

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {

    return MyAppState();
  }
}

class MyAppState extends State<MyApp>{

  int i=0;

  bool isSigned = false;
  Widget _state = CircularProgressIndicator();

  getState()async{

    i = i+1;
    print('get State called $i');

    await FirebaseAuth.instance.currentUser()
        .then((user){
          if(user == null)
            setState(() {
              _state = Auth(this);
            });
          else
            setState(() {
              _state = LinkToHome(this,user.phoneNumber);
            });
    });

  }



  @override
  void initState() {

    getState();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.redAccent,
        accentColor: Colors.white
      ),
        home: _state,
    );
  }
}