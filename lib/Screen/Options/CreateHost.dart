import 'package:bachelor/Components.dart';
import 'package:bachelor/DataBase/CreateDocument.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CreateHost extends StatelessWidget {

  var _scaffoldKey = GlobalKey<ScaffoldState>() ;
  var parentContext ;
  String _name;
  String _address;
  String _state;
  String _postalCode;
  String _city;
  String _street;
  double latitude,longitude;
  String instance,_message ='Do you have all the legal authority of this host?';

  var _details;

  final _finalKey = GlobalKey<FormState>();

  _showDialog(){

    //alert dialog
    showDialog(
        context: parentContext,
      builder: (context)=>AlertDialog(
        title: Text('Warning!',style: TextStyle(fontWeight: FontWeight.bold),),
        content: Text(_message,style: TextStyle(fontSize: 15),),
        actions: <Widget>[
          FlatButton(
            child: Text('No',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
              ),),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Yes, Continue'),
            onPressed: (){
              Navigator.of(context).pop();
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: LinearProgressIndicator(
                  backgroundColor: Colors.redAccent,
                ),
                backgroundColor: Colors.white,
                duration: Duration(days: 365),
              ));
              _saveData();
            },
          ),
        ],
      )

    );

  }

  _saveData() async{
    _address = _street +",\n"+_city+",\n"+_state+", "+_postalCode;

    var date = DateTime.now();

    instance =date.year.toString()+"-" + date.month.toString()+"-";
    instance+= date.day.toString()+"_"+date.hour.toString()+"-";
    instance+=date.minute.toString()+"-"+date.second.toString();

    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((location) {
      if (location != null) {
        latitude = location.latitude;
        longitude = location.longitude;
        _do();
      }

    });

  }

  _do(){
    var _phoneNumber = Components.user.phoneNumber;
    _details = {
      'Name':_name,
      'Address':_address,
      'PhoneNumber':_phoneNumber,
      'Instance':instance,
      'latitude':latitude,
      'longitude':longitude
    };
    CreateDocument(
      data: _details,
      path: 'users/$_phoneNumber/hosts/',
    ).push();
    Navigator.of(parentContext).pop(_details);
  }

  @override
  Widget build(BuildContext context) {

    parentContext = context;
    return Scaffold(
      key: _scaffoldKey,

      ///Form
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green,Colors.blue]
          )
        ),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
          child: Form(
            key: _finalKey,
            child: ListView(
              children: <Widget>[
                AppBar(
                  centerTitle: true,
                  title: const Text('Create Host',
                    style: TextStyle(color: Colors.black),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  iconTheme: IconThemeData(color: Colors.black),
                ),

                //name
                Padding(
                  padding: const EdgeInsets.only(left: 40,right: 40,bottom: 10),
                  child: TextFormField(
                    onChanged: (text)=> _name = text,
                    validator: (text){
                      if(text.isEmpty)
                        return 'what should we call this thing';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Name'
                    ),
                  ),
                ),

                //Address
                Padding(
                  padding: EdgeInsets.only(left: 40,right: 40,top: 20,bottom: 10),
                  child: Text('Address:',
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,),
                  ),
                ),

                //street
                Padding(
                  padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                  child: TextFormField(
                    onChanged: (text)=> _street = text,
                    validator: (text){
                      if(text.isEmpty)
                        return 'Are you from mars!';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Street'
                    ),
                  ),
                ),

                //city
                Padding(
                  padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                  child: TextFormField(
                    onChanged: (text)=> _city = text,
                    validator: (text){
                      if(text.isEmpty)
                        return 'Are you from mars!';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'City'
                    ),
                  ),
                ),

                //state
                Padding(
                  padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                  child: TextFormField(
                    onChanged: (text)=> _state = text,
                    validator: (text){
                      if(text.isEmpty)
                        return 'Are you from mars!';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'State'
                    ),
                  ),
                ),

                //Postal Code
                Padding(
                  padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (text)=> _postalCode = text,
                    validator: (text){
                      if(text.isEmpty)
                        return 'just a number!!';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Postal Code'
                    ),
                  ),
                ),


                SizedBox(height: 40,),


                //ok this is done
                Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                    color: Colors.deepPurple,
                    child: Text('Done',style: TextStyle(color: Colors.white),),
                    onPressed: (){
                      if(_finalKey.currentState.validate())
                        _showDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}

