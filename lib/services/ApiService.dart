import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'ApiService.g.dart';

@JsonSerializable()
class GetLyricsRequest {
  final String trackName;
  final String artistName;
  final String albumName;
  final double duration;

  const GetLyricsRequest({
    required this.trackName,
    required this.artistName,
    required this.albumName,
    required this.duration,
  });

  factory GetLyricsRequest.fromJson(Map<String, dynamic> json) => _$GetLyricsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetLyricsRequestToJson(this);

  Map<String, String> toQueryParameters() => {
    'track_name': trackName,
    'artist_name': artistName,
    'album_name': albumName,
    'duration': duration.toString(),
  };
}

@JsonSerializable()
class GetLyricsResponse {
  final int id;
  final String trackName;
  final String artistName;
  final String albumName;
  final double duration;
  final bool instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  const GetLyricsResponse({
    required this.id,
    required this.trackName,
    required this.artistName,
    required this.albumName,
    required this.duration,
    required this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory GetLyricsResponse.fromJson(Map<String, dynamic> json) => _$GetLyricsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetLyricsResponseToJson(this);
}

@RestApi(baseUrl: "https://lrclib.net")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/api/get")
  Future<GetLyricsResponse> getLyrics({
    @Query("track_name") required String trackName,
    @Query("artist_name") required String artistName,
    @Query("album_name") required String albumName,
    @Query("duration") required double duration,
  });
}
