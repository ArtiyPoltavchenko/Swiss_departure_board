import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/departure.dart';
import '../models/stop.dart';
import 'exceptions.dart';

/// Riverpod provider for [TransportApi].
final transportApiProvider = Provider<TransportApi>((_) => TransportApi());

/// Client for the transport.opendata.ch REST API.
///
/// All methods throw subclasses of [AppException] on failure.
/// Never call the real API in tests — inject a [Dio] with a mock adapter.
class TransportApi {
  static const _baseUrl = 'https://transport.opendata.ch/v1';

  final Dio _dio;

  TransportApi({Dio? dio}) : _dio = dio ?? _buildDio();

  static Dio _buildDio() => Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

  /// Returns up to [limit] stops nearest to the given coordinates.
  ///
  /// Calls `GET /locations?x={lat}&y={lng}&type=station`.
  Future<List<Stop>> getNearbyStops(
    double lat,
    double lng, {
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/locations',
        queryParameters: {'x': lat, 'y': lng, 'type': 'station'},
      );
      final data = response.data;
      if (data == null) throw const ApiParseException('Empty response body');
      final stations = data['stations'] as List<dynamic>? ?? [];
      return stations
          .take(limit)
          .map((s) => Stop.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _mapDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiParseException(e.toString());
    }
  }

  /// Returns departure board for [stationId], up to [limit] entries.
  ///
  /// Calls `GET /stationboard?id={stationId}&limit={limit}`.
  Future<List<Departure>> getDepartures(
    String stationId, {
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/stationboard',
        queryParameters: {'id': stationId, 'limit': limit},
      );
      final data = response.data;
      if (data == null) throw const ApiParseException('Empty response body');
      final board = data['stationboard'] as List<dynamic>? ?? [];
      return board
          .map((e) =>
              Departure.fromStationboardEntry(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _mapDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiParseException(e.toString());
    }
  }

  /// Maps a [DioException] to the appropriate [AppException] and throws it.
  Never _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const ApiTimeoutException();
      case DioExceptionType.connectionError:
        throw const NoNetworkException();
      case DioExceptionType.badResponse:
        throw ApiException(
          e.response?.statusCode ?? 0,
          e.response?.statusMessage ?? 'Bad response',
        );
      default:
        throw ApiParseException(e.message ?? 'Unexpected error');
    }
  }
}
