import 'package:bachelor/DataBase/CreateDocument.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Organization extends StatelessWidget {

  var _scaffoldKey;
  var parentContext;
  String _value;
  double latitude,longitude;

  Organization(this._scaffoldKey,this.parentContext);

  Future getData() async {

    var firestore = Firestore.instance;

    QuerySnapshot qn = await firestore.collection('organization')
        .getDocuments();

    return qn.documents;
  }

  _doTheThing(context,name){
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((location) {
      if (location != null) {
        latitude = location.latitude;
        longitude = location.longitude;
        _createAndExit(context,name);
      }
    });
  }

  _createAndExit(context,name)async{

    String _phoneNumber;

    await FirebaseAuth.instance.currentUser()
                  .then((user){
                    _phoneNumber = user.phoneNumber;
                    CreateDocument(
                        data: {
                          'latitude':latitude,
                          'longitude':longitude,
                          'Name':_value,
                          'Phone Number':_phoneNumber,
                          'handler':name
                        },
                        phoneNumber: _phoneNumber,
                        path: 'users'
                    ).request(_scaffoldKey);
                });
  }

  showDialog(name){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: parentContext,
        builder: (contextt){
          return Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.add_photo_alternate,size: 50,color: Colors.redAccent,),
                  title: Text('$name',style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text('Instance'),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: true,
                    cursorColor: Colors.redAccent,
                    decoration: InputDecoration(
                      hintText: 'Name',
                    ),
                    validator: (value){
                      if(value.isEmpty)
                        return 'Field is Empty!';
                      return null;
                    },
                    onChanged: (value){
                      _value = value;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: (){
                      _doTheThing(parentContext, name);
                    },
                    child: Text('Ok',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),),
                  ),
                )
              ],
            ),
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    return Container(
        padding: EdgeInsets.all(5),
        child: FutureBuilder(
            future: getData(),
            builder: (_ , snapshot){

              if(snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                );
              }else {

                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_,index){
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: ListTile(
                            trailing: IconButton(
                              onPressed: (){
                                  showDialog(snapshot.data[index].data['Name']);
                              },
                              icon: Icon(Icons.message,color: Colors.blue,),
                            ),
                            onTap: (){
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Email: '+snapshot.data[index].data['Email'],
                                  style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.white,
                              ));
                            },
                            title: Text(snapshot.data[index].data['Name'],
                              style: TextStyle(
                                  color:Colors.black ,
                                  fontSize: 20
                              ),
                            ),
                            subtitle: Text(
                              'Contact Number: '+snapshot.data[index].data['Contact Number'],
                              style: TextStyle(
                                  color: Colors.black45
                              ) ,
                            ),
                          ),
                        ),
                      );
                    });

              }

            }),
      );
  }
}