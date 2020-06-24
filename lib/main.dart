
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as httpClient;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:spotifynewitems/api_names.dart';
import 'package:spotifynewitems/spotify_oauth2.dart';

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
  //Not required anymore String _token;
  RootJson _suggestions = new RootJson(item: new Albums(items: [new Album(artist: "", name: "")]));
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final Set<String> _saved = Set<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMusic();
  }

  void backToPreviousPage() async {
    Navigator.of(context, rootNavigator: true).pop(context);
  }

  RootJson parseMusic(String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();

    return  RootJson.fromJson(parsed);
  }

  void getMusic() async {
    var responseBody = await oAuth2Helper.get(ApiUrls.newReleases);
    setState(() {
      if ( responseBody.statusCode == 200 ) {
        _suggestions = parseMusic(responseBody.body);
        print(_suggestions.item);
      }
      else
        print(responseBody.body);
    });
}

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Startup Name Generator',
      theme: Theme.of(context),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Spotify new releases'),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            FlatButton(
              child: Text("Back to main"),
              onPressed: backToPreviousPage,
            ),
            FlatButton(
              child: Text("Get Music!"),
              onPressed: getMusic,
            ),
            _buildList(),
          ]
        ),
      ),
    );
  }

  Widget _buildList() {

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _suggestions.item.items.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(_suggestions.item.items[index].name, _suggestions.item.items[index].artist);
        },
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
         physics: ClampingScrollPhysics(),
        );
  }


  Widget _buildRow(String name, String artist) {
    final bool alreadySaved = _saved.contains(name);
    return ListTile(
      title: Text(
        name,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(name);
          } else {
            _saved.add(name);
          }
        });
      },
    );
  }

}

class RootJson {

  Albums item;
  RootJson({this.item});

  factory RootJson.fromJson(Map<String, dynamic> json) {
    // print("root");
    // print(json);
    return RootJson(
      item: Albums.fromJson(json["albums"]),
    );
  }

}

class Albums {

  List<Album> items;

  Albums({this.items});

  factory Albums.fromJson(Map<String, dynamic> dat) {
    // print("albums");
    //print(dat);
    var list = dat['items'] as List;
    // final parsed = json.decode(dat["items"]).cast<Album>();
    List<Album> imagesList = list.map((i) => Album.fromJson(i)).toList();
    return Albums(
      items: imagesList,
      // List<Album>.from(json["items"]),
    );
  }
}

class Album {
  String artist;
  String name;

  Album({this.artist, this.name});

  factory Album.fromJson(Map<String, dynamic> json) {
    //print("album");
    //print(json);
    return Album(
      artist: json["artist"] as String,
      name: json["name"] as String,
    );
  }
}