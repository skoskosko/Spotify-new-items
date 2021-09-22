import 'package:flutter/material.dart';
import 'package:spotifynewitems/utils/song_operations.dart';

Widget openInSpotifyIcon(String uri) {
  return GestureDetector(
    child: Icon(
      Icons.open_in_new,
      color: Colors.red,
      size: 40,
    ),
    onTap: () {
      openUriInSpotify(uri);
    },
  );
}

Widget playIcon(String uri) {
  return GestureDetector(
    child: Icon(
      Icons.play_circle_filled,
      color: Colors.green,
      size: 40,
    ),
    onTap: () {
      play(uri);
    },
  );
}

Widget addToQueueIcon(String uri) {
  return GestureDetector(
    child: Icon(
      Icons.queue,
      color: Colors.black45,
      size: 40,
    ),
    onTap: () {
      addToQueue(uri);
    },
  );
}