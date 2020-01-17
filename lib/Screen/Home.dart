import 'package:bachelor/Screen/Options/CreateHost.dart';
import 'package:bachelor/Screen/Options/Host.dart';
import 'package:bachelor/Screen/Options/Organization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class LinkToHome extends StatelessWidget{

  var parent,number;

  LinkToHome(this.parent,this.number);

  @override
  Widget build(BuildContext context) {

    return Home(MediaQuery.of(context).size.height,MediaQuery.of(context).size.width,parent,number);
  }
}

class Home extends StatefulWidget{

  var _screenHeight,_screenWidth,parent,number;

  Home(this._screenHeight,this._screenWidth,this.parent,this.number);

  @override
  State<StatefulWidget> createState() {

    return HomeState(_screenHeight,_screenWidth,parent,number);
  }
}

class HomeState extends State<Home> with TickerProviderStateMixin {

  var parentContext,parent;

  bool _check = false,upDirection;

  var _homeState;
  
  var _hostName,_hostNumber;
  int _hostNoHosts,_hostNoOrg;

  var _scaffoldKey;

  Animation<double> button;
  Animation<Offset> bottomBar,appBar,menuBar;

  AnimationController _appBarController,_menuBarController,_bottomBarController;
  ScrollController _scrollController;
  double value=0;
  double screenHeight,screenWidth;

  HomeState(this.screenHeight,this.screenWidth,this.parent,this._hostNumber);

  @override
  void initState() {

    _scaffoldKey = GlobalKey<ScaffoldState>();

    _scrollController = ScrollController()
      ..addListener(() {
        upDirection = _scrollController.position.userScrollDirection == ScrollDirection.forward;

        if (upDirection != true)
          _bottomBarController.reverse();
        else
          _bottomBarController.forward();

        print(upDirection);


      });

    _appBarController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this
    );

    _bottomBarController = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this
    );

    _menuBarController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this
    );

    menuBar = Tween(
      begin: Offset(0,-220),
      end: Offset(0,50)
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _menuBarController
      )
    );

    appBar = Tween(
      begin: Offset(0,-80),
      end: Offset(0,0)
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _appBarController,
      )
    );

    button = Tween(
      begin: 0.0,
      end: 1.0
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _appBarController
      )
    );

    bottomBar = Tween(
        begin: Offset(0,screenHeight),
        end: Offset(0,screenHeight-100)
        ).animate(
           CurvedAnimation(
              parent: _bottomBarController,
              curve: Curves.ease
         )
    );

    pullData();

     _appBarController.forward().orCancel;
     _bottomBarController.forward().orCancel;

     _homeState = Host(_scrollController,_scaffoldKey);

    super.initState();

  }


  pullData()async{

    print("pullData");

    await Firestore.instance
    .document('users/'+_hostNumber)
    .get()
    .then((snapshot){
      _hostName = snapshot['Name'];
      _hostNoOrg = snapshot['Organizations'];
      _hostNoHosts = snapshot['Hosts'];
      print( _hostName +" : "+_hostNumber);
    });

  }

  logOut()async{

    await FirebaseAuth.instance.signOut();
    parent.getState();

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

    print(bottomBar.value);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
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
          createHostActionButton(),

          ///detect gestures
          /*GestureDetector(
            onVerticalDragEnd: (dragDetails){
              print('forward');
              _bottomBarController.forward();
            },
            onVerticalDragStart: (dragDetails){
              print('backward');
              _bottomBarController.reverse();
            },

            behavior: HitTestBehavior.deferToChild,
          ),*/
        ],
      ),
    );
  }

  createHostActionButton(){
    return AnimatedBuilder(
        child: Padding(
          padding: const EdgeInsets.only(bottom :70),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              tooltip: 'Create Host',
              splashColor: Colors.white,
              backgroundColor: Colors.redAccent,
              elevation: 5,
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>CreateHost(_hostNumber),
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
          Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 30,child: Container(child: Text(''),)),
                FlatButton.icon(
                  onPressed: (){
                    showProfileMenu(context);
                  },
                  label: Text('Profile'),
                  icon: Icon(Icons.account_circle),
                ),
                FlatButton.icon(
                  onPressed: (){
                    logOut();
                  },
                  icon: Icon(Icons.backspace),
                  label: Text('LogOut',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30,right: 30),
                  child: Divider(color: Colors.grey,thickness: 1,),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.feedback),
                  onPressed: (){},
                  label: Text('FeedBack'),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.help),
                  onPressed: (){},
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

  mainAppBar(){

    return AnimatedBuilder(
      animation: appBar,
      child: Container(
        height: 80,
        child: AppBar(
          centerTitle: true,
          title: Text("Hew n'Grub",style: TextStyle(color: Colors.white,fontFamily: DefaultTextStyle.of(context).style.fontFamily),),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30),bottomLeft: Radius.circular(30))
          ),
          backgroundColor: Colors.redAccent,
          leading: IconButton(
            onPressed: (){
              if(!_check) {
                _menuBarController.forward();
                _check = true;
              }
              else {
                _menuBarController.reverse();
                _check = false;
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

  bottomAppBar(){
    return AnimatedBuilder(
      builder: (context,child){
        return Transform.translate(
          offset: bottomBar.value,
          child: child,
        );
      },
      animation: bottomBar,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: (){
                setState(() {
                  pullData();
                  _homeState = Host(_scrollController,_scaffoldKey);
                });
              },
              child: Text('Hosts'),
            ),
            FlatButton(
              onPressed: (){
                setState(() {
                  pullData();
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

 showProfileMenu(context){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (contextt){
          return Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text('$_hostName',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  subtitle: Text('$_hostNumber'),
                ),
                Divider(),
                ListTile(
                  onTap: (){},
                  onLongPress: (){},
                  title: Text('My Hosts',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),
                  leading: Icon(Icons.location_on,color: Colors.redAccent,),
                  trailing: Text('$_hostNoHosts'),
                ),
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