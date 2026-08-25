enum SuperMediaType { image, video, file }

enum SuperMediaSource { gallery, camera, files }

enum SuperMediaItemOrigin { local, remote }

enum SuperMediaItemStatus {
  existing,
  added,
  removed,
  uploading,
  uploaded,
  failed,
}

enum SuperMediaImageQuality { original, high, medium, low, custom }

enum SuperMediaLayout { grid, list }
