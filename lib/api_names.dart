class ApiUrls {
  static String ownFollowedPlaylists = "https://api.spotify.com/v1/me/playlists";
  static String followedArtists = "https://api.spotify.com/v1/me/following?type=artist&limit=50";
  static String newReleases = "https://api.spotify.com/v1/browse/new-releases?limit=50";
  static String play = "https://api.spotify.com/v1/me/player/play";
  static String pause = "https://api.spotify.com/v1/me/player/pause";
  static String addToQueue(String trackUri) { return "https://api.spotify.com/v1/me/player/queue?uri=$trackUri"; }
  static String artistAlbums(String artistId, String offset) { return "https://api.spotify.com/v1/artists/$artistId/albums?offset=$offset&limit=20&include_groups=single"; }
  static String albumTracks(String albumId) {
    return "https://api.spotify.com/v1/albums/$albumId/tracks";
  }
}