import 'package:flutter/widgets.dart';

import '../enums/media_enums.dart';

class SuperImageConfig {
  /// Overrides the global multiple-selection behavior for image picker actions.
  final bool? allowMultiple;
  final int? maxSizeBytes;
  final int? maxWidth;
  final int? maxHeight;
  final int quality;
  final SuperMediaImageQuality preset;

  const SuperImageConfig({
    this.allowMultiple,
    this.maxSizeBytes,
    this.maxWidth,
    this.maxHeight,
    this.quality = 85,
    this.preset = SuperMediaImageQuality.high,
  }) : assert(quality >= 0 && quality <= 100);
}

class SuperVideoConfig {
  /// Overrides the global multiple-selection behavior for video picker actions.
  final bool? allowMultiple;
  final int? maxSizeBytes;
  final Duration? maxDuration;

  const SuperVideoConfig({
    this.allowMultiple,
    this.maxSizeBytes,
    this.maxDuration,
  });
}

class SuperFileConfig {
  /// Overrides the global multiple-selection behavior for file picker actions.
  final bool? allowMultiple;
  final int? maxSizeBytes;
  final List<String> allowedExtensions;

  const SuperFileConfig({
    this.allowMultiple,
    this.maxSizeBytes,
    this.allowedExtensions = const [],
  });
}

/// Controls the frame around the complete media picker.
class SuperMediaFrameConfig {
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final Clip clipBehavior;

  const SuperMediaFrameConfig({
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.padding,
    this.alignment,
    this.decoration,
    this.foregroundDecoration,
    this.clipBehavior = Clip.none,
  }) : assert(width == null || width >= 0),
       assert(height == null || height >= 0);
}

/// Controls the size and alignment of each media tile and add button.
class SuperMediaItemFrameConfig {
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;

  const SuperMediaItemFrameConfig({
    this.width,
    this.height,
    this.alignment = AlignmentDirectional.centerStart,
  }) : assert(width == null || width > 0),
       assert(height == null || height > 0);
}

/// Controls every built-in user-facing label.
class SuperMediaTextConfig {
  final String images;
  final String takePhoto;
  final String videos;
  final String recordVideo;
  final String files;
  final String addMedia;
  final String remoteBadge;
  final String unknownSize;
  final String unableToDisplayMedia;
  final String unableToPlayVideo;
  final bool _usesDeviceLocale;

  const SuperMediaTextConfig({
    this.images = 'Images',
    this.takePhoto = 'Take photo',
    this.videos = 'Videos',
    this.recordVideo = 'Record video',
    this.files = 'Files',
    this.addMedia = 'Add media',
    this.remoteBadge = 'API',
    this.unknownSize = 'Unknown',
    this.unableToDisplayMedia = 'Unable to display this media',
    this.unableToPlayVideo = 'Unable to play this video',
  }) : _usesDeviceLocale = false;

  const SuperMediaTextConfig.device()
    : images = 'Images',
      takePhoto = 'Take photo',
      videos = 'Videos',
      recordVideo = 'Record video',
      files = 'Files',
      addMedia = 'Add media',
      remoteBadge = 'API',
      unknownSize = 'Unknown',
      unableToDisplayMedia = 'Unable to display this media',
      unableToPlayVideo = 'Unable to play this video',
      _usesDeviceLocale = true;

  static SuperMediaTextConfig forLocale(Locale locale) {
    return switch (locale.languageCode.toLowerCase()) {
      'ar' => const SuperMediaTextConfig(
        images: 'الصور',
        takePhoto: 'التقاط صورة',
        videos: 'الفيديوهات',
        recordVideo: 'تسجيل فيديو',
        files: 'الملفات',
        addMedia: 'إضافة وسائط',
        remoteBadge: 'محفوظ',
        unknownSize: 'غير معروف',
        unableToDisplayMedia: 'تعذر عرض هذه الوسائط',
        unableToPlayVideo: 'تعذر تشغيل هذا الفيديو',
      ),
      'fr' => const SuperMediaTextConfig(
        images: 'Images',
        takePhoto: 'Prendre une photo',
        videos: 'Vidéos',
        recordVideo: 'Enregistrer une vidéo',
        files: 'Fichiers',
        addMedia: 'Ajouter un média',
        remoteBadge: 'Enregistré',
        unknownSize: 'Inconnu',
        unableToDisplayMedia: 'Impossible d’afficher ce média',
        unableToPlayVideo: 'Impossible de lire cette vidéo',
      ),
      'es' => const SuperMediaTextConfig(
        images: 'Imágenes',
        takePhoto: 'Tomar foto',
        videos: 'Vídeos',
        recordVideo: 'Grabar vídeo',
        files: 'Archivos',
        addMedia: 'Añadir contenido',
        remoteBadge: 'Guardado',
        unknownSize: 'Desconocido',
        unableToDisplayMedia: 'No se puede mostrar este contenido',
        unableToPlayVideo: 'No se puede reproducir este vídeo',
      ),
      'de' => const SuperMediaTextConfig(
        images: 'Bilder',
        takePhoto: 'Foto aufnehmen',
        videos: 'Videos',
        recordVideo: 'Video aufnehmen',
        files: 'Dateien',
        addMedia: 'Medien hinzufügen',
        remoteBadge: 'Gespeichert',
        unknownSize: 'Unbekannt',
        unableToDisplayMedia: 'Medium kann nicht angezeigt werden',
        unableToPlayVideo: 'Video kann nicht abgespielt werden',
      ),
      'tr' => const SuperMediaTextConfig(
        images: 'Görseller',
        takePhoto: 'Fotoğraf çek',
        videos: 'Videolar',
        recordVideo: 'Video kaydet',
        files: 'Dosyalar',
        addMedia: 'Medya ekle',
        remoteBadge: 'Kayıtlı',
        unknownSize: 'Bilinmiyor',
        unableToDisplayMedia: 'Bu medya görüntülenemiyor',
        unableToPlayVideo: 'Bu video oynatılamıyor',
      ),
      _ => const SuperMediaTextConfig(),
    };
  }
}

