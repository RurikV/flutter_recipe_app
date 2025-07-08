import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../data/models/recipe_image.dart';
import '../../services/image_picker/image_service.dart';
import '../../services/classification/object_detection_service.dart';

class RecipeImageGallery extends StatefulWidget {
  final List<RecipeImage> images;
  final Function(List<RecipeImage>) onImagesChanged;
  final bool isEditable;
  final ObjectDetectionService? objectDetectionService;

  const RecipeImageGallery({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.isEditable = false,
    this.objectDetectionService,
  });

  @override
  State<RecipeImageGallery> createState() => _RecipeImageGalleryState();
}

class _RecipeImageGalleryState extends State<RecipeImageGallery> {
  final ImageService _imageService = ImageService();
  late final ObjectDetectionService _objectDetectionService;
  int _currentIndex = 0;
  bool _isProcessing = false;

  // Controller for the PageView
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Use the provided service or get it from GetIt
    _objectDetectionService = widget.objectDetectionService ?? GetIt.instance<ObjectDetectionService>();
    // Initialize the object detection service if needed
    _objectDetectionService.initialize();
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isProcessing = true;
    });

    final RecipeImage? newImage = await _imageService.takePhoto();
    if (newImage != null) {
      await _processImage(newImage);
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _pickImage() async {
    setState(() {
      _isProcessing = true;
    });

    final RecipeImage? newImage = await _imageService.pickImage();
    if (newImage != null) {
      await _processImage(newImage);
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _processImage(RecipeImage image) async {
    // Detect objects in the image
    final serviceDetectedObjects = await _objectDetectionService.detectObjects(image);

    // Convert ServiceDetectedObject to DetectedObject
    final detectedObjects = serviceDetectedObjects
        .map((obj) => obj.toModelDetectedObject())
        .toList();

    // Create a new image with the detected objects
    final updatedImage = RecipeImage(
      path: image.path,
      detectedObjects: detectedObjects,
    );

    // Add the image to the list
    final updatedImages = List<RecipeImage>.from(widget.images)..add(updatedImage);

    // Update the parent widget
    widget.onImagesChanged(updatedImages);

    // Update the current index to show the new image
    setState(() {
      _currentIndex = updatedImages.length - 1;
    });
  }

  void _removeImage(int index) {
    final updatedImages = List<RecipeImage>.from(widget.images);

    // Delete the image file
    _imageService.deleteImage(updatedImages[index].path);

    // Remove the image from the list
    updatedImages.removeAt(index);

    // Update the parent widget
    widget.onImagesChanged(updatedImages);

    // Update the current index
    setState(() {
      _currentIndex = updatedImages.isEmpty ? 0 : _currentIndex % updatedImages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image gallery
        if (widget.images.isNotEmpty)
          _buildImageGallery()
        else
          _buildEmptyState(),

        // Image controls
        if (widget.isEditable)
          _buildImageControls(),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        // Main image display
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // PageView for swiping through images
              PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildImageItem(widget.images[index]);
                },
              ),

              // Loading indicator
              if (_isProcessing)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Delete button (only in edit mode)
              if (widget.isEditable && widget.images.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeImage(_currentIndex),
                  ),
                ),
            ],
          ),
        ),

        // Image indicators
        if (widget.images.length > 1)
          _buildImageIndicators(),
      ],
    );
  }

  Widget _buildImageItem(RecipeImage image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image - handle both local files and remote URLs
        _buildImage(image.path),

        // Detected objects overlay
        if (image.detectedObjects.isNotEmpty)
          CustomPaint(
            painter: ObjectDetectionPainter(
              image.detectedObjects,
              MediaQuery.of(context).size,
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // For remote URLs, use Image.network
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    } else {
      // For local files, use Image.file
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildImageIndicators() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.images.length,
          (index) => _buildIndicator(index == _currentIndex),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }

  Widget _buildEmptyState() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[200],
        child: const Center(
          child: Text('No images'),
        ),
      ),
    );
  }

  Widget _buildImageControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            onPressed: _isProcessing ? null : _takePhoto,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            onPressed: _isProcessing ? null : _pickImage,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing bounding boxes around detected objects
class ObjectDetectionPainter extends CustomPainter {
  final List<DetectedObject> detectedObjects;
  final Size screenSize;

  ObjectDetectionPainter(this.detectedObjects, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final object in detectedObjects) {
      // Convert normalized coordinates to actual pixel values
      final rect = ui.Rect.fromLTRB(
        (object.boundingBox?['left'] ?? 0) * size.width,
        (object.boundingBox?['top'] ?? 0) * size.height,
        (object.boundingBox?['right'] ?? 0) * size.width,
        (object.boundingBox?['bottom'] ?? 0) * size.height,
      );

      // Draw bounding box
      canvas.drawRect(rect, paint);

      // Draw label
      final textSpan = TextSpan(
        text: '${object.label} (${(object.confidence * 100).toStringAsFixed(0)}%)',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          backgroundColor: Colors.red,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(ObjectDetectionPainter oldDelegate) {
    return oldDelegate.detectedObjects != detectedObjects;
  }
}
