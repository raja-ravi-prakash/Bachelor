import 'package:bachelor/Controls/Maps.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Host extends StatefulWidget {
  var _scrollController, _scaffoldKey;

  Host(this._scrollController, this._scaffoldKey);

  @override
  HostData createState() => HostData(_scrollController, _scaffoldKey);
}

class HostData extends State<Host> {
  ScrollController _controller;

  GlobalKey<ScaffoldState> _scaffoldKey;

  HostData(this._controller, this._scaffoldKey);

  Future getData() async {
    //getting Hosts data from FireBase
    var fireStore = Firestore.instance;

    QuerySnapshot qn = await fireStore
        .collection('hosts')
        .orderBy('Name', descending: false)
        .getDocuments();

    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),

      //well we are getting things from internet so a future builder
      child: FutureBuilder(
          future: getData(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              //if still loading show progressBar
              return Align(
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Hosts',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Padding(padding: EdgeInsets.only(bottom :10,left: 150,right: 150)),
                        CircularProgressIndicator(
                          backgroundColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            else if(snapshot.data.length == 0){
              return Align(
                alignment: Alignment.center,
                child: Container(
                  height: 250,
                  width: 250,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                        'assets/emptyBox.gif'
                    ),
                  ),
                ),
              );
            }
            else {
              //building a list view items through iteration
              return ListView.builder(
                  controller: _controller,
                  itemCount: snapshot.data.length,

                  //iterating through document snapshots (like a for loop)
                  itemBuilder: (_, index) {
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ListTile(
                          //action
                          trailing: IconButton(
                            icon: Icon(
                              Icons.map,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              double latitude =
                                  snapshot.data[index].data['latitude'];
                              double longitude =
                                  snapshot.data[index].data['longitude'];

                              //on action event opens maps
                              if (snapshot.data[index].data['Name'] !=
                                  '{End Of Host}')
                                MapUtils.openMap(latitude, longitude);
                              else
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    backgroundColor: Colors.white,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'End Of List',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold),
                                    )));
                            },
                          ),

                          //onTap show's host's details
                          onTap: () {
                            if (snapshot.data[index].data['Name'] !=
                                '{End Of Host}')
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.white,
                                content: Text(
                                  snapshot.data[index].data['Address'],
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                                duration: Duration(milliseconds: 1000),
                              ));
                          },

                          //title of the host
                          title: Text(
                            snapshot.data[index].data['Name'],
                            style: TextStyle(
                                fontFamily: 'Oswald',
                                color: Colors.black,
                                fontSize: 20),
                          ),

                          //phoneNUmber
                          subtitle: Text(
                            'Contact : ' +
                                snapshot.data[index].data['PhoneNumber'],
                            style: TextStyle(color: Colors.black45),
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
