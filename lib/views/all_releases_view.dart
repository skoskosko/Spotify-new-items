import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotifynewitems/api_names.dart';
import 'package:spotifynewitems/spotify_oauth2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as Http;
import 'dart:collection';

class AllFollowedArtistReleases extends StatefulWidget {
  final List<dynamic> artistList;
  final List<dynamic> songList;
  static const String id = "artist_releases";

  AllFollowedArtistReleases({Key key, @required this.artistList, @required this.songList}): super(key: key);

  @override
  AllFollowedArtistReleasesState createState() => AllFollowedArtistReleasesState();
}

class AllFollowedArtistReleasesState extends State<AllFollowedArtistReleases> {
  var songList = new List();
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 7));
  DateTime previousDate;
  var pushed = false;
  var loading = false;
  var loadingText = "Loading";
  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, this.songList);
        return true;
      },
        child: Scaffold(
        appBar: AppBar(
          title: Text('All releases'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Text(""),

                  RaisedButton(
                    onPressed: () async {
                      final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101));
                      if (picked != null && picked != selectedDate)
                        setState(() {
                          previousDate = selectedDate;
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
                    child: Icon(Icons.refresh),
                    onPressed: refresh,
                    shape: CircleBorder(),
                  ),

                  Text(this.loading ? this.loadingText : ""),

                  new Expanded(
                    child: _buildSongList(),
                  )

                ]
            )
        )
    )
    );
  }

  void refresh() {
    if ( previousDate != selectedDate ) {
      setState(() {
        this.loading = true;
      });
      if ( previousDate != null && previousDate.isBefore(selectedDate) && this.songList.isNotEmpty ) {
        updateSongList();
      }
      else {
        previousDate = selectedDate;
        this.songList = new List();
        getItems();
      }
    }
  }

  void updateSongList() {
    var newSongList = new List();
    for ( dynamic song in widget.songList ) {
      if (song["releaseDate"].isAfter(selectedDate)) {
        newSongList.add(song);
      }
    }
    setState(() {
      this.songList = newSongList;
      this.loading = false;
      previousDate = selectedDate;
    });
  }

  Widget _buildSongList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: this.songList.length,
        itemBuilder: (BuildContext context, int index) {
          var currentSong = this.songList[index];
          return ListTile(

            title: Text(
              currentSong["name"],
              style: TextStyle(fontSize: 20),
            ),

            subtitle: Text("${currentSong["artist"]} (${currentSong["releaseDate"].day}.${currentSong["releaseDate"].month}.${currentSong["releaseDate"].year})"),

            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget> [

                  GestureDetector(
                    child: Icon(
                      Icons.open_in_new,
                      color: Colors.red,
                      size: 40,
                    ),
                    onTap: () {
                      openUriInSpotify(currentSong["uri"]);
                    },
                  ),

                  GestureDetector(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: this.pushed ? Colors.red : Colors.blue,
                      size: 40,
                    ),
                    onTap: () {
                      play(currentSong["uri"]);
                    },
                  ),

                ]
            ),
          );
        }
    );
  }

  void getItems() async {
    //TODO: Make this faster
    var albumNames = new Set();
    var songNames = new Set();
    for( dynamic artist in widget.artistList ) {
      var response = jsonDecode((await oAuth2Helper.get(ApiUrls.artistAlbums(artist["id"], "0"))).body);
      print("checking artist ${artist["name"]}");
      for ( dynamic album in response["items"] ) {
        if ( album["release_date_precision"] == "day" ) {
          var releaseDate = DateTime.parse(album["release_date"]);
          if ( releaseDate != null && releaseDate.isAfter(selectedDate) && !albumNames.contains(album["name"]) ) {
            var albumSongs = jsonDecode((await oAuth2Helper.get(ApiUrls.albumTracks(album["id"]))).body);
            for ( dynamic song in albumSongs["items"] ) {
              if ( !songNames.contains(song["name"]) ) {
                songNames.add(song["name"]);
                this.songList.add({
                  "name": song["name"],
                  "uri": song["uri"],
                  "artist": artist["name"],
                  "releaseDate": releaseDate,
                });
              }
            }
          }
        }
      }
    }
    setState(() {
      this.loading = false;
    });
  }

  //TODO: Move play and openUri to common place, they are used in artistView also
  void play(String trackUri) async {
    var token = await oAuth2Helper.getTokenFromStorage();
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Authorization', () => 'Bearer ${token.accessToken}');
    var result = await Http.put(ApiUrls.play,
      headers: headers,
      body: jsonEncode(
          {
            "uris": [
              trackUri
            ],
          }),
    );
    print("Play status code: ${result.statusCode}");
  }

  void openUriInSpotify(String uri) async {
    if ( await canLaunch(uri) ) {
      await launch(uri);
    }
    else {
      throw 'Could not launch uri: $uri';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.songList = widget.songList;
  }
}