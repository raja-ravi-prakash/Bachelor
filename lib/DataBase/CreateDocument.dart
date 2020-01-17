import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
       print('\npush data failed : ');
       print(e.toString());
     }
  }

  _updateHostData()async{
    try {
      await dataBase
              .document('users/'+phoneNumber)
              .get()
              .then((snapshot){
               var dataInstant = {
                 'Hosts':snapshot['Hosts']+1,
                 'Organizations':snapshot['Organizations'],
                 'Name':snapshot['Name']
               };
                _setHostData(dataInstant);
          });
    } catch (e) {
      print('\nupdate Host Data Failed : ');
      print(e.toString());
    }
  }
  
  _setHostData(dataInstant)async{
     
     try {
       await dataBase
                .document('users/'+phoneNumber)
                .updateData(dataInstant);
     } catch (e) {
       print('\nset Host Data failed : ');
       print(e.toString());
     }
     
  }

  _thirdPartyServer(key)async{
     var url = data['template'];
     String hostNumber = '%2B'+data['hostNumber'].substring(0);
     String handlerNumber = '%2B'+data['handlerNumber'].substring(0);
     url = url+'hostNumber='+hostNumber;
     url = url +'&handlerNumber=%2B'+handlerNumber;
     url = url +'&name='+data['Name'];
     url = url +'&latitude='+data['latitude'].toString();
     url = url +'&longitude='+data['longitude'].toString();

     print(url);

     Response response = await get(url);

     if(response.statusCode == 200)
       key.currentState.showSnackBar(SnackBar(
         behavior: SnackBarBehavior.floating,
         content: Text('Message Sent Successfully',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
         backgroundColor: Colors.white,
         duration: Duration(seconds: 2),
       ));
     else
       key.currentState.showSnackBar(SnackBar(
         behavior: SnackBarBehavior.floating,
         content: Text('Message Sent Failed',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold)),
         backgroundColor: Colors.white,
         duration: Duration(seconds: 2),
       ));

  }

  void request(GlobalKey<ScaffoldState> key)async {
     
    var date = DateTime.now();
    String instance =date.year.toString()+"_" + date.month.toString()+"_";
    instance+= date.day.toString()+"_"+date.hour.toString()+"_";
    instance+=date.minute.toString()+"_"+date.second.toString();

    try {
      await dataBase
          .collection('users')
          .document(phoneNumber)
          .collection('organization')
          .document(phoneNumber + "**" + instance)
          .setData(data).then((value) {
        print('Data Sended');
        key.currentState.hideCurrentSnackBar();
        _thirdPartyServer(key);
        key.currentState.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Data Written Successfully',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 1),
        ));
      });
    }catch(e){
      print('\nrequest failed : ');
      print(e.toString());
    }
    
  }
}