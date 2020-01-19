import 'dart:developer';
import 'package:bachelor/Components.dart';
import 'package:bachelor/DataBase/CreateDocument.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class Organization extends StatelessWidget {
  var _scaffoldKey;
  var parentContext;
  String _value;
  double latitude, longitude;

  Organization(this._scaffoldKey, this.parentContext);

  Future getData() async {
    //getting Organization data from FireStore
    var fireStore = Firestore.instance;

    QuerySnapshot qn =
        await fireStore.collection('organization').getDocuments();

    return qn.documents;
  }

  _doTheThing(name, number, email, template) {
    //an intent, calling help!! (FireBase DocumentReference)
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((location) {
      if (location != null) {
        latitude = location.latitude;
        longitude = location.longitude;
        _createAndExit(name, number, email, template);
      } else
        log("Organization: i don't know what to do now");
    });
  }

  _createAndExit(name, number, email, template) async {
    var phoneNumber = Components.user.phoneNumber;
    CreateDocument(data: {
      'latitude': latitude,
      'longitude': longitude,
      'Name': _value,
      'hostNumber': phoneNumber,
      'handlerNumber': number,
      'handler': name,
      'Email': email,
      'template': template
    }, path: 'users/$phoneNumber/organization/')
        .request(_scaffoldKey);
  }

  showDialog(name, image, mainFrame, number, email, template) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: parentContext,
        builder: (sheetContext) {
          return Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Wrap(
              children: <Widget>[
                //title
                ListTile(
                  onTap: () {
                    launch(mainFrame);
                  },
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(image),
                  ),
                  title: Text(
                    '$name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Instance'),
                ),

                Divider(),

                //name
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: true,
                    cursorColor: Colors.redAccent,
                    decoration: InputDecoration(
                      hintText: 'Name',
                    ),
                    validator: (value) {
                      if (value.isEmpty)
                        return 'what sould we call this thing!';
                      return null;
                    },
                    onChanged: (value) {
                      _value = value;
                    },
                  ),
                ),

                //the mighty ok button
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: () {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: LinearProgressIndicator(
                          backgroundColor: Colors.redAccent,
                        ),
                        backgroundColor: Colors.white,
                        duration: Duration(days: 365),
                      ));
                      Navigator.pop(sheetContext);
                      _doTheThing(name, number, email, template);
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  _launchChrome(link) async {
    if (await canLaunch(link))
      await launch(link);
    else
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          "Cannot Open Browser",
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        duration: Duration(days: 365),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),

      //we are getting things from internet so a future builder
      child: FutureBuilder(
          future: getData(),

          //iterating through document snapshots (like a for loop)
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              );
            } else {
              //building a list view items through iteration
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(5),

                        //content
                        child: ListTile(
                          //image
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                                snapshot.data[index].data['image']),
                          ),

                          //intent action
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  snapshot.data[index].data['Name'],
                                  snapshot.data[index].data['image'],
                                  snapshot.data[index].data['mainFrame'],
                                  snapshot.data[index].data['Contact Number'],
                                  snapshot.data[index].data['Email'],
                                  snapshot.data[index].data['template']);
                            },
                            icon: Icon(
                              Icons.message,
                              color: Colors.blue,
                            ),
                          ),

                          //details of the intent
                          onTap: () {
                            _launchChrome(
                                snapshot.data[index].data['mainFrame']);
                          },

                          //title
                          title: Text(
                            snapshot.data[index].data['Name'],
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),

                          //number
                          subtitle: Text(
                            'Contact Number: ' +
                                snapshot.data[index].data['Contact Number'],
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
