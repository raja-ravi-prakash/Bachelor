import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateDocument {
  Map<String,dynamic> data;
  String path,phoneNumber;
  final dataBase= Firestore.instance;

  CreateDocument({
    @required this.data,
    @required this.path,
    this.phoneNumber
    }):assert(data!=null),
      assert(path!=null);


   void push()async{

     var date = DateTime.now();
     String instance =date.year.toString()+"_" + date.month.toString()+"_";
     instance+= date.day.toString()+"_"+date.hour.toString()+"_";
     instance+=date.minute.toString()+"_"+date.second.toString();
     try {
       await dataBase
       .collection('users')
       .document(phoneNumber)
       .collection('hosts')
           .document(instance)
           .setData(data)
           .then((value){
              print('Data Sended');
              _updateHostData();
       });
       await dataBase
           .collection('hosts')
           .document(instance)
           .setData(data)
           .then((value){
         print('Data Sended');
       });
     }catch(e){
       print(e.toString());
     }
  }

  _updateHostData()async{
    await dataBase
        .document('users/'+phoneNumber)
        .get()
        .then((snapshot){
         var dataInstant = {
           'PhoneNumber':snapshot['PhoneNumber'],
           'Hosts':snapshot['Hosts']+1,
           'Organizations':snapshot['Organizations'],
           'Name':snapshot['Name']
         };
          _setHostData(dataInstant);
    });
  }
  
  _setHostData(dataInstant)async{
     
     await dataBase
         .document('users/'+phoneNumber)
         .updateData(dataInstant);
     
  }

  void request(GlobalKey<ScaffoldState> key)async {
    var date = DateTime.now();
    String instance =date.year.toString()+"_" + date.month.toString()+"_";
    instance+= date.day.toString()+"_"+date.hour.toString()+"_";
    instance+=date.minute.toString()+"_"+date.second.toString();

    try {
      await dataBase
          .collection('users')
          .document(phoneNumber + "**" + instance)
          .setData(data).then((value) {
        print('Data Sended');
        key.currentState.showSnackBar(SnackBar(content: Text('Data Sended'),));
      });
    }catch(e){
      print(e.toString());
    }
  }
}