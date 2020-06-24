import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class SpotifyOAuth2Client extends OAuth2Client {
  SpotifyOAuth2Client({@required String redirectUri, @required String customUriScheme}): super(
      authorizeUrl: 'https://accounts.spotify.com/authorize',
      tokenUrl: 'https://accounts.spotify.com/api/token',
      redirectUri: redirectUri,
      customUriScheme: customUriScheme,
  );
}

SpotifyOAuth2Client client = SpotifyOAuth2Client(
    redirectUri: 'spotifynewitems:/',
    customUriScheme: 'spotifynewitems',
);

OAuth2Helper oAuth2Helper = OAuth2Helper(
    client,
    grantType: OAuth2Helper.AUTHORIZATION_CODE,
    clientId: 'df7deead3f074ce18535a45e6041a99c',
    scopes: [
      'playlist-read-private',
      'user-follow-read',
      'streaming',
      'app-remote-control',
    ],
);