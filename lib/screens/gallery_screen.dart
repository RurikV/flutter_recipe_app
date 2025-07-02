import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_recipe_app/services/object_detection_service.dart';
import 'package:flutter_recipe_app/models/recipe_image.dart';

// Simple photo model for temporary use
class SimplePhoto {
  final int id;
  final String recipeUuid;
  final String photoName;
  final String detectedInfo;
  final Uint8List pict;

  SimplePhoto({
    required this.id,
    required this.recipeUuid,
    required this.photoName,
    required this.detectedInfo,
    required this.pict,
  });
}

class GalleryScreen extends StatefulWidget {
  final String recipeUuid;
  final String recipeName;

  const GalleryScreen({
    super.key,
    required this.recipeUuid,
    required this.recipeName,
  });

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  final GetIt _getIt = GetIt.instance;
  late final ObjectDetectionService _objectDetectionService;
  final List<SimplePhoto> _photos = [];
  bool _isLoading = false;
  int _nextPhotoId = 1; // Simple counter for photo IDs

  @override
  void initState() {
    super.initState();
    // Get the object detection service from GetIt
    _objectDetectionService = _getIt<ObjectDetectionService>();
    // No need to load photos as we're not using the database
  }

  @override
  void dispose() {
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

      // Save image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${path.basename(image.path)}');
      await tempFile.writeAsBytes(imageBytes);

      // Detect objects in the image
      final detectedObjects = await _objectDetectionService.detectObjects(tempFile.path);

      // Convert detected objects to a string representation
      final detectedInfo = _formatDetectedObjects(detectedObjects);

      // Create a simple photo object
      final photo = SimplePhoto(
        id: _nextPhotoId++,
        recipeUuid: widget.recipeUuid,
        photoName: image.name,
        detectedInfo: detectedInfo,
        pict: imageBytes,
      );

      // Add to our local list
      setState(() {
        _photos.add(photo);
        _isLoading = false;
      });
    } catch (e) {
      print('Error processing image: $e');
      _showSnackBar('Error processing image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deletePhoto(int photoId) {
    setState(() {
      _photos.removeWhere((photo) => photo.id == photoId);
    });
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
