import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import '../../models/recipe_image.dart';

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
  final ImageService _imageService = ImageService();
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

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите источник'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Камера'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto(context);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Галерея'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    // Store the context before the async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final recipeImage = await _imageService.takePhoto();
      if (recipeImage != null && mounted) {
        setState(() {
          _images.add(recipeImage);
          // Update the controller with a JSON string representation of the images list
          widget.controller.text = RecipeImage.encodeList(_images);
        });

        // Only show SnackBar if the widget is still mounted
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Фото добавлено')),
          );
        }
      }
    } catch (e) {
      // Only show error SnackBar if the widget is still mounted
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении фото: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    // Store the context before the async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final recipeImage = await _imageService.pickImage();
      if (recipeImage != null && mounted) {
        setState(() {
          _images.add(recipeImage);
          // Update the controller with a JSON string representation of the images list
          widget.controller.text = RecipeImage.encodeList(_images);
        });

        // Only show SnackBar if the widget is still mounted
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Фото добавлено')),
          );
        }
      }
    } catch (e) {
      // Only show error SnackBar if the widget is still mounted
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении фото: $e')),
        );
      }
    }
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
