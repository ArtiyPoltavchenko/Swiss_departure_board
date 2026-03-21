/// A public transport stop (station).
///
/// Maps to the `station` objects returned by transport.opendata.ch.
class Stop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  /// Distance from the user in metres. Null if not requested with geolocation.
  final int? distance;

  const Stop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distance,
  });

  /// Creates a [Stop] from a transport.opendata.ch `/locations` station entry.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "id": "8503000",
  ///   "name": "Zürich HB",
  ///   "coordinate": { "x": 47.378177, "y": 8.540192 },
  ///   "distance": 500
  /// }
  /// ```
  factory Stop.fromJson(Map<String, dynamic> json) {
    final coordinate = json['coordinate'] as Map<String, dynamic>?;
    return Stop(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (coordinate?['x'] as num?)?.toDouble() ?? 0.0,
      longitude: (coordinate?['y'] as num?)?.toDouble() ?? 0.0,
      distance: json['distance'] as int?,
    );
  }

  /// Serialises this stop for SharedPreferences storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coordinate': {'x': latitude, 'y': longitude},
        if (distance != null) 'distance': distance,
      };

  @override
  String toString() => 'Stop($id, $name)';

  @override
  bool operator ==(Object other) =>
      other is Stop && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
