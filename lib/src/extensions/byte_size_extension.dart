/// Converts readable numeric sizes into byte counts for picker configuration.
///
/// For example, `5.mb` can be assigned to a `maxSizeBytes` option.
extension ByteSizeExtension on num {
  /// Interprets this number as bytes and rounds it to an integer.
  int get bytes => round();

  /// Converts this number of kibibytes to bytes.
  int get kb => (this * 1024).round();

  /// Converts this number of mebibytes to bytes.
  int get mb => (this * 1024 * 1024).round();

  /// Converts this number of gibibytes to bytes.
  int get gb => (this * 1024 * 1024 * 1024).round();
}

/// Formats [bytes] as a readable B, KB, MB, or GB string.
///
/// Returns [unknownLabel] when the byte count is unavailable. The [decimals]
/// value controls the number of fractional digits for converted units.
String formatBytes(
  int? bytes, {
  int decimals = 1,
  String unknownLabel = 'Unknown',
}) {
  if (bytes == null) return unknownLabel;
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(decimals)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(decimals)} MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(decimals)} GB';
}
