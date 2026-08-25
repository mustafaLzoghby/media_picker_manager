/// Identifies the content represented by a media item.
enum SuperMediaType {
  /// A still image selected locally or loaded from a URL.
  image,

  /// A playable video selected locally or loaded from a URL.
  video,

  /// A generic document or other non-image, non-video file.
  file,
}

/// A native source that can be offered when opening the picker.
enum SuperMediaSource {
  /// The device photo and video library.
  gallery,

  /// The device camera for taking photos or recording videos.
  camera,

  /// The platform file-browser interface.
  files,
}

/// Controls how the available media sources are presented to the user.
enum SuperMediaSourcePresentation {
  /// Display the available sources in a modal bottom sheet.
  bottomSheet,

  /// Display the available sources in an icon-based dialog.
  dialog,

  /// Open a configured source immediately without showing a chooser.
  direct,
}

/// Describes whether an item came from the device or an API.
enum SuperMediaItemOrigin {
  /// A newly selected file with a local path.
  local,

  /// An existing item represented by a remote URL and API identifier.
  remote,
}

/// Tracks the lifecycle of an item displayed by the media manager.
enum SuperMediaItemStatus {
  /// An unchanged remote item that already exists on the server.
  existing,

  /// A local item that has been selected but not uploaded yet.
  added,

  /// A remote item marked for deletion from the server.
  removed,

  /// An item whose upload is currently in progress.
  uploading,

  /// An item whose upload completed successfully.
  uploaded,

  /// An item whose upload failed.
  failed,
}

/// Presets that control whether native image compression is applied.
enum SuperMediaImageQuality {
  /// Keep the image at its original quality when the platform supports it.
  original,

  /// Prefer a high-quality image with light compression.
  high,

  /// Prefer balanced image quality and file size.
  medium,

  /// Prefer a smaller image with stronger compression.
  low,

  /// Use the explicit image quality and dimension configuration values.
  custom,
}

/// Built-in arrangements for media items and the add button.
enum SuperMediaLayout {
  /// Display media in a configurable multi-column grid.
  grid,

  /// Display media vertically using a fixed item height.
  list,
}
