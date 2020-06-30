import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotifynewitems/spotify_oauth2.dart';
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
              Text(
              widget.artistName,
              style: Theme.of(context).textTheme.headline5,
              ),
              OutlineButton(
                child: Text(
                    'Artist page on Spotify'
                ),
                onPressed: artistPage,
              ),
              OutlineButton(
                child: Text('Press for test song, CHOOCHOO'),
                onPressed: playTestSong,
              )
            ]
          )
        )
    );
  }

  void artistPage() async {
    if ( await canLaunch(widget.artistPageUri) ) {
      await launch(widget.artistPageUri);
    }
    else {
      throw 'Could not launch uri: ${widget.artistPageUri}';
    }
  }

  void playTestSong() async {
    var token = await oAuth2Helper.getTokenFromStorage();
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Authorization', () => 'Bearer ${token.accessToken}');
    Http.put('https://api.spotify.com/v1/me/player/play',
        headers: headers,
        body: jsonEncode(
                {
                  "uris":
                  [
                    "spotify:track:5fB7KNzDNtTLWAa6D2zcBJ"
                  ]
                }),
    );
  }

  @override
  initState() {
    super.initState();
  }
}