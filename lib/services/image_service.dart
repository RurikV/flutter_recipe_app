import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/recipe_image.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Take a photo with the camera
  Future<RecipeImage?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo == null) return null;
      
      // Save the image to the app's documents directory
      final savedImagePath = await _saveImageToLocalStorage(photo);
      
      return RecipeImage(path: savedImagePath);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Pick an image from the gallery
  Future<RecipeImage?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) return null;
      
      // Save the image to the app's documents directory
      final savedImagePath = await _saveImageToLocalStorage(image);
      
      return RecipeImage(path: savedImagePath);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Save the image to local storage and return the path
  Future<String> _saveImageToLocalStorage(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final savedImage = File('${appDir.path}/images/$fileName');
    
    // Create the images directory if it doesn't exist
    await Directory('${appDir.path}/images').create(recursive: true);
    
    // Copy the image to the new location
    await File(image.path).copy(savedImage.path);
    
    return savedImage.path;
  }

  // Load an image from a path
  Future<File?> loadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  // Delete an image
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}