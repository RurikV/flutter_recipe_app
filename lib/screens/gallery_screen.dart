import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' as f;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_recipe_app/database/app_database.dart';
import 'package:flutter_recipe_app/utils/gallery_utils.dart';
import 'package:flutter_recipe_app/utils/tflite_isolate.dart';

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
  List<Photo> _photos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
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

      // Load labels file on the main isolate
      final labelsContent = await rootBundle.loadString('assets/models/labels.txt');

      // Process image with TensorFlow Lite
      final outputJson = await f.compute(
        TfliteIsolate.runModelOnBinary,
        [
          imageBytes,
          labelsContent,
          'assets/models/model_unquant.tflite',
        ],
      );

      // Parse the result
      final Map<String, dynamic> resultMap = json.decode(outputJson);

      // Check if there's an error
      if (resultMap.containsKey('error')) {
        print(resultMap['error']);
      }

      final TfliteDto tfliteObject = TfliteDto.fromJson(resultMap);

      // Save to database
      final photo = PhotosCompanion.insert(
        recipeUuid: widget.recipeUuid,
        photoName: image.name,
        detectedInfo: tfliteObject.toString(),
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
