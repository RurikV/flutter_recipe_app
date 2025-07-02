import 'package:flutter/material.dart';

/// A dialog that allows the user to choose between camera and gallery as the source for an image.
class ImageSourceDialog extends StatelessWidget {
  /// Callback when camera option is selected
  final VoidCallback onCameraSelected;
  
  /// Callback when gallery option is selected
  final VoidCallback onGallerySelected;

  const ImageSourceDialog({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  /// Shows the image source dialog
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageSourceDialog(
          onCameraSelected: onCameraSelected,
          onGallerySelected: onGallerySelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onCameraSelected();
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
                onGallerySelected();
              },
            ),
          ],
        ),
      ),
    );
  }
}