/// Controls every built-in icon using widgets rather than icon data.
///
/// Null values use the package's default Material icons.
class SuperMediaIconConfig {
  final Widget? images;
  final Widget? takePhoto;
  final Widget? videos;
  final Widget? recordVideo;
  final Widget? files;
  final Widget? addMedia;
  final Widget? remove;
  final Widget? reorder;
  final Widget? brokenImage;
  final Widget? videoPlaceholder;
  final Widget? filePlaceholder;

  const SuperMediaIconConfig({
    this.images,
    this.takePhoto,
    this.videos,
    this.recordVideo,
    this.files,
    this.addMedia,
    this.remove,
    this.reorder,
    this.brokenImage,
    this.videoPlaceholder,
    this.filePlaceholder,
  });
}

class SuperMediaLimits {
  final int? maxItems;
  final int? maxImages;
  final int? maxVideos;
  final int? maxFiles;
  final int? maxTotalSizeBytes;

  const SuperMediaLimits({
    this.maxItems,
    this.maxImages,
    this.maxVideos,
    this.maxFiles,
    this.maxTotalSizeBytes,
  });
}

class SuperMediaPickerConfig {
  final Set<SuperMediaType> allowedTypes;
  final Set<SuperMediaSource> sources;
  final bool allowMultiple;
  final bool enableReorder;
  final bool showReorderHandle;
  final bool enablePreview;
  final bool keepAlive;
  final bool showFileSize;
  final bool showFileName;
  final bool? showLocalFileSize;
  final bool? showLocalFileName;
  final bool? showRemoteFileSize;
  final bool? showRemoteFileName;
  final bool showRemoveButton;
  final bool showRemoteBadge;
  final SuperMediaLayout layout;
  final int crossAxisCount;
  final double spacing;
  final double borderRadius;
  final double gridItemAspectRatio;
  final double? gridItemHeight;
  final double listItemHeight;
  final SuperImageConfig image;
  final SuperVideoConfig video;
  final SuperFileConfig file;
  final SuperMediaLimits limits;
  final SuperMediaFrameConfig frame;
  final SuperMediaItemFrameConfig itemFrame;
  final SuperMediaTextConfig text;
  final Locale? locale;
  final TextDirection? textDirection;
  final Map<String, SuperMediaTextConfig> translations;
  final SuperMediaIconConfig icons;

  const SuperMediaPickerConfig({
    this.allowedTypes = const {
      SuperMediaType.image,
      SuperMediaType.video,
      SuperMediaType.file,
    },
    this.sources = const {
      SuperMediaSource.gallery,
      SuperMediaSource.camera,
      SuperMediaSource.files,
    },
    this.allowMultiple = true,
    this.enableReorder = true,
    this.showReorderHandle = false,
    this.enablePreview = true,
    this.keepAlive = true,
    this.showFileSize = true,
    this.showFileName = true,
    this.showLocalFileSize,
    this.showLocalFileName,
    this.showRemoteFileSize,
    this.showRemoteFileName,
    this.showRemoveButton = true,
    this.showRemoteBadge = true,
    this.layout = SuperMediaLayout.grid,
    this.crossAxisCount = 3,
    this.spacing = 8,
    this.borderRadius = 12,
    this.gridItemAspectRatio = 1,
    this.gridItemHeight,
    this.listItemHeight = 96,
    this.image = const SuperImageConfig(),
    this.video = const SuperVideoConfig(),
    this.file = const SuperFileConfig(),
    this.limits = const SuperMediaLimits(),
    this.frame = const SuperMediaFrameConfig(),
    this.itemFrame = const SuperMediaItemFrameConfig(),
    this.text = const SuperMediaTextConfig.device(),
    this.locale,
    this.textDirection,
    this.translations = const {},
    this.icons = const SuperMediaIconConfig(),
  }) : assert(crossAxisCount > 0),
       assert(gridItemAspectRatio > 0),
       assert(gridItemHeight == null || gridItemHeight > 0),
       assert(listItemHeight > 0);

  /// Whether one picker action may select multiple items of [type].
  ///
  /// A per-type value takes precedence over the global [allowMultiple] value.
  bool allowsMultipleFor(SuperMediaType type) {
    return switch (type) {
      SuperMediaType.image => image.allowMultiple ?? allowMultiple,
      SuperMediaType.video => video.allowMultiple ?? allowMultiple,
      SuperMediaType.file => file.allowMultiple ?? allowMultiple,
    };
  }

  SuperMediaTextConfig resolveText(Locale deviceLocale) {
    if (!text._usesDeviceLocale) return text;
    final effectiveLocale = locale ?? deviceLocale;
    return translations[effectiveLocale.toLanguageTag()] ??
        translations[effectiveLocale.languageCode] ??
        SuperMediaTextConfig.forLocale(effectiveLocale);
  }
}
