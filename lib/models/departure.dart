/// A single departure entry from a transport stop's departure board.
///
/// Maps to entries in the `stationboard` array returned by
/// transport.opendata.ch `/stationboard`.
class Departure {
  /// Line identifier shown on the vehicle (e.g. "7", "S3", "33").
  final String line;

  /// Final destination of the service (e.g. "Wollishofen").
  final String destination;

  /// Scheduled departure time from the timetable.
  final DateTime scheduledTime;

  /// Real-time prognosis from the operator. Null if not available.
  final DateTime? estimatedTime;

  /// Normalised category string: "tram", "bus", "train", "ship", "cableway".
  final String category;

  /// Track or platform identifier. Null if not provided by the API.
  final String? platform;

  /// True when disruption data has been merged for this departure.
  final bool hasDisruption;

  const Departure({
    required this.line,
    required this.destination,
    required this.scheduledTime,
    this.estimatedTime,
    required this.category,
    this.platform,
    this.hasDisruption = false,
  });

  /// Minutes until departure (using [estimatedTime] if available, otherwise
  /// [scheduledTime]). Returns 0 if the departure time is in the past.
  int get minutesUntil {
    final target = estimatedTime ?? scheduledTime;
    final diff = target.difference(DateTime.now()).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  /// True when [minutesUntil] == 0 (the vehicle is departing now).
  bool get isDeparting => minutesUntil == 0;

  /// Creates a [Departure] from a transport.opendata.ch stationboard entry.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "stop": {
  ///     "departure": "2024-01-15T10:30:00+0100",
  ///     "platform": "3",
  ///     "prognosis": { "departure": "2024-01-15T10:31:00+0100" }
  ///   },
  ///   "name": "IC 1",
  ///   "category": "IC",
  ///   "number": "1",
  ///   "to": "Zürich HB"
  /// }
  /// ```
  factory Departure.fromStationboardEntry(Map<String, dynamic> json) {
    final stop = json['stop'] as Map<String, dynamic>? ?? {};
    final prognosis = stop['prognosis'] as Map<String, dynamic>?;

    final scheduledStr = stop['departure'] as String?;
    final estimatedStr = prognosis?['departure'] as String?;

    final scheduledTime =
        scheduledStr != null ? DateTime.parse(scheduledStr) : DateTime.now();

    final estimatedTime =
        estimatedStr != null ? DateTime.parse(estimatedStr) : null;

    // Prefer `number` (e.g. "7") over `name` (e.g. "Tram 7").
    final line =
        json['number'] as String? ?? json['name'] as String? ?? '';

    return Departure(
      line: line,
      destination: json['to'] as String? ?? '',
      scheduledTime: scheduledTime,
      estimatedTime: estimatedTime,
      category: _normaliseCategory(json['category'] as String? ?? ''),
      platform: stop['platform'] as String?,
      hasDisruption: false,
    );
  }

  /// Returns a copy of this departure with [hasDisruption] set to [value].
  Departure withDisruption(bool value) => Departure(
        line: line,
        destination: destination,
        scheduledTime: scheduledTime,
        estimatedTime: estimatedTime,
        category: category,
        platform: platform,
        hasDisruption: value,
      );

  static String _normaliseCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 't':
      case 'tram':
        return 'tram';
      case 'b':
      case 'bus':
        return 'bus';
      case 'ic':
      case 'icn':
      case 'ir':
      case 'ec':
      case 'en':
      case 'nj':
      case 's':
      case 'sn':
        return 'train';
      case 'ship':
      case 'boat':
        return 'ship';
      case 'cableway':
      case 'cable_car':
        return 'cableway';
      default:
        return raw.toLowerCase();
    }
  }

  @override
  String toString() =>
      'Departure(line: $line, to: $destination, at: $scheduledTime)';
}
