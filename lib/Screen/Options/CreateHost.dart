import 'package:bachelor/DataBase/CreateDocument.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CreateHost extends StatelessWidget {
  String _name;
  String _address;
  String _phoneNumber;
  String _hostNumber;
  String _state;
  String _postalCode;
  String _city;
  String _street;
  double latitude,longitude;
  String instance,_message ='Please make sure your location is as the location of the host.';

  CreateHost(this._hostNumber);

  var _details;

  final _finalKey = GlobalKey<FormState>();

  _showDialog(contextt){

    showDialog(
        context: contextt,
      builder: (context)=>AlertDialog(
        title: Text('Note'),
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
              ),),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Continue'),
            onPressed: (){
              Navigator.of(context).pop();
              _saveData(contextt);
            },
          ),
        ],
      )
    );

  }

  _saveData(context) async{
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
        _do(context);
      }
      return location;
    });

  }

  _do(context){
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
      path: '/hosts/',
      phoneNumber: _hostNumber
    ).push();
    Navigator.of(context).pop(_details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green,Colors.blue]
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            child: Form(
              key: _finalKey,
              child: Wrap(
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
                  Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40,bottom: 10),
                    child: TextFormField(
                      onChanged: (text)=> _name = text,
                      validator: (text){
                        if(text.isEmpty)
                          return 'Field is Empty';
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'Name'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                    child: TextFormField(
                      onChanged: (text) => _phoneNumber =text,
                      validator: (text){
                        if(text.isEmpty)
                          return 'Field is Empty';
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'Phone Number'
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40,right: 40,top: 20,bottom: 10),
                    child: Text('Address:',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                    child: TextFormField(
                      onChanged: (text)=> _street = text,
                      validator: (text){
                        if(text.isEmpty)
                          return 'Field is Empty';
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'Street'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                    child: TextFormField(
                      onChanged: (text)=> _city = text,
                      validator: (text){
                        if(text.isEmpty)
                          return 'Field is Empty';
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'City'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                    child: TextFormField(
                      onChanged: (text)=> _state = text,
                      validator: (text){
                        if(text.isEmpty)
                          return 'Field is Empty';
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'State'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40,top: 10,bottom: 10),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (text)=> _postalCode = text,
                      validator: (text){
                        if(text.isEmpty)
                          return 'Field is Empty';
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'Postal Code'
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FlatButton(
                      color: Colors.deepPurple,
                      child: Text('Done',style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        if(_finalKey.currentState.validate())
                          _showDialog(context);
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10),),
                ],
              ),
            ),
          ),
        )
      )
    );
  }
}

