import 'dart:developer';
import 'package:bachelor/Components.dart';
import 'package:bachelor/Screen/MyHosts.dart';
import 'package:bachelor/Screen/Options/CreateHost.dart';
import 'package:bachelor/Screen/Options/Host.dart';
import 'package:bachelor/Screen/Options/Organization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



class Home extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {

    return HomeState();
  }
}

class HomeState extends State<Home> with TickerProviderStateMixin {

  //class dependent variables
  BuildContext parentContext;
  Widget _homeState;

  //widget conditions
  bool _menuState = false, upDirection,_gesture = true;

  //host details from fireBase
  String  _hostName,_hostNumber;
  int _hostNoHosts,_hostNoOrg;

  //scaffold key for snackBar
  var _scaffoldKey;

  //required animations
  Animation<double> button;
  Animation<Offset> bottomBar,appBar,menuBar;

  //required controllers for animations
  AnimationController _appBarController,_menuBarController,_bottomBarController;
  ScrollController _scrollController;


  @override
  void initState() {

    //initialization of elements
    _hostNumber = Components.user.phoneNumber;
    _scaffoldKey = GlobalKey<ScaffoldState>();


    //scrollController
    _scrollController = ScrollController()
      ..addListener(() {
        upDirection = _scrollController.position.userScrollDirection == ScrollDirection.forward;

        if(upDirection)
          log('Home: scrolling Up');
        else
          log('Home: scrolling Down');

        //if this is true someone is scrolling up or someone is scrolling down
        if (upDirection != true)
          //reversing the bottomBar animation
          _bottomBarController.reverse();
        else
          //playing the bottomBar animation
          _bottomBarController.forward();

      });


    ///controllers
    //AppBar controller
    _appBarController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this
    );

