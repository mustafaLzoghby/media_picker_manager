## 0.1.0

- Published package name finalized as `media_picker_manager`, with the matching
  public import library and renamed example application.
- Documented required iOS permissions, Android minimum SDK/network permission,
  automatic transitive dependencies, and optional macOS entitlements; the
  example now includes the same platform configuration.
- Added GitHub repository, issue tracker, documentation metadata, README badges,
  and GitHub-hosted demo GIF URLs.
- Initial release.
- Single and multiple image/video/file picking.
- Remote/API media support.
- Added/removed item tracking for edit forms.
- Per-type and total limits.
- File size display and validation.
- Image quality/resize options.
- Video processing transform hook.
- Upload progress state support.
- Custom item/add/empty builders.
- Independent image, video, and file multiple-selection settings.
- Configurable picker frame, item proportions, and container builder.
- Configurable labels and widget-based icons for all built-in controls.
- Automatic grid/list drag sorting with a customizable reorder handle.
- Zoomable full-screen image preview and full-screen video playback.
- Preserve example selections when cards scroll off-screen.
- Keep picker state alive in lazy scrolling containers by default.
- Video thumbnails from explicit image paths/URLs or automatic first frames.
- Automatic device-locale text, RTL layout, and custom translation maps.
- Optional factory name/type fields with path and URL inference.
- Extensionless remote URLs default to images with ID-based names.
- Delete-one-by-ID, delete-all, and removed remote ID helpers.
- Merge newly introduced initial API IDs during widget updates and hot reload.
- Fixed grid item heights, per-origin metadata visibility, and item frame builder.
- Per-item frame width, height, and alignment controls.
- Explicit RTL/LTR override and mirrored directional controls.
- Initial items accept media items, URL strings, API maps, and custom mappers.
- Singular `initialItem` accepts the same input forms as `initialItems`.
- Dynamic initial data now recognizes URI/File/XFile values, flexible API key
  aliases, and custom models with `toJson()`, while retaining mapper support.
- Added separate one/multiple image, video, file, and mixed-media widgets with
  direct path callbacks for API uploads.
- Added typed `addedImagePaths`, `addedVideoPaths`, `addedFilePaths`, and
  `addedMediaPaths` result helpers plus an action-level `onPicked` callback.
- Rebuilt the example as a focused cookbook for every separate picker.
- Reorder sorting remains enabled, but its handle icon is now hidden by default.
- Initial-data widgets are now generic and expose typed mappers, allowing any
  model type without `Object` casts.
- Single image, video, file, and media pickers now expose direct width, height,
  and alignment controls, use a full-width column, and align to start by default.
- Added `onDelete(id)` and `onDeleteAll(ids)` endpoint callbacks for remote
  initial items; controller delete-all now returns the affected remote IDs.
- Added direct image quality/dimension limits, video duration/size limits, file
  size limits, and multi-only item/total-size limits to the simple pickers.
- Added per-type `maxImages` and `maxVideos` controls to the multiple-media
  picker and a playable remote video to the example lists.
- Exposed `addButtonBuilder` and `itemBuilder` on every simple picker so apps
  can completely replace the default upload frame and selected-media design.
