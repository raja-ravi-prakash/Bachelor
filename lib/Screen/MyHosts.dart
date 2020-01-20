import 'dart:developer';
import 'package:bachelor/Components.dart';
import 'package:bachelor/Controls/Maps.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MyHosts extends StatefulWidget {
  var _scrollController, _scaffoldKey,parentContext;

  MyHosts(this._scrollController, this._scaffoldKey, this.parentContext);

  @override
  MyHostsData createState() => MyHostsData(_scrollController, _scaffoldKey,parentContext);
}

class MyHostsData extends State<MyHosts> {
  ScrollController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey;
  var parentContext ;

  MyHostsData(this._controller, this._scaffoldKey,this.parentContext);
  
  _deleteHost(String id)async{

    var referenceId = 'users/'+Components.user.phoneNumber+'/hosts/'+id;

    await Firestore.instance
        .document(referenceId)
        .updateData({'enabled':false})
        .then((value){
          setState(() {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Deleted!',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              duration: Duration(seconds: 1),
            ));
            log('Document: $id deleted');
          });
    });
  }

  _hostAction(data){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: parentContext,
        builder: (sheetContext){
          return Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Wrap(
              children: <Widget>[

                //title
                ListTile(
                  title: Text(data['Name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  subtitle: Text(data['Instance']),
                  trailing: InkWell(
                    child: Icon(Icons.delete,color: Colors.redAccent,),
                    onTap: (){
                      _deleteHost(data['Instance']);
                      Navigator.pop(context);
                    },
                  )
                ),
                Divider(),

                //MyHosts
                ListTile(
                  onTap: (){},
                  onLongPress: (){},
                  title: Text('Latitude',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),
                  leading: Icon(Icons.location_on,color: Colors.redAccent,),
                  trailing: Text(data['latitude'].toString()),
                ),

                //Organization Calls
                ListTile(
                  onTap: (){},
                  onLongPress: (){},
                  title: Text('Longitude',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),
                  leading: Icon(Icons.poll,color: Colors.redAccent,),
                  trailing: Text(data['longitude'].toString()),
                ),

              ],
            ),
          );
        }
    );
  }

  Future getData() async {
    //getting Hosts data from FireBase
    var fireStore = Firestore.instance;

    QuerySnapshot qn = await fireStore
        .collection('users')
        .document(Components.user.phoneNumber)
        .collection('hosts')
        .orderBy('enabled', descending: true)
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
                        Text('My Hosts',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
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
                      color: snapshot.data[index].data['enabled'] ? Colors.white:Colors.grey[200],
                      elevation: snapshot.data[index].data['enabled'] ? 2 : 0,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ListTile(
                          enabled: snapshot.data[index].data['enabled'],
                          //action
                          trailing: IconButton(
                            icon: Icon(
                              Icons.map,
                              color: snapshot.data[index].data['enabled'] ?Colors.blue : Colors.grey,
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
                            if (snapshot.data[index].data['Name'] != '{End Of Host}')
                              _hostAction(snapshot.data[index]);

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
