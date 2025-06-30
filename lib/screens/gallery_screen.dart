import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditionally import dart:io only for non-web platforms
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_recipe_app/database/app_database.dart';
import 'package:flutter_recipe_app/services/ssd_detection_service.dart';
import 'package:flutter_recipe_app/models/recipe_image.dart';

class GalleryScreen extends StatefulWidget {
  final String recipeUuid;
  final String recipeName;

  const GalleryScreen({
    Key? key,
    required this.recipeUuid,
    required this.recipeName,
  }) : super(key: key);

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  final AppDatabase _db = AppDatabase();
  final SSDObjectDetectionService _objectDetectionService = SSDObjectDetectionService();
  List<Photo> _photos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _objectDetectionService.initialize();
  }

  @override
  void dispose() {
    _objectDetectionService.dispose();
    super.dispose();
  }

  // Format detected objects into a readable string
  String _formatDetectedObjects(List<DetectedObject> objects) {
    if (objects.isEmpty) {
      return 'No objects detected';
    }

    // Sort by confidence (highest first)
    final sortedObjects = List<DetectedObject>.from(objects)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    // Take top 3 objects
    final topObjects = sortedObjects.take(3).toList();

    // Format as a string
    return topObjects.map((obj) => 
      '${obj.label} (${(obj.confidence * 100).toStringAsFixed(1)}%)'
    ).join(', ');
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await _db.getPhotosForRecipe(widget.recipeUuid);
      setState(() {
        _photos = photos;
      });
    } catch (e) {
      print('Error loading photos: $e');
      _showSnackBar('Error loading photos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      // Read image as bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Skip file operations on web platform
      if (kIsWeb) {
        // On web, we can't use File operations, so we'll skip object detection
        // and just save the image with a placeholder for detected objects
        final photo = PhotosCompanion.insert(
          recipeUuid: widget.recipeUuid,
          photoName: image.name,
          detectedInfo: 'Object detection not available on web',
          pict: imageBytes,
        );

        await _db.insertPhoto(photo);
        await _loadPhotos();
        return;
      }

      // Save image to a temporary file (non-web platforms only)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${path.basename(image.path)}');
      await tempFile.writeAsBytes(imageBytes);

      // Detect objects in the image
      final detectedObjects = await _objectDetectionService.detectObjects(tempFile.path);

      // Convert detected objects to a string representation
      final detectedInfo = _formatDetectedObjects(detectedObjects);

      // Save to database
      final photo = PhotosCompanion.insert(
        recipeUuid: widget.recipeUuid,
        photoName: image.name,
        detectedInfo: detectedInfo,
        pict: imageBytes,
      );

      await _db.insertPhoto(photo);
      await _loadPhotos();
    } catch (e) {
      print('Error processing image: $e');
      _showSnackBar('Error processing image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    try {
      await _db.deletePhoto(photoId);
      await _loadPhotos();
    } catch (e) {
      print('Error deleting photo: $e');
      _showSnackBar('Error deleting photo: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
      return const Center(
        child: Text('No photos yet. Add some using the camera or gallery.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.memory(
                      photo.pict,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        photo.detectedInfo,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deletePhoto(photo.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos: ${widget.recipeName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPhotoGrid(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _pickImage(ImageSource.camera),
            tooltip: 'Take Photo',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => _pickImage(ImageSource.gallery),
            tooltip: 'Choose from Gallery',
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
