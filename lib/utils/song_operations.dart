import 'dart:convert';
import 'dart:io';
import 'package:spotifynewitems/utils/spotify_oauth2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as Http;
import 'dart:collection';
import '../api_names.dart';

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

void addToQueue(String trackUri) async {
  Http.Response result = await oAuth2Helper.post(
      ApiUrls.addToQueue(trackUri));
  if (result.statusCode == HttpStatus.noContent) {
    print("Successfully added song to queue");
  }
  else
    print("Failed to add song to queue ${result.reasonPhrase}");
}

void openUriInSpotify(String uri) async {
  if (await canLaunch(uri)) {
    await launch(uri);
  }
  else {
    throw 'Could not launch uri: $uri';
  }
}
