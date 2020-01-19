import 'package:bachelor/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

///this is just a kind of a storage class to store objects of the user

class Components {

  //user object
  static FirebaseUser user ;

  //MediaQuery Data
  static double screenHeight ;
  static double screenWidth ;

  //parent object
  static MyAppState parent ;
}