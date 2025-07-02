# SSD MobileNet v1 Model

This directory should contain the SSD MobileNet v1 TensorFlow Lite model file.

## How to download the model

1. Download the SSD MobileNet v1 model from the TensorFlow model repository:
   - Visit: https://www.tensorflow.org/lite/examples/object_detection/overview
   - Or download directly from: https://tfhub.dev/tensorflow/lite-model/ssd_mobilenet_v1/1/metadata/1

2. Rename the downloaded file to `ssd_mobilenet.tflite` and place it in this directory.

## Model Information

- Input size: 300x300 pixels
- Output: Bounding boxes, class indices, confidence scores, and number of detections
- Classes: 91 object classes (see ssd_mobilenet_labels.txt)

## Usage

This model is used by the `SSDObjectDetectionService` class in `ssd_object_detection_service.dart` to detect objects in images.
