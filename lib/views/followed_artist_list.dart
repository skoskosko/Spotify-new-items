import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:spotifynewitems/spotify_oauth2.dart';
import 'package:spotifynewitems/api_names.dart';
import 'package:spotifynewitems/views/artist_releases_view.dart';


class ArtistList extends StatefulWidget {
  static const String id = "artist_list";
  @override
  ArtistListState createState() => ArtistListState();
}

class ArtistListState extends State<ArtistList> {

  List<dynamic> _items = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist List'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
            'You are following ' + _items.length.toString() + ' artists',
            style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              'Select an artist to see releases separately, or press below to see newest from all followed artists',
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
            OutlineButton(
              child: Text("New releases from all followed artists"),
              onPressed: () => {
                print('all releases')//getArtists()
              },
            ),
            new Expanded(
                flex: 0,
                    child: new GridView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 1, mainAxisSpacing: 1, crossAxisSpacing: 1),
                        children: [
                          _artistGrid()
                        ],
                    )
            ),
          ]
        )
      )
    );
  }

  @override
  initState() {
    super.initState();
    getArtists();
  }

  Widget _artistGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _items.isNotEmpty? _items.length: 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0
      ),
      itemBuilder: (BuildContext context, int index) {
        var currentArtist = _items[index];
        return GestureDetector(
          onTap: () => {
            print(currentArtist['id']),
            Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistReleases(artistId: currentArtist['id'], artistName: currentArtist['name'], artistPageUri: currentArtist['uri'],)))
          },
          child: GridTile(
            child: currentArtist['images'].length > 0 ? Image.network(currentArtist['images'][0]['url']) : Image.asset('images/blank-profile-picture.png'),
            footer: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  ' '+currentArtist['name']+' ',
                  style: TextStyle(color: Colors.black, backgroundColor: Colors.white, ),
                )
            ),
          )
        );
      },
    );
  }

  void getArtists() async {
    var response = jsonDecode((await oAuth2Helper.get(ApiUrls.followedArtists)).body);

    bool hasNext = true;
    if ( response['error'] == null ) {
      _items.addAll(response['artists']['items']);
      while ( hasNext == true ) {
        if (response['artists']['next'] != null) {
          var nextRes = jsonDecode((await oAuth2Helper.get(response['artists']['next'])).body);
          _items.addAll(nextRes['artists']['items']);
          if ( nextRes['artists']['next'] != null ) {
            response = nextRes;
          }
          else {
            hasNext = false;
          }
        }
        else {
          hasNext = false;
        }
      }
      print(_items.length);

      setState(() {
        //print(response.body);
      });
    }
  }


}

class Artist {
  String id;
  String name;
  var images;
  var external_urls;

  Artist({this.id, this.name, this.images, this.external_urls});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      images: json['images'],
      external_urls: json['external_urls']
    );
  }
}