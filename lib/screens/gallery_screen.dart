import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_master/services/classification/object_detection_service.dart';
import 'package:recipe_master/data/models/recipe_image.dart' as model;

// Simple photo model for temporary use
class SimplePhoto {
  final int id;
  final String recipeUuid;
  final String photoName;
  final String detectedInfo;
  final String imagePath;

  SimplePhoto({
    required this.id,
    required this.recipeUuid,
    required this.photoName,
    required this.detectedInfo,
    required this.imagePath,
  });
}

class GalleryScreen extends StatefulWidget {
  final String recipeUuid;
  final String recipeName;
  final ObjectDetectionService objectDetectionService;

  const GalleryScreen({
    super.key,
    required this.recipeUuid,
    required this.recipeName,
    required this.objectDetectionService,
  });

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  late final ObjectDetectionService _objectDetectionService;
  final List<SimplePhoto> _photos = [];
  bool _isLoading = false;
  int _nextPhotoId = 1; // Simple counter for photo IDs

  @override
  void initState() {
    super.initState();
    // Use the injected object detection service
    _objectDetectionService = widget.objectDetectionService;
    // Initialize the service
    _objectDetectionService.initialize();
    // No need to load photos as we're not using the database
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Format detected objects into a readable string
  String _formatDetectedObjects(List<ServiceDetectedObject> objects) {
    if (objects.isEmpty) {
      return 'No objects detected';
    }

    // Sort by confidence (highest first)
    final sortedObjects = List<ServiceDetectedObject>.from(objects)
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
      final XFile? image = await _selectImage(source);
      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      final String savedImagePath = await _saveImageToStorage(image);
      final String detectedInfo = await _detectObjectsInImage(savedImagePath);

      final photo = _createPhotoModel(image, savedImagePath, detectedInfo);

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

  Future<XFile?> _selectImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(
      source: source,
      maxHeight: 800,
      maxWidth: 800,
    );
  }

  Future<String> _saveImageToStorage(XFile image) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${path.basename(image.path)}');

    // Copy the file instead of reading bytes and writing them
    await File(image.path).copy(tempFile.path);

    return tempFile.path;
  }

  Future<String> _detectObjectsInImage(String imagePath) async {
    final recipeImage = model.RecipeImage(path: imagePath);
    final serviceDetectedObjects = await _objectDetectionService.detectObjects(recipeImage);
    return _formatDetectedObjects(serviceDetectedObjects);
  }

  SimplePhoto _createPhotoModel(XFile image, String imagePath, String detectedInfo) {
    return SimplePhoto(
      id: _nextPhotoId++,
      recipeUuid: widget.recipeUuid,
      photoName: image.name,
      detectedInfo: detectedInfo,
      imagePath: imagePath,
    );
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
                    child: Image.file(
                      File(photo.imagePath),
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
