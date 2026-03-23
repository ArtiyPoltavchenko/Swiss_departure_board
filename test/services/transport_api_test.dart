import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiss_departure_board/services/exceptions.dart';
import 'package:swiss_departure_board/services/transport_api.dart';

// ---------------------------------------------------------------------------
// Mock HttpClientAdapter — returns pre-configured responses without network.
// ---------------------------------------------------------------------------

class _MockAdapter implements HttpClientAdapter {
  final int statusCode;
  final String body;
  final bool simulateTimeout;
  final bool simulateConnectionError;

  _MockAdapter({
    this.body = '{}',
    this.simulateTimeout = false,
    this.simulateConnectionError = false,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (simulateConnectionError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    if (simulateTimeout) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
    }
    return ResponseBody.fromString(body, statusCode,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }

  @override
  void close({bool force = false}) {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TransportApi _apiWith(_MockAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://transport.opendata.ch/v1'));
  dio.httpClientAdapter = adapter;
  return TransportApi(dio: dio);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TransportApi.getNearbyStops', () {
    test('returns correct List<Stop> on 200 response', () async {
      final body = jsonEncode({
        'stations': [
          {
            'id': '8503000',
            'name': 'Zürich HB',
            'coordinate': {'x': 47.378177, 'y': 8.540192},
            'distance': 320,
          },
          {
            'id': '8503001',
            'name': 'Zürich, Bellevue',
            'coordinate': {'x': 47.366661, 'y': 8.544566},
            'distance': 750,
          },
        ],
      });

      final api = _apiWith(_MockAdapter(body: body));
      final stops = await api.getNearbyStops(47.37, 8.54);

      expect(stops.length, equals(2));
      expect(stops[0].id, equals('8503000'));
      expect(stops[0].name, equals('Zürich HB'));
      expect(stops[0].distance, equals(320));
      expect(stops[1].id, equals('8503001'));
    });

    test('respects the limit parameter', () async {
      final stations = List.generate(
        10,
        (i) => {
          'id': '$i',
          'name': 'Stop $i',
          'coordinate': {'x': 47.0 + i, 'y': 8.0},
          'distance': i * 100,
        },
      );
      final body = jsonEncode({'stations': stations});

      final api = _apiWith(_MockAdapter(body: body));
      final stops = await api.getNearbyStops(47.0, 8.0, limit: 3);

      expect(stops.length, equals(3));
    });

    test('returns empty list when stations array is empty', () async {
      final api = _apiWith(_MockAdapter(body: jsonEncode({'stations': []})));
      final stops = await api.getNearbyStops(47.0, 8.0);
      expect(stops, isEmpty);
    });

    test('throws NoNetworkException on connection error', () async {
      final api = _apiWith(_MockAdapter(simulateConnectionError: true));
      expect(
        () => api.getNearbyStops(47.0, 8.0),
        throwsA(isA<NoNetworkException>()),
      );
    });
  });

  group('TransportApi.getDepartures', () {
    test('returns correct List<Departure> on 200 response', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      final body = jsonEncode({
        'stationboard': [
          {
            'stop': {
              'departure': futureTime,
              'platform': '2',
              'prognosis': {},
            },
            'to': 'Wollishofen',
            'category': 'T',
            'number': '7',
            'name': 'Tram 7',
          },
          {
            'stop': {
              'departure': futureTime,
              'platform': null,
              'prognosis': {},
            },
            'to': 'Flughafen',
            'category': 'S',
            'number': '16',
            'name': 'S16',
          },
        ],
      });

      final api = _apiWith(_MockAdapter(body: body));
      final departures = await api.getDepartures('8503000');

      expect(departures.length, equals(2));
      expect(departures[0].line, equals('7'));
      expect(departures[0].destination, equals('Wollishofen'));
      expect(departures[0].category, equals('tram'));
      expect(departures[0].platform, equals('2'));
      expect(departures[1].line, equals('16'));
      expect(departures[1].category, equals('train'));
    });

    test('returns empty list when stationboard array is empty', () async {
      final api =
          _apiWith(_MockAdapter(body: jsonEncode({'stationboard': []})));
      final departures = await api.getDepartures('8503000');
      expect(departures, isEmpty);
    });

    test('throws ApiTimeoutException on connection timeout', () async {
      final api = _apiWith(_MockAdapter(simulateTimeout: true));
      expect(
        () => api.getDepartures('8503000'),
        throwsA(isA<ApiTimeoutException>()),
      );
    });
  });
}
