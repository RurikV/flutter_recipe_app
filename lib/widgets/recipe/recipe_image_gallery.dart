import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/recipe_image.dart';
import '../../services/image_service.dart';
import '../../services/object_detection_service.dart';

class RecipeImageGallery extends StatefulWidget {
  final List<RecipeImage> images;
  final Function(List<RecipeImage>) onImagesChanged;
  final bool isEditable;

  const RecipeImageGallery({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.isEditable = false,
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
    _objectDetectionService = GetIt.instance<ObjectDetectionService>();
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
    final detectedObjects = await _objectDetectionService.detectObjects(image.path);

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
  void dispose() {
    _pageController.dispose();
    // No need to call dispose() on _objectDetectionService as it's a singleton
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.images.isEmpty)
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
            ),
          )
        else
          Stack(
            children: [
              Container(
                height: 200,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final image = widget.images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image
                          image.path.startsWith('http')
                              ? Image.network(
                                  image.path,
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
                                )
                              : Image.file(
                                  File(image.path),
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
                                ),

                          // Detected objects overlay
                          if (image.detectedObjects.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black.withAlpha(128),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Detected Objects:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...image.detectedObjects.map((obj) {
                                      return Text(
                                        '${obj.label} (${(obj.confidence * 100).toStringAsFixed(1)}%)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Indicators
              if (widget.images.length > 1)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.images.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key
                              ? Colors.white
                              : Colors.white.withAlpha(102),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Remove button
              if (widget.isEditable)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _removeImage(_currentIndex),
                  ),
                ),
            ],
          ),

        // Add image buttons
        if (widget.isEditable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                  label: const Text('Pick Image'),
                  onPressed: _isProcessing ? null : _pickImage,
                ),
              ],
            ),
          ),

        // Processing indicator
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
