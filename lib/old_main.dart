import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      //home: AuthScreen(),
      home: HomeScreen(),
      // home: NamePairList(),
      // home: LayoutWidget(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void authenticate() async {
    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
      url:
      "https://accounts.spotify.com/authorize?client_id=1d0c8fe4b89c4f37b8f4019a2282df1c&redirect_uri=spotifynewitems:/&response_type=token",
      callbackUrlScheme: "spotifynewitems",
    );

// Extract token from resulting url
    final token = Uri.parse(result);
    String at = token.fragment;
    at = "http://website/index.html?$at"; // Just for easy persing
    var accesstoken = Uri.parse(at).queryParameters['access_token'];
    print('token');
    print(accesstoken);

  }



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Spotify new releases'),
        ),
        body: Center(
          child: FlatButton(
            child: Text("Authenticate!"),
            onPressed: authenticate,
          ),
        ),
      ),
    );
  }

}