import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spotifynewitems/api_names.dart';
import 'package:spotifynewitems/utils/spotify_oauth2.dart';
import '../components/song_list_action_buttons.dart';

class AllFollowedArtistReleases extends StatefulWidget {
  final List<dynamic> artistList;
  final List<dynamic> songList;
  static const String id = "artist_releases";

  AllFollowedArtistReleases({Key key, @required this.artistList, @required this.songList}): super(key: key);

  @override
  AllFollowedArtistReleasesState createState() => AllFollowedArtistReleasesState();
}

class AllFollowedArtistReleasesState extends State<AllFollowedArtistReleases> with SingleTickerProviderStateMixin {
  var songList = new List();
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 7));
  DateTime previousDate;
  var pushed = false;
  var loading = false;
  var loadingText = "Loading";
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    this.songList = widget.songList;
    _animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000));
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
                          firstDate: DateTime(1900, 1),
                          lastDate: DateTime(2101));
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          previousDate = selectedDate;
                          selectedDate = picked;
                        });
                      }
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
                  new AnimatedBuilder(
                    animation: _animationController,
                    child: OutlineButton(
                      child: Icon(Icons.refresh),
                      onPressed: refresh,
                      shape: CircleBorder(),
                    ),
                    builder: (BuildContext context, Widget _widget) {
                      return new Transform.rotate(angle: _animationController.value * 6.3, child: _widget);
                    },
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
    if ( this.songList.isEmpty || this.previousDate != this.selectedDate ) {
      this.loading = true;
      this.animation();
      if ( this.previousDate != null && this.previousDate.isBefore(this.selectedDate) && this.songList.isNotEmpty ) {
        this.updateSongList();
      }
      else {
        this.previousDate = this.selectedDate;
        this.songList = new List();
        this.getItems();
      }
    }
  }

  void animation() {
    this.setState(() {
      this.loading ? this._animationController.repeat() : this._animationController.reset();
    });
  }

  void updateSongList() {
    var newSongList = new List();
    for ( dynamic song in this.songList ) {
      if (song["releaseDate"].isAfter(this.selectedDate)) {
        newSongList.add(song);
      }
    }
    this.songList = newSongList;
    this.loading = false;
    this.previousDate = this.selectedDate;
    this.animation();
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
                  openInSpotifyIcon(currentSong["uri"]),
                  playIcon(currentSong["uri"]),
                  addToQueueIcon(currentSong["uri"]),
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
    this.loading = false;
    this.animation();
  }
}