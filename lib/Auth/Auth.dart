import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Auth extends StatefulWidget {

  var parent;

  Auth(this.parent);
  @override
  State<StatefulWidget> createState() {

    return AuthState(parent);
  }
}

class AuthState extends State<Auth> with SingleTickerProviderStateMixin{

  var parent;
  var _phoneNumber;
  var parentContext;
  var _smsCode;
  var _hostName;
  static String _message='';
  var _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _controller;
  Animation<double> _animation;

  AuthState(this.parent);

  void _signInWithPhoneNumber() async {
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
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    _phoneNumber = currentUser.phoneNumber;
    setState(() {
      if (user != null) {
        _message = 'Successfully signed in, uid: ' + user.uid;
        _checkUser();
        print(_message);
        //parent.getState();
      } else {
        _message = 'Sign in failed';
      }
    });
  }

  _checkUser()async{
    await Firestore.instance.
      document('users/'+_phoneNumber)
        .get()
        .then((snapshot){
          _scaffoldKey.currentState.hideCurrentSnackBar();
          if(snapshot.exists)
            parent.getState();
          else
            _newUser();
    });
  }

  _newUser(){
    showModalBottomSheet(
        context: parentContext,
        builder: (sheetContext){
          return Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text('Sign UP',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    cursorColor: Colors.redAccent,
                    decoration: InputDecoration(
                      hintText: 'Your Sweet Name',
                    ),
                    validator: (value){
                      if(value.isEmpty)
                        return 'Field is Empty!';
                      return null;
                    },
                    onChanged: (value){
                      _hostName = value;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.pop(sheetContext);
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: LinearProgressIndicator(
                          backgroundColor: Colors.redAccent,
                        ),
                        backgroundColor: Colors.white,
                        duration: Duration(days: 365),
                      ));
                      _createUser();
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

  _createUser()async{
    await Firestore.instance
        .document('users/'+_phoneNumber)
        .setData({
          'Hosts':0,
          'Name':_hostName,
          'Organizations':0
    }).then((value){
      _scaffoldKey.currentState.hideCurrentSnackBar();
      parent.getState();
    });
  }

  void _verifyPhoneNumber() async {

    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = 'Received phone auth credential: $phoneAuthCredential';
        print("phone verification "+_message);
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
        'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        _scaffoldKey.currentState.hideCurrentSnackBar();
      });
      print('code sent');
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
        builder: (contextt){
          return Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text('Enter Otp',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    cursorColor: Colors.redAccent,
                    decoration: InputDecoration(
                      hintText: 'Enter Otp',
                    ),
                    validator: (value){
                      if(value.isEmpty)
                        return 'Field is Empty!';
                      return null;
                    },
                    onChanged: (value){
                      _smsCode = value;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.pop(contextt);
                      _signInWithPhoneNumber();
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

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2)
    );

    _animation = Tween(

      begin: 0.0,
      end: 1.0,

    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut
    ));

    _controller.forward();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    parentContext = context;

    return /*MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.redAccent,
        accentColor: Colors.white
      ),
      home:*/ Scaffold(
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
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          _phoneNumber = value;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone,color: Colors.grey,),
                          border: OutlineInputBorder(),
                          hintText: 'Phone Number',
                          contentPadding: EdgeInsets.only(left: 10,right: 10)
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
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: LinearProgressIndicator(
                                backgroundColor: Colors.redAccent,
                              ),
                              backgroundColor: Colors.white,
                              duration: Duration(days: 365),
                            ));
                            _verifyPhoneNumber();
                          },
                          child: Text('Login',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              builder: (contextt,child){
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