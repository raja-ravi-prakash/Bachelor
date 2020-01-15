import 'package:bachelor/Controls/Maps.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Host extends StatefulWidget {

  var _scrollController,_scaffoldKey;

  Host(this._scrollController,this._scaffoldKey);

  @override
  HostData createState() => HostData(_scrollController,_scaffoldKey);
}

class HostData extends State<Host>{

  var _controller;

  GlobalKey<ScaffoldState> _scaffoldKey;

  HostData(this._controller,this._scaffoldKey);

  Future getData() async {

    var firestore = Firestore.instance;

    QuerySnapshot qn = await firestore.collection('hosts')
    .orderBy('Name',descending: false)
        .getDocuments();

    return qn.documents;
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
                    controller: _controller,
                    itemCount: snapshot.data.length,
                    itemBuilder: (_,index){
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(Icons.map,color: Colors.blue,),
                              onPressed: (){
                                double latitude = snapshot.data[index].data['latitude'];
                                double longitude = snapshot.data[index].data['longitude'];

                                if(snapshot.data[index].data['Name'] != '{End Of Host}')
                                  MapUtils.openMap(latitude, longitude);
                                else
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.white,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text('End Of List',style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    )
                                  );
                              },
                            ),
                            onTap: (){
                              if(snapshot.data[index].data['Name'] != '{End Of Host}')
                              _scaffoldKey
                              .currentState.showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.white,
                                    content: Text(snapshot.data[index].data['Address'],
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 1000),
                                  )
                              );
                            },
                            title: Text(snapshot.data[index].data['Name'],
                              style: TextStyle(
                                fontFamily: 'Oswald',
                                  color:Colors.black ,
                                  fontSize: 20
                              ),
                            ),
                            subtitle: Text(
                                'Contact : '+snapshot.data[index].data['PhoneNumber'],
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
