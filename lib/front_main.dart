import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_web_auth/flutter_web_auth.dart';
//import 'package:http/http.dart' as http;
import 'package:spotifynewitems/api_names.dart';
import 'package:spotifynewitems/main.dart';
import 'package:spotifynewitems/spotify_oauth2.dart';
import 'package:spotifynewitems/views/followed_artist_list.dart';

void main() {
  runApp(FrontScreen());
}

class FrontScreen extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FrontPage(title: 'Spotify New Items'),
      routes: {
        'artists': (context) => ArtistList()
      },
    );
  }
}

class FrontPage extends StatefulWidget {
  FrontPage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  String _textField;
  bool _authenticated = false;

  @override
  void initState() {
    // TODO: implement initState
    _textField = 'Welcome';
  }

  void _authenticate() async {
    var result = await oAuth2Helper.getToken();
    var resp = await oAuth2Helper.get(ApiUrls.ownFollowedPlaylists);
    setState(() {
      if ( result.error == null
          && result.httpStatusCode == 200
          && result.accessToken != null ) {
        _textField = 'Authenticated';
        _authenticated = true;
      }
      print(result);

      var ree = jsonDecode(resp.body);
      //'spotify:playlist:5olgk8MU3qwzf5wnwjfT2w';
      int i = 0;
    });
  }
  void _disconnect() async {
    var res = await oAuth2Helper.disconnect();
    setState(() {
      if ( res.httpStatusCode == 200 ) {
        print('Disconnected, token invalidated');
      }
    });
    sleep(Duration(seconds: 2));
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    //Exit is not recommended on iOS devices, exit will break out of debugging mode
    if( Theme.of(context).platform == TargetPlatform.android ) { exit(0); }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
        onWillPop: _showMyDialog,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),
          body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$_textField',
                  style: Theme.of(context).textTheme.headline4,
                ),
                OutlineButton(
                  child: Text("Press this to move to Eskos view"),
                  onPressed: () => {
                    _authenticated ? Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp())) : null
                  },
                ),
                OutlineButton(
                  child: Text("Press this to move to Artist view"),
                  onPressed: () => {
                    _authenticated ? Navigator.pushNamed(context, 'artists') : null
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: _buildActionButtons(context), // This trailing comma makes auto-formatting nicer for build methods.
        )
    );
  }

  Future<bool> _showMyDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to close this application?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                _disconnect();
                return true;
              },
            )
          ],
        ) ?? false;
      },
    );
  }

  Widget _buildArtistList() {}

  Widget _buildActionButtons(context) {
    return new Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Spacer(
            flex: 3,
          ),
          Expanded(
            flex: 3,
            child: FloatingActionButton(
              heroTag: "authentication_btn",
              onPressed: _authenticate,
              child: /*Icon(Icons.check_circle)*/Text('Login'),
            ),
          ),
          Expanded(
            flex: 3,
            child: FloatingActionButton(
              heroTag: "exit_btn",
              onPressed: _showMyDialog,
              child: /*Icon(Icons.cancel)*/ Text('Exit'),
            ),
          ),
          Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }
}
