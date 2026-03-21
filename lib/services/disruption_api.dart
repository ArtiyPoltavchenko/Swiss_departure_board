import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/disruption.dart';
import 'exceptions.dart';

/// Riverpod provider for [DisruptionApi].
final disruptionApiProvider = Provider<DisruptionApi>((_) => DisruptionApi());

/// API key for opentransportdata.swiss.
/// Phase 7 will replace this with a compile-time --dart-define secret.
const String _apiKey = 'PLACEHOLDER';

/// Client for the opentransportdata.swiss SIRI-SX disruption feed.
///
/// If [_apiKey] is still the placeholder value, all methods return an empty
/// list silently — the app continues to work without disruption data.
class DisruptionApi {
  static const _baseUrl =
      'https://api.opentransportdata.swiss/siri-sx-ch-json';

  final Dio _dio;

  DisruptionApi({Dio? dio}) : _dio = dio ?? _buildDio();

  static Dio _buildDio() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  /// Returns active disruptions. Optionally filtered by [lineRef].
  ///
  /// Returns an empty list silently when the API key is the placeholder value.
  Future<List<Disruption>> getDisruptions({String? lineRef}) async {
    if (_apiKey == 'PLACEHOLDER') return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
        queryParameters: {
          if (lineRef != null) 'LineRef': lineRef,
        },
      );
      return _parseResponse(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NoNetworkException();
      }
      // Non-critical: log and return empty rather than crashing the UI.
      return [];
    } catch (_) {
      return [];
    }
  }

  List<Disruption> _parseResponse(Map<String, dynamic>? data) {
    if (data == null) return [];
    try {
      final situations = data['Siri']?['ServiceDelivery']
              ?['SituationExchangeDelivery']?['Situations']
              ?['PtSituationElement'] as List<dynamic>? ??
          [];

      return situations.map((s) {
        final element = s as Map<String, dynamic>;
        final summary = element['Summary'] as String? ?? '';
        final detail = element['Description'] as String?;
        final validFrom = _parseDate(element['ValidityPeriod']?['StartTime']);
        final validTo = _parseDate(element['ValidityPeriod']?['EndTime']);
        final lineRef =
            element['Affects']?['Networks']?['AffectedNetwork']
                ?['AffectedLine']?['LineRef'] as String?;

        return Disruption(
          summary: summary,
          detail: detail,
          affectedLine: lineRef,
          validFrom: validFrom,
          validTo: validTo,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null;
    }
  }
}
