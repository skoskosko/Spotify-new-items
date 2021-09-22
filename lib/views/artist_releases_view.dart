import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotifynewitems/api_names.dart';
import 'package:spotifynewitems/components/song_list_action_buttons.dart';
import 'package:spotifynewitems/utils/song_operations.dart';
import 'package:spotifynewitems/utils/spotify_oauth2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as Http;
import 'dart:collection';

class ArtistReleases extends StatefulWidget {
  final String artistId;
  final String artistName;
  final String artistPageUri;
  static const String id = "artist_releases";

  ArtistReleases({Key key, @required this.artistId, this.artistName, this.artistPageUri}): super(key: key);

  @override
  ArtistReleaseState createState() => ArtistReleaseState();
}

class ArtistReleaseState extends State<ArtistReleases> {
  List<dynamic> _artistItems = new List();
  final myController = TextEditingController();
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Artist View'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(""),
              Text(
              widget.artistName,
              style: Theme.of(context).textTheme.headline5,
              ),
              OutlineButton(
                child: Text(
                    'Artist page on Spotify'
                ),
                onPressed: () {
                  openUriInSpotify(widget.artistPageUri);
                },
              ),
              RaisedButton(
                onPressed: () async {
                  final DateTime picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101));
                  if (picked != null && picked != selectedDate)
                    setState(() {
                      selectedDate = picked;
                    });
                },
                child: Text(
                  "Selected date: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blue)
                ),
                color: Colors.black54,

              ),
              OutlineButton(
                child: Text("Refresh"),
                onPressed: refresh,
              ),
              new Expanded(
                child: _buildSongList(),
              )
            ]
          )
        )
    );
  }

  void openUriInSpotify(String uri) async {
    if ( await canLaunch(uri) ) {
      await launch(uri);
    }
    else {
      throw 'Could not launch uri: $uri';
    }
  }

  Widget _buildSongList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _artistItems.length,
        itemBuilder: (BuildContext context, int index) {
          String songName = _artistItems[index]["name"];
          String songUri = _artistItems[index]["uri"];
          return ListTile(
              title: Text(
                songName,
                style: TextStyle(fontSize: 20),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget> [
                  openInSpotifyIcon(songUri),
                  playIcon(songUri),
                  addToQueueIcon(songUri)
                ]
              ),
          );
        }
    );
  }

  void refresh() {
    _artistItems = new List();
    getArtistSongs();
  }

  void getArtistSongs() async {
    var songNames = new Set();
    var response = jsonDecode((await oAuth2Helper.get(ApiUrls.artistAlbums(widget.artistId, "0"))).body);
    for ( dynamic album in response["items"] ) {
      if (album["release_date_precision"] == "day") {
        var releaseDate = DateTime.parse(album["release_date"]);
        if (releaseDate != null && releaseDate.isAfter(selectedDate)) {
          var albumSongs = jsonDecode((await oAuth2Helper.get(ApiUrls.albumTracks(album["id"]))).body);
          for (dynamic song in albumSongs["items"]) {
            if (!songNames.contains(song["name"])) {
              songNames.add(song["name"]);
              _artistItems.add({
                "name": song["name"],
                "uri": song["uri"],
                "artist": widget.artistName,
                "releaseDate": releaseDate,
              });
            }
          }
        }
      }
    }
    setState(() {

    });
  }

  void play(String trackUri) async {
    var token = await oAuth2Helper.getTokenFromStorage();
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Authorization', () => 'Bearer ${token.accessToken}');
    Http.put(ApiUrls.play,
      headers: headers,
      body: jsonEncode(
          {
            "uris": [
              trackUri
            ],
          }),
    );
  }

  @override
  initState() {
    super.initState();
    getArtistSongs();
  }
}