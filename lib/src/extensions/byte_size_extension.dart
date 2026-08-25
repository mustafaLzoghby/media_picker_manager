extension ByteSizeExtension on num {
  int get bytes => round();
  int get kb => (this * 1024).round();
  int get mb => (this * 1024 * 1024).round();
  int get gb => (this * 1024 * 1024 * 1024).round();
}

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
