import 'package:flutter/material.dart';
import 'package:media_picker_manager/media_picker_manager.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MediaDemoPage(),
    );
  }
}

class Images {
  final int id;
  final String image;

  Images({required this.id, required this.image});
}

class MediaDemoPage extends StatefulWidget {
  const MediaDemoPage({super.key});

  @override
  State<MediaDemoPage> createState() => _MediaDemoPageState();
}

class _MediaDemoPageState extends State<MediaDemoPage> {
  late final SuperMediaController<Images> _imagesController;
  String? _image;
  List<String> _images = const [];
  String? _video;
  List<String> _videos = const [];
  String? _file;
  List<String> _files = const [];
  String? _media;
  List<String> _multipleMedia = const [];

  final List<Images> _initialImages = [
    Images(id: 1, image: 'https://picsum.photos/id/1011/900/600'),
    Images(id: 2, image: 'https://picsum.photos/id/1012/900/600'),
  ];

  final List<String> _initialString = ['https://picsum.photos/id/1011/900/600'];

  final List<String> _initialVideos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ];

  static const _simpleConfig = SuperMediaPickerConfig(
    crossAxisCount: 3,
    gridItemHeight: 120,
    showFileName: false,
    showFileSize: true,
    showRemoteBadge: false,
    itemFrame: SuperMediaItemFrameConfig(height: 120),
  );

  @override
  void initState() {
    super.initState();
    _imagesController = SuperMediaController<Images>();
  }

  @override
  void dispose() {
    _imagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Picker Manager')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Simple, separate pickers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose only the widget you need. Every upload callback returns a local path ready for your API.',
          ),
          const SizedBox(height: 24),
          _ExampleCard(
            title: 'One image — source dialog',
            callback: 'onUploadImage: (path) => upload(path)',
            value: _image,
            child: SuperImagePicker(
              width: double.infinity,
              height: 160,
              emptyWidth: double.infinity,
              emptyHeight: 170,
              nonEmptyWidth: double.infinity,
              nonEmptyHeight: 240,
              alignment: AlignmentDirectional.centerStart,
              config: const SuperMediaPickerConfig(
                sourcePresentation: SuperMediaSourcePresentation.dialog,
                text: SuperMediaTextConfig(addMedia: 'upload'),
                icons: SuperMediaIconConfig(
                  images: Icon(Icons.photo_library_outlined),
                  takePhoto: Icon(Icons.photo_camera_outlined),
                ),
                showFileName: false,
                showFileSize: true,
                showRemoteBadge: false,
              ),
              addButtonBuilder:
                  (context, openPicker) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B5FEF), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: openPicker,
                        borderRadius: BorderRadius.circular(24),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.white,
                                size: 38,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Choose an image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              onUploadImage: (path) => setState(() => _image = path),
            ),
          ),
          _ExampleCard(
            title: 'Any typed model',
            callback:
                'onDelete: (id) => deleteEndpoint(id)  •  onDeleteAll: (ids) => deleteAllEndpoint(ids)',
            value: _summary(_images),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SuperImagesPicker<Images>(
                  controller: _imagesController,
                  initialImages: _initialImages,
                  initialItemMapper:
                      (image, index) => SuperMediaItem.remote(
                        id: image.id.toString(),
                        url: image.image,
                      ),
                  config: SuperMediaPickerConfig(
                    text: SuperMediaTextConfig(addMedia: 'upload'),
                    crossAxisCount: 4,
                    gridItemHeight: 120,
                    showFileName: false,
                    showFileSize: false,
                    showRemoteBadge: false,
                    confirmDelete: true,
                    layout: SuperMediaLayout.list,
                    itemFrame: SuperMediaItemFrameConfig(height: 120),
                  ),
                  onDelete: (id) => debugPrint('DELETE /media/$id'),
                  onDeleteAll: (ids) => debugPrint('DELETE media IDs: $ids'),
                  onDeleteRequest: (item) async {
                    debugPrint('Waiting for DELETE /media/${item.id}');
                    return true;
                  },
                  onUploadImages: (paths) => setState(() => _images = paths),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed:
                      _imagesController.items.isEmpty
                          ? null
                          : _imagesController.deleteAllItems,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Delete all with controller'),
                ),
              ],
            ),
          ),
          _ExampleCard(
            title: 'Multiple images — bottom sheet',
            callback: 'onUploadImages: (paths) => uploadAll(paths)',
            value: _summary(_images),
            child: SuperImagesPicker(
              initialImages: _initialString,
              maxItems: 6,
              quality: 75,
              maxWidth: 1600,
              maxHeight: 1600,
              maxSizeBytes: 5.mb,
              maxTotalSizeBytes: 20.mb,
              config: _simpleConfig,
              onUploadImages: (paths) => setState(() => _images = paths),
            ),
          ),
          _ExampleCard(
            title: 'One video — direct Gallery',
            callback: 'onUploadVideo: (path) => upload(path)',
            value: _video,
            child: SuperVideoPicker(
              width: double.infinity,
              height: 190,
              config: const SuperMediaPickerConfig(
                sources: {SuperMediaSource.gallery},
                sourcePresentation: SuperMediaSourcePresentation.direct,
                directSource: SuperMediaSource.gallery,
                directType: SuperMediaType.video,
                showFileName: false,
                showFileSize: true,
              ),
              onUploadVideo: (path) => setState(() => _video = path),
            ),
          ),
          _ExampleCard(
            title: 'Multiple videos',
            callback: 'onUploadVideos: (paths) => uploadAll(paths)',
            value: _summary(_videos),
            child: SuperVideosPicker(
              initialVideos: _initialVideos,
              maxItems: 4,
              maxSizeBytes: 100.mb,
              maxTotalSizeBytes: 300.mb,
              maxDuration: const Duration(minutes: 5),
              config: _simpleConfig,
              onUploadVideos: (paths) => setState(() => _videos = paths),
            ),
          ),
          _ExampleCard(
            title: 'One file',
            callback: 'onUploadFile: (path) => upload(path)',
            value: _file,
            child: SuperFilePicker(
              width: double.infinity,
              height: 96,
              config: const SuperMediaPickerConfig(
                layout: SuperMediaLayout.list,
                listItemHeight: 88,
                file: SuperFileConfig(
                  allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
                ),
              ),
              onUploadFile: (path) => setState(() => _file = path),
            ),
          ),
          _ExampleCard(
            title: 'Multiple files',
            callback: 'onUploadFiles: (paths) => uploadAll(paths)',
            value: _summary(_files),
            child: SuperFilesPicker(
              maxItems: 5,
              maxSizeBytes: 10.mb,
              maxTotalSizeBytes: 40.mb,
              config: const SuperMediaPickerConfig(
                layout: SuperMediaLayout.list,
                listItemHeight: 88,
                file: SuperFileConfig(
                  allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
                ),
              ),
              onUploadFiles: (paths) => setState(() => _files = paths),
            ),
          ),
          _ExampleCard(
            title: 'One image or video',
            callback: 'onUploadMedia: (path) => upload(path)',
            value: _media,
            child: SuperSingleMediaPicker(
              config: _simpleConfig,
              onUploadMedia: (path) => setState(() => _media = path),
            ),
          ),
          _ExampleCard(
            title: 'Multiple images and videos',
            callback: 'onUploadMedia: (paths) => uploadAll(paths)',
            value: _summary(_multipleMedia),
            child: SuperMultipleMediaPicker(
              initialMedia: [
                'https://picsum.photos/id/1025/900/600',
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
              ],
              maxItems: 8,
              maxImages: 6,
              maxVideos: 2,
              imageQuality: 75,
              imageMaxWidth: 1600,
              imageMaxHeight: 1600,
              imageMaxSizeBytes: 5.mb,
              videoMaxSizeBytes: 100.mb,
              videoMaxDuration: const Duration(minutes: 5),
              maxTotalSizeBytes: 300.mb,
              config: _simpleConfig,
              onUploadMedia: (paths) => setState(() => _multipleMedia = paths),
            ),
          ),
          const _AdvancedExample(),
        ],
      ),
    );
  }

  String? _summary(List<String> paths) {
    if (paths.isEmpty) return null;
    return '${paths.length} selected\n${paths.join('\n')}';
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.callback,
    required this.child,
    this.value,
  });

  final String title;
  final String callback;
  final Widget child;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            SelectableText(
              callback,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            child,
            const SizedBox(height: 10),
            Text(
              value == null ? 'No local path selected' : 'API value:\n$value',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedExample extends StatelessWidget {
  const _AdvancedExample();

  @override
  Widget build(BuildContext context) {
    return const _ExampleCard(
      title: 'Advanced mixed picker',
      callback: 'onChanged: (result) => send(result.addedMediaPaths)',
      value:
          'Use this only when you need API items, deletion IDs, or complete configuration.',
      child: SuperMediaPicker(
        initialItems: [
          'https://picsum.photos/id/1011/900/600',
          {
            'media_id': 'api-image',
            'image_url': 'https://picsum.photos/id/1012/900/600',
          },
        ],
        config: SuperMediaPickerConfig(
          crossAxisCount: 5,
          gridItemHeight: 120,
          showRemoteBadge: true,
          showRemoteFileName: false,
          showRemoteFileSize: false,
        ),
      ),
    );
  }
}
