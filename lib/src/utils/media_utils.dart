import '../enums/media_enums.dart';

const _imageExtensions = {
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'heic',
  'heif',
  'bmp',
};
const _videoExtensions = {'mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm', '3gp'};

String extensionOf(String name) {
  final cleanName = name.split('?').first.split('#').first;
  final index = cleanName.lastIndexOf('.');
  if (index == -1 || index == cleanName.length - 1) return '';
  return cleanName.substring(index + 1).toLowerCase();
}

String mediaNameFromPathOrUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    final segment = uri.pathSegments.last;
    if (segment.isNotEmpty) return Uri.decodeComponent(segment);
  }
  final normalized =
      value.replaceAll('\\', '/').split('?').first.split('#').first;
  final name = normalized.split('/').last;
  return name.isEmpty ? 'media' : name;
}

SuperMediaType mediaTypeFromName(String name) {
  final ext = extensionOf(name);
  if (_imageExtensions.contains(ext)) return SuperMediaType.image;
  if (_videoExtensions.contains(ext)) return SuperMediaType.video;
  return SuperMediaType.file;
}
