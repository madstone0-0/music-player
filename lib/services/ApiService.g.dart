// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiService.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetLyricsRequest _$GetLyricsRequestFromJson(Map<String, dynamic> json) =>
    GetLyricsRequest(
      trackName: json['trackName'] as String,
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String,
      duration: (json['duration'] as num).toDouble(),
    );

Map<String, dynamic> _$GetLyricsRequestToJson(GetLyricsRequest instance) =>
    <String, dynamic>{
      'trackName': instance.trackName,
      'artistName': instance.artistName,
      'albumName': instance.albumName,
      'duration': instance.duration,
    };

GetLyricsResponse _$GetLyricsResponseFromJson(Map<String, dynamic> json) =>
    GetLyricsResponse(
      id: (json['id'] as num).toInt(),
      trackName: json['trackName'] as String,
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String,
      duration: (json['duration'] as num).toDouble(),
      instrumental: json['instrumental'] as bool,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );

Map<String, dynamic> _$GetLyricsResponseToJson(GetLyricsResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackName': instance.trackName,
      'artistName': instance.artistName,
      'albumName': instance.albumName,
      'duration': instance.duration,
      'instrumental': instance.instrumental,
      'plainLyrics': instance.plainLyrics,
      'syncedLyrics': instance.syncedLyrics,
    };

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _ApiService implements ApiService {
  _ApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://lrclib.net';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<GetLyricsResponse> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required double duration,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'track_name': trackName,
      r'artist_name': artistName,
      r'album_name': albumName,
      r'duration': duration,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GetLyricsResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/get',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GetLyricsResponse _value;
    try {
      _value = GetLyricsResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