    //bottomBar controller
    _bottomBarController = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this
    );

    //menuBar Controller
    _menuBarController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this
    );

    ///animations
    //menuBar animation
    menuBar = Tween(
      begin: Offset(0,-220),
      end: Offset(0,50)
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _menuBarController
      )
    );

    //appBar animation
    appBar = Tween(
      begin: Offset(0,-80),
      end: Offset(0,0)
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _appBarController,
      )
    );

    //floating action button animation
    button = Tween(
      begin: 0.0,
      end: 1.0
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _appBarController
      )
    );

    //bottomBar animation
    bottomBar = Tween(
        begin: Offset(0,Components.screenHeight),
        end: Offset(0,Components.screenHeight-100)
        ).animate(
           CurvedAnimation(
              parent: _bottomBarController,
              curve: Curves.ease
         )
    );

    //getting host info
    pullData();

      log('Home: Animations Started');
     _appBarController.forward().orCancel;
     _bottomBarController.forward().orCancel;
     _homeState = Host(_scrollController,_scaffoldKey);

    super.initState();

  }


  //getting host's data from dataBase
  pullData()async{

    log('Home: pullData');

    await Firestore.instance
    .document('users/'+_hostNumber)
    .get()
    .then((snapshot){
      _hostName = snapshot['Name'];
      _hostNoOrg = snapshot['Organizations'];
      _hostNoHosts = snapshot['Hosts'];
      log('Name: $_hostName, Hosts: $_hostNoHosts, Organizations: $_hostNoOrg');
    });

  }

  logOut()async{

    log('Home: user Logged out');
    await FirebaseAuth.instance.signOut();
    Components.parent.getState();

  }

  @override
  void dispose() {
    _appBarController.dispose();
    _bottomBarController.dispose();
    _menuBarController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    parentContext = context;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: (){
          setState(() {
            _gesture = false;
            print('Double Tap');
            log('Home: MyHosts Loaded');
            _homeState = MyHosts(_scrollController,_scaffoldKey,parentContext);
          });
        },
        onHorizontalDragUpdate: (details){
          if(details.primaryDelta >0 && !_gesture){
            setState(() {
              _gesture = !_gesture;
              print('Dragged Left');
              log('Home: Hosts reloaded');
              pullData();
              _homeState = Host(_scrollController,_scaffoldKey);
            });
          }
          else if(details.primaryDelta <0 && _gesture){
            setState(() {
              _gesture = !_gesture;
              print('Dragged Right');
              pullData();
              log('Home: Organization reloaded');
              _homeState = Organization(_scaffoldKey,parentContext);
            });
          }
        },
        child: Stack(
          children: <Widget>[

            ///body
            Container(
              margin: EdgeInsets.only(top: 60),
              color: Colors.white,
              child: _homeState,
            ),

            ///Menu Bar
            mainMenuBar(),

            ///App Bar
            mainAppBar(),

            ///Bottom App Bar
            bottomAppBar(),

            ///Floating Action Button
            hostActionButton(),

          ],
        ),
      ),
    );
  }

  ///floating action button layer
  hostActionButton(){
    return AnimatedBuilder(
        child: Padding(
          padding: const EdgeInsets.only(bottom :70),
          child: Align(
            alignment: Alignment.bottomCenter,
            //floating action button
            child: FloatingActionButton(
              tooltip: 'Create Host',
              splashColor: Colors.white,
              backgroundColor: Colors.redAccent,
              elevation: 5,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>CreateHost(),
                    )
                );
              },
              child: Icon(Icons.add,color: Colors.white,),
            ),
          ),
        ),
        animation: button,
        builder: (context,child){
          return Transform.scale(
            scale: button.value,
            child: child,
          );
        }
    );
  }

  ///menu bar layer
  mainMenuBar(){
    return AnimatedBuilder(
      builder: (context,child){
        return Transform.translate(
          offset: menuBar.value,
          child: child,
        );
      },
      animation: menuBar,
      child: Wrap(
        children: <Widget>[

          //custom created menuBar
          Container(
            margin: EdgeInsets.only(left: 10,right: 10),

            //components in menuBar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 30,child: Container(child: Text(''),)),

                //profile
                FlatButton.icon(
                  onPressed: (){
                    log('Home: Profile');
                    showProfileMenu();
                  },
                  label: Text('Profile'),
                  icon: Icon(Icons.account_circle),
                ),

                //Logout
                FlatButton.icon(
                  onPressed: (){
                    log('Home: Logout');
                    logOut();
                  },
                  icon: Icon(Icons.backspace),
                  label: Text('LogOut',style: TextStyle(fontWeight: FontWeight.bold),),
                ),


                Padding(
                  padding: const EdgeInsets.only(left: 30,right: 30),
                  child: Divider(color: Colors.grey,thickness: 1,),
                ),

                //FeedBack
                FlatButton.icon(
                  icon: Icon(Icons.feedback),
                  onPressed: (){log('Home: FeedBack');},
                  label: Text('FeedBack'),
                ),

                //Help & Support
                FlatButton.icon(
                  icon: Icon(Icons.help),
                  onPressed: (){log('Home: Help & Support');},
                  label: Text('Help & Support'),
                ),


              ],
            ),

            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10
                  )
                ],
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))
            ),
          ),
        ],
      ),
    );
  }

  ///AppBar Layer
  mainAppBar(){

    return AnimatedBuilder(
      animation: appBar,

      //appbar within a container
      child: Container(
        height: 80,
        child: AppBar(
          centerTitle: true,
          title: Text("Hew n'Grub",style: TextStyle(color: Colors.white,fontFamily: DefaultTextStyle.of(context).style.fontFamily),),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30),bottomLeft: Radius.circular(30))
          ),

          backgroundColor: Colors.redAccent,

          //menu icon
          leading: IconButton(
            onPressed: (){
              if(!_menuState) {
                log('Home: menuBar open');
                _menuBarController.forward();
                _menuState = true;
              }
              else {
                log("Home: menuBar closed");
                _menuBarController.reverse();
                _menuState = false;
              }
            },
            icon: Icon(Icons.menu,color: Colors.white,),
          ),
        ),
      ),


      builder: (context,child){
        return Transform.translate(
          offset: appBar.value,
          child: child,
        );
      },
    );
  }


  ///bottomAppBar layer
  bottomAppBar(){
    return AnimatedBuilder(
      builder: (context,child){
        return Transform.translate(
          offset: bottomBar.value,
          child: child,
        );
      },
      animation: bottomBar,

      //bottomAppBar
      child: Container(
        margin: EdgeInsets.only(left: 10,right: 10),
        padding: EdgeInsets.all(5),

        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(6)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10
              )
            ]
        ),

        //components in bottomBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            //Hosts
            FlatButton(
              onPressed: (){
                setState(() {
                  log('Home: Hosts reloaded');
                  pullData();
                  _homeState = Host(_scrollController,_scaffoldKey);
                });
              },
              child: Text('Hosts'),
            ),

            //Organization
            FlatButton(
              onPressed: (){
                setState(() {
                  pullData();
                  log('Home: Organization reloaded');
                  _homeState = Organization(_scaffoldKey,parentContext);
                });
              },
              child: Text('Organization'),
            )


          ],
        ),


      ),
    );
  }

  ///Profile Menu
 showProfileMenu(){
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
                  title: Text('$_hostName',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  subtitle: Text('$_hostNumber'),
                ),
                Divider(),

                //MyHosts
                ListTile(
                  onTap: (){
                    setState(() {
                      _menuBarController.reverse();
                      _menuState = !_menuState;
                      _homeState = MyHosts(_scrollController,_scaffoldKey,parentContext);
                      Navigator.of(context).pop();
                    });
                  },
                  onLongPress: (){},
                  title: Text('My Hosts',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),
                  leading: Icon(Icons.location_on,color: Colors.redAccent,),
                  trailing: Text('$_hostNoHosts'),
                ),

                //Organization Calls
                ListTile(
                  onTap: (){},
                  onLongPress: (){},
                  title: Text('Organization Calls',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),
                  leading: Icon(Icons.poll,color: Colors.redAccent,),
                  trailing: Text('$_hostNoOrg'),
                ),
              ],
            ),
          );
        }
    );
 }

}