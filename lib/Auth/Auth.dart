import 'dart:developer';
import 'package:bachelor/Components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Auth extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return AuthState();
  }
}

class AuthState extends State<Auth> with SingleTickerProviderStateMixin{

  var _phoneNumber;
  var parentContext;
  var sheet;
  String _smsCode;
  String _hostName;
  String _message='';
  var _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final _phoneNumberKey = GlobalKey<FormState>();

  ///animation controllers
  AnimationController _controller;
  Animation<double> _animation;


  void _signInWithPhoneNumber() async {

    //loading thing in bottom
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: LinearProgressIndicator(
        backgroundColor: Colors.redAccent,
      ),
      backgroundColor: Colors.white,
      duration: Duration(days: 365),
    ));


    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _smsCode,
    );


    Components.user = (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();

    assert(Components.user.uid == currentUser.uid);

    setState(() {
      if (Components.user != null) {

        _message = 'Auth: Successfully signed in, uid: ' + Components.user.uid;
        _checkUser();

        log(_message);


      } else {
        _message = 'Auth: sign in failed';
        log(_message);
        _scaffoldKey.currentState.hideCurrentSnackBar();

        //signIN Failed
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("SignIn Failed",style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.white,
          duration: Duration(days: 365),
        ));

      }
    });
  }

  ///check if user exists in out database or not
  _checkUser()async{
    await Firestore.instance.
      document('users/'+Components.user.phoneNumber)
        .get()
        .then((snapshot){

          //checking user
          _scaffoldKey.currentState.hideCurrentSnackBar();

          if(snapshot.exists)
            //old user
            Components.parent.getState();

          else
            //new user baby
            _newUserBaby();

    });
  }

  ///wrapping a dialog for our new user
  _newUserBaby(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: parentContext,
        builder: (sheetContext){
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              children: <Widget>[

                //title
                ListTile(
                  title: Text('Sign UP',style: TextStyle(fontWeight: FontWeight.bold),),
                ),

                Divider(),

                //text field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _nameKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        autovalidate: true,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        cursorColor: Colors.redAccent,
                        decoration: InputDecoration(
                          hintText: 'Your Sweet Name Please..',
                        ),
                        validator: (value){
                          if(value.isNotEmpty) {
                            if(_hostName.length <5)
                              return 'Name should have atleast 5 letters long.';
                            return null;
                          }
                          return 'Dude! Seriously.';
                        },
                        onChanged: (value){
                          _hostName = value;
                        },
                      ),
                    ),
                  ),
                ),

                //the mighty OK button
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: (){

                      //the infinity loading thing in the bottom
                      if (_nameKey.currentState.validate()) {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: LinearProgressIndicator(
                            backgroundColor: Colors.redAccent,
                          ),
                          backgroundColor: Colors.white,
                          duration: Duration(days: 365),
                        ));
                        Navigator.pop(sheetContext);
                        _createUser();
                      }

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

  //creating a new bitch
  _createUser()async{
    await Firestore.instance
        .document('users/'+Components.user.phoneNumber)
        .setData({
          'Hosts':0,
          'Name':_hostName,
          'Organizations':0
    }).then((value){
      _scaffoldKey.currentState.hideCurrentSnackBar();

      //thing thing is over now let's go
      Components.parent.getState();
    });
  }


  void _verifyPhoneNumber() async {

    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {

      Components.user = (await _auth.signInWithCredential(phoneAuthCredential)).user;
      setState(() {

        //autoVerification thing
        _message = 'Auth: Received phone auth credential: $phoneAuthCredential';
        log("phone verification "+_message);
        _checkUser();

        if(Components.user != null) {
          Navigator.of(context).pop();
          Components.parent.getState();
        }

      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
        'Auth: Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
        log(_message);

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("SignIn Failed",style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 5),

          //never giveUp Try Again Button
          action: SnackBarAction(
            label: 'Try Again',
            onPressed: (){
              Components.parent.getState();
            },
          ),

        ));
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {

      setState(() {
        _scaffoldKey.currentState.hideCurrentSnackBar();
      });

      //code is on it's way
      log('Auth: code sent');
      showDialog();
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91"+_phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  showDialog(){

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: parentContext,
        builder: (sheetContext){
          sheet = sheetContext;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              children: <Widget>[

                //title
                ListTile(
                  title: Text('Enter Otp',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Divider(),

                //textField for otp
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _otpKey,
                    child: TextFormField(
                      autovalidate: true,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      cursorColor: Colors.redAccent,
                      decoration: InputDecoration(
                        hintText: 'Enter Otp',
                      ),
                      validator: (value){
                        if(_smsCode == null)
                          return null;
                        else if(value.isEmpty)
                          return 'Just type the number.';
                        else if(_smsCode.length != 6)
                          return 'Length should be 6.';
                        return null;
                      },
                      onChanged: (value){
                        _smsCode = value;
                      },
                    ),
                  ),
                ),

                //the mighty OK button
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: (){
                      if (_otpKey.currentState.validate() && _smsCode.length == 6) {
                        Navigator.pop(sheetContext);
                        _signInWithPhoneNumber();
                      }
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
  void initState() {

    //signIn card animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2)
    );

    //the card animation property
    _animation = Tween(

      begin: 0.0,
      end: 1.0,

    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut
    ));

    log('Auth: animation start');
    _controller.forward();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    parentContext = context;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.redAccent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: AnimatedBuilder(
              animation: _animation,
              child: Card(
                elevation: 20,
                child: Wrap(
                  children: <Widget>[

                    ///Heading
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20,bottom: 50),
                        child: Text('Login',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                      ),
                    ),

                    ///PhoneNumber Field
                    Padding(
                      padding: const EdgeInsets.only(left: 50,right: 50,bottom: 20),
                      child: Form(
                        key: _phoneNumberKey,
                        child: TextFormField(
                          autovalidate: true,
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            _phoneNumber = value;
                          },
                          validator: (value){
                           if(_phoneNumber == null)
                             return null;
                           if(value.isNotEmpty)
                             if(_phoneNumber.length ==10)
                               return null ;

                             return 'Unsupported Format.';
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone,color: Colors.grey,),
                            border: OutlineInputBorder(),
                            hintText: 'Phone Number',
                            contentPadding: EdgeInsets.only(left: 10,right: 10)
                          ),
                        ),
                      ),
                    ),

                    ///Actions
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: FlatButton(
                          color: Colors.redAccent,
                          onPressed: (){
                            if(_phoneNumberKey.currentState.validate()) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: LinearProgressIndicator(
                                  backgroundColor: Colors.redAccent,
                                ),
                                backgroundColor: Colors.white,
                                duration: Duration(days: 365),
                              ));
                              _verifyPhoneNumber();
                            }
                            _otpKey.currentState.reset();
                          },
                          child: Text('Login',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),


                  ],
                ),
              ),
              builder: (animatedContext,child){
                print(_animation.value);
                return Transform.scale(
                    scale: _animation.value,
                    child: child,
                );
              },
            ),
          ),
        ),
      );
    //);
  }
}