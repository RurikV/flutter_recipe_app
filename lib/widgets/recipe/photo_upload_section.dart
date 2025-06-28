import 'package:flutter/material.dart';
import '../../services/image_service.dart';

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
        widget.controller.text = recipeImage.path;
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
        widget.controller.text = recipeImage.path;
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
            child: Column(
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
            ),
          ),
        ),
      ),
    );
  }
}
