import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadSection extends StatelessWidget {
  final TextEditingController controller;
  final ImageService _imageService = ImageService();

  PhotoUploadSection({
    super.key,
    required this.controller,
  });

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
    try {
      final recipeImage = await _imageService.takePhoto();
      if (recipeImage != null) {
        controller.text = recipeImage.path;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото добавлено')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении фото: $e')),
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final recipeImage = await _imageService.pickImage();
      if (recipeImage != null) {
        controller.text = recipeImage.path;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото добавлено')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении фото: $e')),
      );
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
                    controller: controller,
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
