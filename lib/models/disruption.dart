/// A service disruption from the opentransportdata.swiss SIRI-SX feed.
class Disruption {
  /// Short summary shown to the user.
  final String summary;

  /// Optional long-form description.
  final String? detail;

  /// Line identifier this disruption affects, if known.
  final String? affectedLine;

  /// Start of the validity period. Null if not specified.
  final DateTime? validFrom;

  /// End of the validity period. Null if not specified.
  final DateTime? validTo;

  const Disruption({
    required this.summary,
    this.detail,
    this.affectedLine,
    this.validFrom,
    this.validTo,
  });

  @override
  String toString() => 'Disruption($summary)';
}
