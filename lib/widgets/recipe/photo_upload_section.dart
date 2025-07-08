import 'package:flutter/material.dart';
import '../../../data/models/recipe_image.dart';
import 'photo_capture_handler.dart';

class PhotoUploadSection extends StatefulWidget {
  final TextEditingController controller;

  const PhotoUploadSection({
    super.key,
    required this.controller,
  });

  @override
  State<PhotoUploadSection> createState() => _PhotoUploadSectionState();
}

class _PhotoUploadSectionState extends State<PhotoUploadSection> {
  final PhotoCaptureHandler _photoCaptureHandler = PhotoCaptureHandler();
  List<RecipeImage> _images = [];

  @override
  void initState() {
    super.initState();
    // Initialize _images from controller.text if it's not empty
    if (widget.controller.text.isNotEmpty) {
      try {
        _images = RecipeImage.decodeList(widget.controller.text);
      } catch (e) {
        // If decoding fails, create a single RecipeImage from the path
        _images = [RecipeImage(path: widget.controller.text)];
      }
    }
  }

  /// Handles the image capture process
  void _handleImageCapture(RecipeImage recipeImage) {
    if (mounted) {
      setState(() {
        _images.add(recipeImage);
        // Update the controller with a JSON string representation of the images list
        widget.controller.text = RecipeImage.encodeList(_images);
      });
    }
  }

  /// Shows the image source dialog
  void _showImageSourceDialog(BuildContext context) {
    _photoCaptureHandler.showImageSourceDialog(
      context: context,
      onImageCaptured: _handleImageCapture,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 17),
      child: Center(
        child: GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: 396,
            height: 215,
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              border: Border.all(
                color: const Color(0xFF165932),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: _images.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Color(0xFF165932),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Добавить фото рецепта',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF165932),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hidden field for image URL
                      Opacity(
                        opacity: 0,
                        child: TextFormField(
                          controller: widget.controller,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      // Display a placeholder with text indicating that photos have been added
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFFECECEC),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Color(0xFF165932),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_images.length} фото добавлено',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF165932),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Overlay with count of images
                      if (_images.length > 1)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${_images.length - 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Add icon to indicate that more photos can be added
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF165932),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Hidden field for image URL
                      Opacity(
                        opacity: 0,
                        child: TextFormField(
                          controller: widget.controller,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
