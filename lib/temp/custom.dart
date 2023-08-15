// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
//
// class PriorsGenerator {
//   static const List<List<int>> minSizes = [
//     [10, 16, 24],
//     [32, 48],
//     [64, 96],
//     [128, 192, 256]
//   ];
//   static const List<int> steps = [8, 16, 32, 64];
//
//   List<List<double>> generatePriors(List<int> inputShape) {
//     int width = inputShape[0];
//     int height = inputShape[1];
//     List<List<double>> priors = [];
//
//     for (int k = 0; k < steps.length; k++) {
//       int featureMapWidth = (width / steps[k]).floor();
//       int featureMapHeight = (height / steps[k]).floor();
//
//       for (int i = 0; i < featureMapHeight; i++) {
//         for (int j = 0; j < featureMapWidth; j++) {
//           for (var size in minSizes[k]) {
//             double sKx = size / width;
//             double sKy = size / height;
//
//             double cx = (j + 0.5) * steps[k] / width;
//             double cy = (i + 0.5) * steps[k] / height;
//
//             priors.add([cx, cy, sKx, sKy]);
//           }
//         }
//       }
//     }
//     return priors;
//   }
// }
//
// Float32List _preprocessImage(img.Image image) {
//   Float32List convertedBytes = Float32List(120 * 160 * 3);
//   int pixelIndex = 0;
//
//   for (int i = 0; i < 120; i++) {
//     for (int j = 0; j < 160; j++) {
//       var pixel = image.getPixel(j, i);
//       convertedBytes[pixelIndex++] = (pixel.r - 128) / 128.0;
//       convertedBytes[pixelIndex++] = (pixel.g - 128) / 128.0;
//       convertedBytes[pixelIndex++] = (pixel.b - 128) / 128.0;
//     }
//   }
//   return convertedBytes;
// }
//
// class TFLiteModel {
//   late Interpreter interpreter;
//
//   Future<void> loadModel(String modelPath) async {
//     interpreter = await Interpreter.fromAsset(modelPath);
//   }
//
//   List<dynamic> runInference(Float32List input) {
//     // Create one dynamic list to hold the outputs
//     var outputLocations = List.generate(1076, (_) => List.filled(2, 0.0)); // Bounding boxes (Identity)
//     var outputScores = List.generate(1076, (_) => List.filled(1, 0.0)); // Confidence scores (Identity_1)
//     var outputLandmarks = List.generate(1076, (_) => List.filled(14, 0.0)); // Landmarks (Identity_2)
//
//     try {
//       var reshapedInput = input.reshape([1, 120, 160, 3]);
//       if (reshapedInput == null || reshapedInput.isEmpty) {
//         print("Input is null or has invalid shape.");
//         return [];
//       }
//
//       // Run inference: passing a List of tensors
//       List<Object> inputs = [reshapedInput];  // Input tensor
//       List<Object> outputs = [outputLocations, outputScores, outputLandmarks];  // Output tensors
//
//       var ouput = interpreter.runInference(inputs);  // Run inference with inputs and outputs
//
//       // Return the outputs
//       return [outputLocations, outputScores, outputLandmarks];
//     } catch (e) {
//       print("Error during inference: $e");
//       return [];
//     }
//   }
// }
//
// class Face extends StatefulWidget {
//   final Medium image;
//
//   const Face({Key? key, required this.image}) : super(key: key);
//
//   @override
//   State<Face> createState() => _FaceState();
// }
//
// class _FaceState extends State<Face> {
//   late TFLiteModel _tfliteModel;
//   List<List<double>> detectedFaces = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeModel();
//     processImage();
//   }
//
//   Future<void> _initializeModel() async {
//     try {
//       _tfliteModel = TFLiteModel();
//       await _tfliteModel.loadModel('assets/yunet.tflite');
//       print("TFLite model loaded successfully");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> processImage() async {
//     try {
//       // Convert the widget image to raw bytes
//       File? imageFile = await widget.image.getFile();
//       final imageBytes = await imageFile.readAsBytes();
//       final originalImage = img.decodeImage(imageBytes);
//       if (originalImage == null) {
//         print("Image decoding failed.");
//         return;
//       }
//
//       // Preprocess the image (resize and normalize)
//       Float32List input = _preprocessImage(originalImage);
//
//       // Generate priors and run inference
//       PriorsGenerator priorsGenerator = PriorsGenerator();
//       List<List<double>> priors = priorsGenerator.generatePriors([160, 160]);
//
//       List<dynamic> output = await _tfliteModel.runInference(input);
//       if (output.isEmpty) {
//         print("Inference output is empty");
//         return;
//       }
//
//       // Decode the output
//       List<List<double>> decodedDetections = decodeOutput(
//           output, priors, [160, 160]);
//
//       // Apply NMS
//       if (decodedDetections.isEmpty) {
//         print("No detections to apply NMS");
//         return;
//       }
//
//       setState(() {
//         detectedFaces = decodedDetections;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error in processing image: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   List<List<double>> decodeOutput(List<dynamic> output,
//       List<List<double>> priors,
//       List<int> inputShape,) {
//     final locations = output[0]; // Output locations
//     final confidences = output[1]; // Output scores
//     final iouScores = output[2]; // Output IOU scores
//
//     final int numDetections = locations.length;
//     final List<List<double>> decoded = [];
//     final List<double> scales = [
//       inputShape[0].toDouble(),
//       inputShape[1].toDouble()
//     ];
//
//     for (int i = 0; i < numDetections; i++) {
//       final List<double> loc = locations[i];
//       final List<double> prior = priors[i];
//
//       // Compute bounding box
//       double cx = prior[0] + loc[0] * 0.1 * prior[2];
//       double cy = prior[1] + loc[1] * 0.1 * prior[3];
//       double w = prior[2] * exp(loc[2] * 0.2);
//       double h = prior[3] * exp(loc[3] * 0.2);
//
//       double xMin = (cx - w / 2) * scales[0];
//       double yMin = (cy - h / 2) * scales[1];
//       double xMax = (cx + w / 2) * scales[0];
//       double yMax = (cy + h / 2) * scales[1];
//
//       // Decode landmarks (optional, depending on model)
//       final List<double> landmarks = [];
//       for (int j = 0; j < 5; j++) {
//         double lx = prior[0] + loc[4 + j * 2] * 0.1 * prior[2];
//         double ly = prior[1] + loc[5 + j * 2] * 0.1 * prior[3];
//         landmarks.addAll([lx * scales[0], ly * scales[1]]);
//       }
//
//       // Compute confidence score
//       double confidence = confidences[i][1]; // Assuming class 1 is the target class
//       double iou = iouScores[i];
//       double score = sqrt(confidence * iou);
//
//       // Only consider detections with significant confidence
//       if (score > 0.6) {
//         decoded.add([xMin, yMin, xMax, yMax, ...landmarks, score]);
//       }
//     }
//
//     return decoded;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Face Detection')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : detectedFaces.isEmpty
//           ? const Center(child: Text('No faces detected.'))
//           : ListView.builder(
//         itemCount: detectedFaces.length,
//         itemBuilder: (context, index) {
//           var detection = detectedFaces[index];
//           return ListTile(
//             title: Text('Face ${index + 1} - Confidence: ${detection.last}'),
//             subtitle: Text('Bounding Box: ${detection.sublist(0, 4)}'),
//           );
//         },
//       ),
//     );
//   }
// }