import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import '../../models/recipe_image.dart';
import 'image_source_dialog.dart';

/// A handler class that manages photo capture and selection operations.
class PhotoCaptureHandler {
  final ImageService _imageService = ImageService();
  
  /// Shows a dialog to select the image source (camera or gallery)
  /// and handles the selected option.
  Future<void> showImageSourceDialog({
    required BuildContext context,
    required Function(RecipeImage) onImageCaptured,
  }) async {
    ImageSourceDialog.show(
      context: context,
      onCameraSelected: () => _takePhoto(context, onImageCaptured),
      onGallerySelected: () => _pickImage(context, onImageCaptured),
    );
  }

  /// Takes a photo using the camera
  Future<void> _takePhoto(
    BuildContext context, 
    Function(RecipeImage) onImageCaptured,
  ) async {
    // Store the context before the async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final recipeImage = await _imageService.takePhoto();
      if (recipeImage != null) {
        onImageCaptured(recipeImage);

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Фото добавлено')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении фото: $e')),
      );
    }
  }

  /// Picks an image from the gallery
  Future<void> _pickImage(
    BuildContext context, 
    Function(RecipeImage) onImageCaptured,
  ) async {
    // Store the context before the async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final recipeImage = await _imageService.pickImage();
      if (recipeImage != null) {
        onImageCaptured(recipeImage);

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Фото добавлено')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении фото: $e')),
      );
    }
  }
}