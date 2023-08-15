// // //
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // // import 'package:photo_gallery/photo_gallery.dart';
// // // import 'dart:io';
// // // import 'package:image/image.dart' as i; // Make sure to add the image package in pubspec.yaml
// // // import 'package:fast_image_resizer/fast_image_resizer.dart';
// // //
// // // class FaceDetectionScreen extends StatefulWidget {
// // //   final List<Medium> images; // Changed to accept a list of Medium objects
// // //
// // //   const FaceDetectionScreen({super.key, required this.images});
// // //
// // //   @override
// // //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // // }
// // //
// // // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// // //   late cv2.FaceDetectorYN detector;
// // //   bool isProcessing = false;
// // //   List<Uint8List> croppedFaces = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadModel();
// // //   }
// // //
// // //   Future<void> _loadModel() async {
// // //     // Load the ONNX model from assets
// // //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// // //     final buffer = byteData.buffer.asUint8List();
// // //
// // //     // Create a temporary file to save the model
// // //     final tempDir = Directory.systemTemp;
// // //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// // //
// // //     // Write the model to the temp file
// // //     await modelFile.writeAsBytes(buffer);
// // //
// // //     // Initialize the detector
// // //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", ( 640, 640), 0.9, 0.05, 1);
// // //     print("Model loaded successfully.");
// // //     print(detector.getTopK());
// // //
// // //     // Start processing the images once the model is loaded
// // //     await processImages(widget.images);
// // //   }
// // //
// // //   Future<void> processImages(List<Medium> mediums) async {
// // //     setState(() {
// // //       isProcessing = true;
// // //     });
// // //
// // //     // Process images in batches
// // //     for (int i = 0; i < 20; i += 20) {
// // //       List<Medium> batch = mediums.sublist(i, i + 20 > 20 ? 20 : i + 20);
// // //       await Future.wait(batch.map((medium) async => await processImage(medium)));
// // //     }
// // //
// // //     setState(() {
// // //       isProcessing = false;
// // //     });
// // //   }
// // //
// // //   Future<void> processImage(Medium medium) async {
// // //     // Get the image file from the Medium object
// // //     File? imageFile = await medium.getFile();
// // //     if (imageFile == null) {
// // //       print("Failed to get the image file.");
// // //       return;
// // //     }
// // //
// // //     // Read the image
// // //     final imageBytes = await imageFile.readAsBytes();
// // //     cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// // //
// // //     cv2.Mat resizedImg = cv2.resize(img1, (640, 640));
// // //
// // //     // Detect faces
// // //     dynamic detections = detector.detect(resizedImg);
// // //
// // //     // Convert Mat to a List to access its elements
// // //     List<dynamic> detectionsList = detections.toList();
// // //     print("this is detecion list");
// // //     print(detectionsList);
// // //     if (detectionsList.isNotEmpty) {
// // //       // Create a list to hold bounding boxes
// // //       List<List<double>> faces = [];
// // //
// // //       // Extract the detections
// // //       for (var detection in detectionsList) {
// // //         print("this is detecion list instance");
// // //
// // //         print(detection.length);
// // //         print(detection[0]);
// // //         print(detection[3]);
// // //         List<double> faceData = detection; // Adjust based on your model output structure
// // //         faces.add(faceData);
// // //       }
// // //
// // //       // Crop faces from the image in batches
// // //       List<File?> croppedFiles = await cropFaces(imageFile, faces);
// // //
// // //       // Convert cropped files to Uint8List for displaying in the UI
// // //       for (var file in croppedFiles) {
// // //         if (file != null) {
// // //           final croppedBytes = await file.readAsBytes();
// // //           setState(() {
// // //             croppedFaces.add(croppedBytes);
// // //           });
// // //         }
// // //       }
// // //
// // //       print("Cropped faces: ${croppedFaces.length}");
// // //     }
// // //   }
// // //
// // //   Future<List<File?>> cropFaces(File imageFile, List<List<double>> faces) async {
// // //     List<File?> croppedFiles = [];
// // //
// // //     // Read the original image
// // //     final originalBytes = await imageFile.readAsBytes();
// // //     i.Image? originalImage = i.decodeImage(originalBytes);
// // //
// // //     if (originalImage == null) return croppedFiles;
// // //
// // //     // Resize the original image to 640x640 for cropping
// // //     ByteData? resizedBytes = await resizeImage(
// // //       Uint8List.fromList(originalBytes),
// // //       width: 640,
// // //       height: 640,
// // //     );
// // //
// // //     if (resizedBytes == null) {
// // //       print("Failed to resize the original image.");
// // //       return croppedFiles;
// // //     }
// // //
// // //     // Convert the resized bytes back to an image
// // //     i.Image resizedImage = i.decodeImage(Uint8List.view(resizedBytes.buffer))!;
// // //
// // //     for (var face in faces) {
// // //       // Assuming the first four values are bounding box coordinates (x1, y1, width, height)
// // //       int x1 = face[0].toInt(); // Top-left x
// // //       int y1 = face[1].toInt(); // Top-left y
// // //       int width = face[2].toInt(); // Width
// // //       int height = face[3].toInt();
// // //
// // //       print("x:$x1, y:$y1, w:$width, h:$height");
// // //
// // //       // Crop the face from the resized image
// // //       i.Image croppedImage = i.copyCrop(resizedImage, x: x1, y: y1, width: width, height: height);
// // //
// // //       // Resize the cropped image if needed (optional)
// // //       ByteData? finalResizedBytes = await resizeImage(
// // //         Uint8List.fromList(i.encodePng(croppedImage)), // Convert cropped image to bytes
// // //         width: 160, // Target width
// // //         height: 160, // Target height
// // //       );
// // //
// // //       if (finalResizedBytes != null) {
// // //         final tempDir = Directory.systemTemp;
// // //         File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
// // //         await croppedFile.writeAsBytes(Uint8List.view(finalResizedBytes.buffer));
// // //         croppedFiles.add(croppedFile);
// // //       } else {
// // //         croppedFiles.add(null);
// // //       }
// // //     }
// // //
// // //     return croppedFiles;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Face Detection')),
// // //       body: Column(
// // //         children: [
// // //           if (isProcessing) const CircularProgressIndicator(),
// // //           if (!isProcessing && croppedFaces.isNotEmpty)
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: croppedFaces.length,
// // //                 itemBuilder: (context, index) {
// // //                   return Image.memory(croppedFaces[index]);
// // //                 },
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // // import 'package:photo_gallery/photo_gallery.dart';
// // // import 'dart:io';
// // //
// // // class FaceDetectionScreen extends StatefulWidget {
// // //   final List<Medium> images; // List of images to process
// // //
// // //   const FaceDetectionScreen({super.key, required this.images});
// // //
// // //   @override
// // //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // // }
// // //
// // // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// // //   late cv2.FaceDetectorYN detector;
// // //   bool isProcessing = false;
// // //   List<Uint8List> croppedFaces = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadModel();
// // //   }
// // //
// // //   Future<void> _loadModel() async {
// // //     // Load the ONNX model from assets
// // //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// // //     final buffer = byteData.buffer.asUint8List();
// // //
// // //     // Create a temporary file to save the model
// // //     final tempDir = Directory.systemTemp;
// // //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// // //
// // //     // Write the model to the temp file
// // //     await modelFile.writeAsBytes(buffer);
// // //
// // //     // Initialize the detector
// // //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", (640, 640), 0.9, 0.05, 10); // Reduced topK to 10
// // //
// // //     print("Model loaded successfully.");
// // //     // Process the images
// // //     await processImages(widget.images);
// // //   }
// // //
// // //   Future<void> processImages(List<Medium> mediums) async {
// // //     setState(() {
// // //       isProcessing = true;
// // //     });
// // //
// // //     int batchSize = 100;  // Process images in smaller batches
// // //     for (int i = 0; i < 200; i += batchSize) {
// // //       List<Medium> batch = mediums.sublist(i, (i + batchSize > 200) ? 200 : i + batchSize);
// // //
// // //       await Future.wait(batch.map((medium) async => await processImage(medium)));  // Asynchronous processing of images
// // //     }
// // //
// // //     setState(() {
// // //       isProcessing = false;
// // //     });
// // //     print("lenght of croppd faces");
// // //     print(croppedFaces.length);
// // //   }
// // //
// // //   Future<void> processImage(Medium medium) async {
// // //     // Get the image file from the Medium object
// // //     File? imageFile = await medium.getFile();
// // //     if (imageFile == null) {
// // //       print("Failed to get the image file.");
// // //       return;
// // //     }
// // //
// // //     // Read the image using OpenCV
// // //     final imageBytes = await imageFile.readAsBytes();
// // //     cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// // //     double wi = img1.width/640;
// // //
// // //
// // //     double he = img1.height/640;
// // //     // Resize the image to 640x640 for face detection
// // //     cv2.Mat resizedImg = cv2.resize(img1, (640, 640 ));
// // //
// // //     // Detect faces
// // //     dynamic detections = detector.detect(resizedImg);
// // //
// // //     // Convert Mat to a List to access its elements
// // //     List<dynamic> detectionsList = detections.toList();
// // //     if (detectionsList.isNotEmpty) {
// // //       // Create a list to hold bounding boxes
// // //       List<List<double>> faces = [];
// // //
// // //       // Extract the detections
// // //       for (var detection in detectionsList) {
// // //         List<double> faceData = detection; // Adjust based on your model output structure
// // //         faces.add(faceData);
// // //       }
// // //
// // //       // Crop faces from the image
// // //       await cropAndResizeFaces( img1, faces, wi, he);
// // //     }
// // //   }
// // //
// // //   Future<void> cropAndResizeFaces( cv2.Mat img1, List<List<double>> faces, double w, double h) async {
// // //     List<Uint8List> croppedFacesBatch = [];
// // //     print("priting isnise cropandriee");
// // //     print(img1.width);
// // //     print(img1.width*w);
// // //     // Loop through detected faces and crop them using OpenCV
// // //     for (var face in faces) {
// // //       double x1 = (face[0]*w); // Top-left x
// // //       double y1 = (face[1]*h);// Top-left y
// // //       double width = (face[2]*w); // Width
// // //       double height = (face[3]*h); // Height
// // //
// // //       print("x:$x1, y:$y1, w:$width, h:$height");
// // //
// // //       cv2.Point2f center = cv2.Point2f(x1.toInt() + width.toInt() / 2, y1.toInt() + height.toInt() / 2);
// // //
// // //       cv2.Mat croppedFace = cv2.getRectSubPix(img1, (width.toInt(), height.toInt()) , center);
// // //
// // //
// // //       // Resize the cropped face to a fixed size (160x160)
// // //       cv2.Mat resizedFace = cv2.resize(croppedFace, (160, 160), );
// // //
// // //       // Encode the resized face to PNG format and convert it to Uint8List
// // //       final imencodeResult = cv2.imencode('.png', resizedFace);
// // //
// // //       final success = imencodeResult.$1; // Assuming item1 is the success flag
// // //       final resizedFaceBytes = imencodeResult.$2; // Assuming item2 is the encoded image
// // //
// // //       if (!success) {
// // //         print("Image encoding failed.");
// // //         return null; // Handle the error as needed
// // //       }
// // //
// // //
// // //       // Add the face to the list to display
// // //       croppedFacesBatch.add(resizedFaceBytes);
// // //     }
// // //
// // //     setState(() {
// // //       croppedFaces.addAll(croppedFacesBatch); // Add the batch of cropped faces to the state
// // //     });
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Face Detection')),
// // //       body: Column(
// // //         children: [
// // //           if (isProcessing) const CircularProgressIndicator(),
// // //           if (!isProcessing && croppedFaces.isNotEmpty)
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: croppedFaces.length,
// // //                 itemBuilder: (context, index) {
// // //                   return Image.memory(croppedFaces[index]);
// // //                 },
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // // import 'package:photo_gallery/photo_gallery.dart';
// // // import 'dart:io';
// // // import 'package:flutter/foundation.dart';
// // //
// // // class FaceDetectionScreen extends StatefulWidget {
// // //   final List<Medium> images; // List of images to process
// // //
// // //   const FaceDetectionScreen({super.key, required this.images});
// // //
// // //   @override
// // //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // // }
// // //
// // // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// // //   late cv2.FaceDetectorYN detector;
// // //   bool isProcessing = false;
// // //   List<Uint8List> croppedFaces = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadModel();
// // //   }
// // //
// // //   Future<void> _loadModel() async {
// // //     // Load the ONNX model from assets
// // //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// // //     final buffer = byteData.buffer.asUint8List();
// // //
// // //     // Create a temporary file to save the model
// // //     final tempDir = Directory.systemTemp;
// // //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// // //
// // //     // Write the model to the temp file
// // //     await modelFile.writeAsBytes(buffer);
// // //
// // //     // Initialize the detector
// // //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", (640, 640), 0.9, 0.05, 10); // Reduced topK to 10
// // //
// // //     print("Model loaded successfully.");
// // //     // Process the images
// // //     await processImages(widget.images);
// // //   }
// // //
// // //   Future<void> processImages(List<Medium> mediums) async {
// // //     setState(() {
// // //       isProcessing = true;
// // //     });
// // //
// // //     int batchSize = 50; // Process images in smaller batches
// // //     for (int i = 0; i < 100; i += batchSize) {
// // //       List<Medium> batch = mediums.sublist(i, (i + batchSize > 100) ? 100 : i + batchSize);
// // //      print('preparing batch');
// // //       // Utilize compute function for improved performance, passing the detector instance
// // //       await Future.wait(batch.map((medium) async => await (_processImageWrapper, {'medium': medium, 'detector': detector})));  // Asynchronous processing of images
// // //     }
// // //
// // //     setState(() {
// // //       isProcessing = false;
// // //     });
// // //     print("Length of cropped faces: ${croppedFaces.length}");
// // //   }
// // //
// // //   // Wrapper function for compute, passing detector and medium
// // //    Future<List<Uint8List>> _processImageWrapper(Map<String, dynamic> args) async {
// // //      print('preparing wraper');
// // //
// // //      Medium medium = args['medium'];
// // //     cv2.FaceDetectorYN detector = args['detector'];
// // //     return await _processImage(medium, detector);
// // //   }
// // //
// // //   // No longer static, since it's used with compute
// // //    Future<List<Uint8List>> _processImage(Medium medium, cv2.FaceDetectorYN detector) async {
// // //     // Get the image file from the Medium object
// // //      print('preparing preprovess');
// // //
// // //      File? imageFile = await medium.getFile();
// // //     if (imageFile == null) {
// // //       print("Failed to get the image file.");
// // //       return [];
// // //     }
// // //
// // //     try {
// // //       // Read the image using OpenCV
// // //       final imageBytes = await imageFile.readAsBytes();
// // //       cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// // //       double wi = img1.width / 640;
// // //       double he = img1.height / 640;
// // //       print('preparing scaleing: $wi');
// // //
// // //
// // //
// // //       // Resize the image to 640x640 for face detection
// // //       cv2.Mat resizedImg = cv2.resize(img1, (640, 640));
// // //
// // //       // Detect faces using the passed detector
// // //       dynamic detections = detector.detect(resizedImg);
// // //
// // //       // Convert Mat to a List to access its elements
// // //       List<dynamic> detectionsList = detections.toList();
// // //       List<Uint8List> croppedFacesBatch = [];
// // //       print(detectionsList[0]);
// // //
// // //
// // //       if (detectionsList.isNotEmpty) {
// // //         print("im isnide");
// // //         // Create a list to hold bounding boxes
// // //         List<List<double>> faces = [];
// // //
// // //         // Extract the detections
// // //         for (var detection in detectionsList) {
// // //           List<double> faceData = detection; // Adjust based on your model output structure
// // //           faces.add(faceData);
// // //         }
// // //
// // //         // Crop faces from the image
// // //         croppedFacesBatch = await cropAndResizeFaces(img1, faces, wi, he);
// // //       }
// // //
// // //       // Clean up memory
// // //       img1.dispose();
// // //       resizedImg.dispose();
// // //
// // //       return croppedFacesBatch;
// // //
// // //     } catch (e) {
// // //       print("Error processing image: $e");
// // //       return [];
// // //     }
// // //   }
// // //
// // //   Future<List<Uint8List>> cropAndResizeFaces(cv2.Mat img1, List<List<double>> faces, double w, double h) async {
// // //     List<Uint8List> croppedFacesBatch = [];
// // //     print("Inside cropAndResizeFaces: Image Width: ${img1.width}, Scaled Width: ${img1.width * w}");
// // //
// // //     // Loop through detected faces and crop them using OpenCV
// // //     for (var face in faces) {
// // //       double x1 = (face[0] * w); // Top-left x
// // //       double y1 = (face[1] * h); // Top-left y
// // //       double width = (face[2] * w); // Width
// // //       double height = (face[3] * h); // Height
// // //
// // //       print("x:$x1, y:$y1, w:$width, h:$height");
// // //
// // //       cv2.Point2f center = cv2.Point2f(x1.toInt() + width.toInt() / 2, y1.toInt() + height.toInt() / 2);
// // //       cv2.Mat croppedFace = cv2.getRectSubPix(img1, (width.toInt(), height.toInt()), center);
// // //
// // //       // Resize the cropped face to a fixed size (160x160)
// // //       cv2.Mat resizedFace = cv2.resize(croppedFace, (160, 160));
// // //
// // //       // Encode the resized face to PNG format and convert it to Uint8List
// // //       final imencodeResult = cv2.imencode('.png', resizedFace);
// // //       final success = imencodeResult.$1; // Assuming item1 is the success flag
// // //       final resizedFaceBytes = imencodeResult.$2; // Assuming item2 is the encoded image
// // //
// // //       if (!success) {
// // //         print("Image encoding failed.");
// // //         continue; // Skip this face
// // //       }
// // //
// // //       // Add the face to the list to return
// // //       croppedFacesBatch.add(resizedFaceBytes);
// // //       // croppedFace.dispose();  // Release memory for cropped face
// // //       resizedFace.dispose();   // Release memory for resized face
// // //     }
// // //
// // //     return croppedFacesBatch;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Face Detection')),
// // //       body: Column(
// // //         children: [
// // //           if (isProcessing) const CircularProgressIndicator(),
// // //           if (!isProcessing && croppedFaces.isNotEmpty)
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: croppedFaces.length,
// // //                 itemBuilder: (context, index) {
// // //                   return Image.memory(croppedFaces[index]);
// // //                 },
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // import 'dart:typed_data';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // import 'package:photo_gallery/photo_gallery.dart';
// // import 'dart:io';
// // import 'dart:async';
// // import 'package:fast_image_resizer/fast_image_resizer.dart';
// //
// // class FaceDetectionScreen extends StatefulWidget {
// //   final List<Medium> images; // List of images to process
// //
// //   const FaceDetectionScreen({super.key, required this.images});
// //
// //   @override
// //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // }
// //
// // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// //   late cv2.FaceDetectorYN detector;
// //   bool isProcessing = false;
// //   List<Uint8List> croppedFaces = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadModel();
// //   }
// //
// //   Future<void> _loadModel() async {
// //     // Load the ONNX model from assets
// //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// //     final buffer = byteData.buffer.asUint8List();
// //
// //     // Create a temporary file to save the model
// //     final tempDir = Directory.systemTemp;
// //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// //
// //     // Write the model to the temp file
// //     await modelFile.writeAsBytes(buffer);
// //
// //     // Initialize the detector
// //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", (320, 320), 0.67, 0.05, 10); // Reduced topK to 10
// //
// //     print("Model loaded successfully.");
// //     // Process the images
// //     await processImages(widget.images);
// //   }
// //
// //   Future<void> processImages(List<Medium> mediums) async {
// //     setState(() {
// //       isProcessing = true;
// //     });
// //
// //     int batchSize = 100; // Process images in smaller batches
// //     for (int i = 0; i < 500; i += batchSize) {
// //       List<Medium> batch = mediums.sublist(i, (i + batchSize > 500) ? 500 : i + batchSize);
// //
// //       // Process each image synchronously (without compute)
// //       for (var medium in batch) {
// //         await processImage(medium);
// //       }
// //
// //       print("batch completed");
// //     }
// //
// //     setState(() {
// //       isProcessing = false;
// //     });
// //     print("Length of cropped faces:");
// //     print(croppedFaces.length);
// //   }
// //
// //   Future<void> processImage(Medium medium) async {
// //     try {
// //       // Get the image file from the Medium object
// //       File? imageFile = await medium.getFile();
// //       if (imageFile == null) {
// //         print("Failed to get the image file.");
// //         return;
// //       }
// //
// //       // Read the image using OpenCV
// //       final imageBytes = await imageFile.readAsBytes();
// //       cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// //
// //       if (img1.isEmpty) {
// //         print("Image is empty, skipping.");
// //         return;
// //       }
// //
// //       double wi = img1.width / 320;
// //       double he = img1.height / 320;
// //
// //       // Resize the image to 640x640 for face detection
// //       cv2.Mat resizedImg = cv2.resize(img1, (320, 320));
// //
// //       // Detect faces
// //       dynamic detections = detector.detect(resizedImg);
// //
// //       // Convert Mat to a List to access its elements
// //       List<dynamic> detectionsList = detections.toList();
// //       if (detectionsList.isNotEmpty) {
// //         // Crop faces from the image
// //         await cropAndResizeFaces(img1, detectionsList, wi, he);
// //       }
// //     } catch (e) {
// //       print("Error processing image: $e");
// //     }
// //   }
// //
// //   Future<void> cropAndResizeFaces(cv2.Mat img1, List<dynamic> faces, double w, double h) async {
// //     List<Uint8List> croppedFacesBatch = [];
// //
// //     // Loop through detected faces and crop them using OpenCV
// //     for (var face in faces) {
// //       try {
// //         double x1 = face[0] * w; // Top-left x
// //         double y1 = face[1] * h; // Top-left y
// //         double width = face[2] * w; // Width
// //         double height = face[3] * h; // Height
// //
// //         cv2.Point2f center = cv2.Point2f(x1.toInt() + width.toInt() / 2, y1.toInt() + height.toInt() / 2);
// //
// //         cv2.Mat croppedFace = cv2.getRectSubPix(img1, (width.toInt(), height.toInt()), center);
// //
// //         // Resize the cropped face to a fixed size (160x160)
// //         cv2.Mat resizedFace = cv2.resize(croppedFace, (160, 160));
// //
// //         // Encode the resized face to PNG format and convert it to Uint8List
// //         final imencodeResult = cv2.imencode('.png', resizedFace);
// //         final success = imencodeResult.$1;
// //         final resizedFaceBytes = imencodeResult.$2;
// //
// //         if (!success) {
// //           print("Image encoding failed.");
// //           continue;
// //         }
// //
// //         // Add the face to the list to display
// //         croppedFacesBatch.add(resizedFaceBytes);
// //       } catch (e) {
// //         print("Error cropping/resizing face: $e");
// //       }
// //     }
// //
// //     // Add the batch of cropped faces to the state
// //     setState(() {
// //       croppedFaces.addAll(croppedFacesBatch);
// //     });
// //   }
// //
// //   // Function to clear memory
// //   // Future<void> clearMemory() async {
// //   //   // Call OpenCV garbage collection or manually clean large objects
// //   //   // For example, clear large matrices if ne;eded
// //   //
// //   //
// //   //   print("Memory cleared.");
// //   // }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Face Detection')),
// //       body: Column(
// //         children: [
// //           if (isProcessing) const CircularProgressIndicator(),
// //           if (!isProcessing && croppedFaces.isNotEmpty)
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: croppedFaces.length,
// //                 itemBuilder: (context, index) {
// //                   return Image.memory(croppedFaces[index]);
// //                 },
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }//
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // // import 'package:photo_gallery/photo_gallery.dart';
// // // import 'dart:io';
// // // import 'package:image/image.dart' as i; // Make sure to add the image package in pubspec.yaml
// // // import 'package:fast_image_resizer/fast_image_resizer.dart';
// // //
// // // class FaceDetectionScreen extends StatefulWidget {
// // //   final List<Medium> images; // Changed to accept a list of Medium objects
// // //
// // //   const FaceDetectionScreen({super.key, required this.images});
// // //
// // //   @override
// // //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // // }
// // //
// // // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// // //   late cv2.FaceDetectorYN detector;
// // //   bool isProcessing = false;
// // //   List<Uint8List> croppedFaces = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadModel();
// // //   }
// // //
// // //   Future<void> _loadModel() async {
// // //     // Load the ONNX model from assets
// // //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// // //     final buffer = byteData.buffer.asUint8List();
// // //
// // //     // Create a temporary file to save the model
// // //     final tempDir = Directory.systemTemp;
// // //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// // //
// // //     // Write the model to the temp file
// // //     await modelFile.writeAsBytes(buffer);
// // //
// // //     // Initialize the detector
// // //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", ( 640, 640), 0.9, 0.05, 1);
// // //     print("Model loaded successfully.");
// // //     print(detector.getTopK());
// // //
// // //     // Start processing the images once the model is loaded
// // //     await processImages(widget.images);
// // //   }
// // //
// // //   Future<void> processImages(List<Medium> mediums) async {
// // //     setState(() {
// // //       isProcessing = true;
// // //     });
// // //
// // //     // Process images in batches
// // //     for (int i = 0; i < 20; i += 20) {
// // //       List<Medium> batch = mediums.sublist(i, i + 20 > 20 ? 20 : i + 20);
// // //       await Future.wait(batch.map((medium) async => await processImage(medium)));
// // //     }
// // //
// // //     setState(() {
// // //       isProcessing = false;
// // //     });
// // //   }
// // //
// // //   Future<void> processImage(Medium medium) async {
// // //     // Get the image file from the Medium object
// // //     File? imageFile = await medium.getFile();
// // //     if (imageFile == null) {
// // //       print("Failed to get the image file.");
// // //       return;
// // //     }
// // //
// // //     // Read the image
// // //     final imageBytes = await imageFile.readAsBytes();
// // //     cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// // //
// // //     cv2.Mat resizedImg = cv2.resize(img1, (640, 640));
// // //
// // //     // Detect faces
// // //     dynamic detections = detector.detect(resizedImg);
// // //
// // //     // Convert Mat to a List to access its elements
// // //     List<dynamic> detectionsList = detections.toList();
// // //     print("this is detecion list");
// // //     print(detectionsList);
// // //     if (detectionsList.isNotEmpty) {
// // //       // Create a list to hold bounding boxes
// // //       List<List<double>> faces = [];
// // //
// // //       // Extract the detections
// // //       for (var detection in detectionsList) {
// // //         print("this is detecion list instance");
// // //
// // //         print(detection.length);
// // //         print(detection[0]);
// // //         print(detection[3]);
// // //         List<double> faceData = detection; // Adjust based on your model output structure
// // //         faces.add(faceData);
// // //       }
// // //
// // //       // Crop faces from the image in batches
// // //       List<File?> croppedFiles = await cropFaces(imageFile, faces);
// // //
// // //       // Convert cropped files to Uint8List for displaying in the UI
// // //       for (var file in croppedFiles) {
// // //         if (file != null) {
// // //           final croppedBytes = await file.readAsBytes();
// // //           setState(() {
// // //             croppedFaces.add(croppedBytes);
// // //           });
// // //         }
// // //       }
// // //
// // //       print("Cropped faces: ${croppedFaces.length}");
// // //     }
// // //   }
// // //
// // //   Future<List<File?>> cropFaces(File imageFile, List<List<double>> faces) async {
// // //     List<File?> croppedFiles = [];
// // //
// // //     // Read the original image
// // //     final originalBytes = await imageFile.readAsBytes();
// // //     i.Image? originalImage = i.decodeImage(originalBytes);
// // //
// // //     if (originalImage == null) return croppedFiles;
// // //
// // //     // Resize the original image to 640x640 for cropping
// // //     ByteData? resizedBytes = await resizeImage(
// // //       Uint8List.fromList(originalBytes),
// // //       width: 640,
// // //       height: 640,
// // //     );
// // //
// // //     if (resizedBytes == null) {
// // //       print("Failed to resize the original image.");
// // //       return croppedFiles;
// // //     }
// // //
// // //     // Convert the resized bytes back to an image
// // //     i.Image resizedImage = i.decodeImage(Uint8List.view(resizedBytes.buffer))!;
// // //
// // //     for (var face in faces) {
// // //       // Assuming the first four values are bounding box coordinates (x1, y1, width, height)
// // //       int x1 = face[0].toInt(); // Top-left x
// // //       int y1 = face[1].toInt(); // Top-left y
// // //       int width = face[2].toInt(); // Width
// // //       int height = face[3].toInt();
// // //
// // //       print("x:$x1, y:$y1, w:$width, h:$height");
// // //
// // //       // Crop the face from the resized image
// // //       i.Image croppedImage = i.copyCrop(resizedImage, x: x1, y: y1, width: width, height: height);
// // //
// // //       // Resize the cropped image if needed (optional)
// // //       ByteData? finalResizedBytes = await resizeImage(
// // //         Uint8List.fromList(i.encodePng(croppedImage)), // Convert cropped image to bytes
// // //         width: 160, // Target width
// // //         height: 160, // Target height
// // //       );
// // //
// // //       if (finalResizedBytes != null) {
// // //         final tempDir = Directory.systemTemp;
// // //         File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
// // //         await croppedFile.writeAsBytes(Uint8List.view(finalResizedBytes.buffer));
// // //         croppedFiles.add(croppedFile);
// // //       } else {
// // //         croppedFiles.add(null);
// // //       }
// // //     }
// // //
// // //     return croppedFiles;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Face Detection')),
// // //       body: Column(
// // //         children: [
// // //           if (isProcessing) const CircularProgressIndicator(),
// // //           if (!isProcessing && croppedFaces.isNotEmpty)
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: croppedFaces.length,
// // //                 itemBuilder: (context, index) {
// // //                   return Image.memory(croppedFaces[index]);
// // //                 },
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // // import 'package:photo_gallery/photo_gallery.dart';
// // // import 'dart:io';
// // //
// // // class FaceDetectionScreen extends StatefulWidget {
// // //   final List<Medium> images; // List of images to process
// // //
// // //   const FaceDetectionScreen({super.key, required this.images});
// // //
// // //   @override
// // //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // // }
// // //
// // // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// // //   late cv2.FaceDetectorYN detector;
// // //   bool isProcessing = false;
// // //   List<Uint8List> croppedFaces = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadModel();
// // //   }
// // //
// // //   Future<void> _loadModel() async {
// // //     // Load the ONNX model from assets
// // //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// // //     final buffer = byteData.buffer.asUint8List();
// // //
// // //     // Create a temporary file to save the model
// // //     final tempDir = Directory.systemTemp;
// // //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// // //
// // //     // Write the model to the temp file
// // //     await modelFile.writeAsBytes(buffer);
// // //
// // //     // Initialize the detector
// // //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", (640, 640), 0.9, 0.05, 10); // Reduced topK to 10
// // //
// // //     print("Model loaded successfully.");
// // //     // Process the images
// // //     await processImages(widget.images);
// // //   }
// // //
// // //   Future<void> processImages(List<Medium> mediums) async {
// // //     setState(() {
// // //       isProcessing = true;
// // //     });
// // //
// // //     int batchSize = 100;  // Process images in smaller batches
// // //     for (int i = 0; i < 200; i += batchSize) {
// // //       List<Medium> batch = mediums.sublist(i, (i + batchSize > 200) ? 200 : i + batchSize);
// // //
// // //       await Future.wait(batch.map((medium) async => await processImage(medium)));  // Asynchronous processing of images
// // //     }
// // //
// // //     setState(() {
// // //       isProcessing = false;
// // //     });
// // //     print("lenght of croppd faces");
// // //     print(croppedFaces.length);
// // //   }
// // //
// // //   Future<void> processImage(Medium medium) async {
// // //     // Get the image file from the Medium object
// // //     File? imageFile = await medium.getFile();
// // //     if (imageFile == null) {
// // //       print("Failed to get the image file.");
// // //       return;
// // //     }
// // //
// // //     // Read the image using OpenCV
// // //     final imageBytes = await imageFile.readAsBytes();
// // //     cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// // //     double wi = img1.width/640;
// // //
// // //
// // //     double he = img1.height/640;
// // //     // Resize the image to 640x640 for face detection
// // //     cv2.Mat resizedImg = cv2.resize(img1, (640, 640 ));
// // //
// // //     // Detect faces
// // //     dynamic detections = detector.detect(resizedImg);
// // //
// // //     // Convert Mat to a List to access its elements
// // //     List<dynamic> detectionsList = detections.toList();
// // //     if (detectionsList.isNotEmpty) {
// // //       // Create a list to hold bounding boxes
// // //       List<List<double>> faces = [];
// // //
// // //       // Extract the detections
// // //       for (var detection in detectionsList) {
// // //         List<double> faceData = detection; // Adjust based on your model output structure
// // //         faces.add(faceData);
// // //       }
// // //
// // //       // Crop faces from the image
// // //       await cropAndResizeFaces( img1, faces, wi, he);
// // //     }
// // //   }
// // //
// // //   Future<void> cropAndResizeFaces( cv2.Mat img1, List<List<double>> faces, double w, double h) async {
// // //     List<Uint8List> croppedFacesBatch = [];
// // //     print("priting isnise cropandriee");
// // //     print(img1.width);
// // //     print(img1.width*w);
// // //     // Loop through detected faces and crop them using OpenCV
// // //     for (var face in faces) {
// // //       double x1 = (face[0]*w); // Top-left x
// // //       double y1 = (face[1]*h);// Top-left y
// // //       double width = (face[2]*w); // Width
// // //       double height = (face[3]*h); // Height
// // //
// // //       print("x:$x1, y:$y1, w:$width, h:$height");
// // //
// // //       cv2.Point2f center = cv2.Point2f(x1.toInt() + width.toInt() / 2, y1.toInt() + height.toInt() / 2);
// // //
// // //       cv2.Mat croppedFace = cv2.getRectSubPix(img1, (width.toInt(), height.toInt()) , center);
// // //
// // //
// // //       // Resize the cropped face to a fixed size (160x160)
// // //       cv2.Mat resizedFace = cv2.resize(croppedFace, (160, 160), );
// // //
// // //       // Encode the resized face to PNG format and convert it to Uint8List
// // //       final imencodeResult = cv2.imencode('.png', resizedFace);
// // //
// // //       final success = imencodeResult.$1; // Assuming item1 is the success flag
// // //       final resizedFaceBytes = imencodeResult.$2; // Assuming item2 is the encoded image
// // //
// // //       if (!success) {
// // //         print("Image encoding failed.");
// // //         return null; // Handle the error as needed
// // //       }
// // //
// // //
// // //       // Add the face to the list to display
// // //       croppedFacesBatch.add(resizedFaceBytes);
// // //     }
// // //
// // //     setState(() {
// // //       croppedFaces.addAll(croppedFacesBatch); // Add the batch of cropped faces to the state
// // //     });
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Face Detection')),
// // //       body: Column(
// // //         children: [
// // //           if (isProcessing) const CircularProgressIndicator(),
// // //           if (!isProcessing && croppedFaces.isNotEmpty)
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: croppedFaces.length,
// // //                 itemBuilder: (context, index) {
// // //                   return Image.memory(croppedFaces[index]);
// // //                 },
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:opencv_dart/opencv_dart.dart' as cv2;
// // // import 'package:photo_gallery/photo_gallery.dart';
// // // import 'dart:io';
// // // import 'package:flutter/foundation.dart';
// // //
// // // class FaceDetectionScreen extends StatefulWidget {
// // //   final List<Medium> images; // List of images to process
// // //
// // //   const FaceDetectionScreen({super.key, required this.images});
// // //
// // //   @override
// // //   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// // // }
// // //
// // // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// // //   late cv2.FaceDetectorYN detector;
// // //   bool isProcessing = false;
// // //   List<Uint8List> croppedFaces = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadModel();
// // //   }
// // //
// // //   Future<void> _loadModel() async {
// // //     // Load the ONNX model from assets
// // //     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
// // //     final buffer = byteData.buffer.asUint8List();
// // //
// // //     // Create a temporary file to save the model
// // //     final tempDir = Directory.systemTemp;
// // //     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
// // //
// // //     // Write the model to the temp file
// // //     await modelFile.writeAsBytes(buffer);
// // //
// // //     // Initialize the detector
// // //     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", (640, 640), 0.9, 0.05, 10); // Reduced topK to 10
// // //
// // //     print("Model loaded successfully.");
// // //     // Process the images
// // //     await processImages(widget.images);
// // //   }
// // //
// // //   Future<void> processImages(List<Medium> mediums) async {
// // //     setState(() {
// // //       isProcessing = true;
// // //     });
// // //
// // //     int batchSize = 50; // Process images in smaller batches
// // //     for (int i = 0; i < 100; i += batchSize) {
// // //       List<Medium> batch = mediums.sublist(i, (i + batchSize > 100) ? 100 : i + batchSize);
// // //      print('preparing batch');
// // //       // Utilize compute function for improved performance, passing the detector instance
// // //       await Future.wait(batch.map((medium) async => await (_processImageWrapper, {'medium': medium, 'detector': detector})));  // Asynchronous processing of images
// // //     }
// // //
// // //     setState(() {
// // //       isProcessing = false;
// // //     });
// // //     print("Length of cropped faces: ${croppedFaces.length}");
// // //   }
// // //
// // //   // Wrapper function for compute, passing detector and medium
// // //    Future<List<Uint8List>> _processImageWrapper(Map<String, dynamic> args) async {
// // //      print('preparing wraper');
// // //
// // //      Medium medium = args['medium'];
// // //     cv2.FaceDetectorYN detector = args['detector'];
// // //     return await _processImage(medium, detector);
// // //   }
// // //
// // //   // No longer static, since it's used with compute
// // //    Future<List<Uint8List>> _processImage(Medium medium, cv2.FaceDetectorYN detector) async {
// // //     // Get the image file from the Medium object
// // //      print('preparing preprovess');
// // //
// // //      File? imageFile = await medium.getFile();
// // //     if (imageFile == null) {
// // //       print("Failed to get the image file.");
// // //       return [];
// // //     }
// // //
// // //     try {
// // //       // Read the image using OpenCV
// // //       final imageBytes = await imageFile.readAsBytes();
// // //       cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
// // //       double wi = img1.width / 640;
// // //       double he = img1.height / 640;
// // //       print('preparing scaleing: $wi');
// // //
// // //
// // //
// // //       // Resize the image to 640x640 for face detection
// // //       cv2.Mat resizedImg = cv2.resize(img1, (640, 640));
// // //
// // //       // Detect faces using the passed detector
// // //       dynamic detections = detector.detect(resizedImg);
// // //
// // //       // Convert Mat to a List to access its elements
// // //       List<dynamic> detectionsList = detections.toList();
// // //       List<Uint8List> croppedFacesBatch = [];
// // //       print(detectionsList[0]);
// // //
// // //
// // //       if (detectionsList.isNotEmpty) {
// // //         print("im isnide");
// // //         // Create a list to hold bounding boxes
// // //         List<List<double>> faces = [];
// // //
// // //         // Extract the detections
// // //         for (var detection in detectionsList) {
// // //           List<double> faceData = detection; // Adjust based on your model output structure
// // //           faces.add(faceData);
// // //         }
// // //
// // //         // Crop faces from the image
// // //         croppedFacesBatch = await cropAndResizeFaces(img1, faces, wi, he);
// // //       }
// // //
// // //       // Clean up memory
// // //       img1.dispose();
// // //       resizedImg.dispose();
// // //
// // //       return croppedFacesBatch;
// // //
// // //     } catch (e) {
// // //       print("Error processing image: $e");
// // //       return [];
// // //     }
// // //   }
// // //
// // //   Future<List<Uint8List>> cropAndResizeFaces(cv2.Mat img1, List<List<double>> faces, double w, double h) async {
// // //     List<Uint8List> croppedFacesBatch = [];
// // //     print("Inside cropAndResizeFaces: Image Width: ${img1.width}, Scaled Width: ${img1.width * w}");
// // //
// // //     // Loop through detected faces and crop them using OpenCV
// // //     for (var face in faces) {
// // //       double x1 = (face[0] * w); // Top-left x
// // //       double y1 = (face[1] * h); // Top-left y
// // //       double width = (face[2] * w); // Width
// // //       double height = (face[3] * h); // Height
// // //
// // //       print("x:$x1, y:$y1, w:$width, h:$height");
// // //
// // //       cv2.Point2f center = cv2.Point2f(x1.toInt() + width.toInt() / 2, y1.toInt() + height.toInt() / 2);
// // //       cv2.Mat croppedFace = cv2.getRectSubPix(img1, (width.toInt(), height.toInt()), center);
// // //
// // //       // Resize the cropped face to a fixed size (160x160)
// // //       cv2.Mat resizedFace = cv2.resize(croppedFace, (160, 160));
// // //
// // //       // Encode the resized face to PNG format and convert it to Uint8List
// // //       final imencodeResult = cv2.imencode('.png', resizedFace);
// // //       final success = imencodeResult.$1; // Assuming item1 is the success flag
// // //       final resizedFaceBytes = imencodeResult.$2; // Assuming item2 is the encoded image
// // //
// // //       if (!success) {
// // //         print("Image encoding failed.");
// // //         continue; // Skip this face
// // //       }
// // //
// // //       // Add the face to the list to return
// // //       croppedFacesBatch.add(resizedFaceBytes);
// // //       // croppedFace.dispose();  // Release memory for cropped face
// // //       resizedFace.dispose();   // Release memory for resized face
// // //     }
// // //
// // //     return croppedFacesBatch;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Face Detection')),
// // //       body: Column(
// // //         children: [
// // //           if (isProcessing) const CircularProgressIndicator(),
// // //           if (!isProcessing && croppedFaces.isNotEmpty)
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: croppedFaces.length,
// // //                 itemBuilder: (context, index) {
// // //                   return Image.memory(croppedFaces[index]);
// // //                 },
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:opencv_dart/opencv_dart.dart' as cv2;
// import 'package:photo_gallery/photo_gallery.dart';
// import 'dart:io';
// import 'dart:async';
// import 'package:fast_image_resizer/fast_image_resizer.dart';
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> images; // List of images to process
//
//   const FaceDetectionScreen({super.key, required this.images});
//
//   @override
//   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   late cv2.FaceDetectorYN detector;
//   bool isProcessing = false;
//   List<Uint8List> croppedFaces = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }
//
//   Future<void> _loadModel() async {
//     // Load the ONNX model from assets
//     final byteData = await rootBundle.load('model/face_detection_yunet_2023mar.onnx');
//     final buffer = byteData.buffer.asUint8List();
//
//     // Create a temporary file to save the model
//     final tempDir = Directory.systemTemp;
//     final modelFile = File('${tempDir.path}/face_detection_yunet_2023mar.onnx');
//
//     // Write the model to the temp file
//     await modelFile.writeAsBytes(buffer);
//
//     // Initialize the detector
//     detector = cv2.FaceDetectorYN.fromFile(modelFile.path, "", (320, 320), 0.67, 0.05, 10); // Reduced topK to 10
//
//     print("Model loaded successfully.");
//     // Process the images
//     await processImages(widget.images);
//   }
//
//   Future<void> processImages(List<Medium> mediums) async {
//     setState(() {
//       isProcessing = true;
//     });
//
//     int batchSize = 100; // Process images in smaller batches
//     for (int i = 0; i < 500; i += batchSize) {
//       List<Medium> batch = mediums.sublist(i, (i + batchSize > 500) ? 500 : i + batchSize);
//
//       // Process each image synchronously (without compute)
//       for (var medium in batch) {
//         await processImage(medium);
//       }
//
//       print("batch completed");
//     }
//
//     setState(() {
//       isProcessing = false;
//     });
//     print("Length of cropped faces:");
//     print(croppedFaces.length);
//   }
//
//   Future<void> processImage(Medium medium) async {
//     try {
//       // Get the image file from the Medium object
//       File? imageFile = await medium.getFile();
//       if (imageFile == null) {
//         print("Failed to get the image file.");
//         return;
//       }
//
//       // Read the image using OpenCV
//       final imageBytes = await imageFile.readAsBytes();
//       cv2.Mat img1 = cv2.imdecode(imageBytes, cv2.IMREAD_COLOR);
//
//       if (img1.isEmpty) {
//         print("Image is empty, skipping.");
//         return;
//       }
//
//       double wi = img1.width / 320;
//       double he = img1.height / 320;
//
//       // Resize the image to 640x640 for face detection
//       cv2.Mat resizedImg = cv2.resize(img1, (320, 320));
//
//       // Detect faces
//       dynamic detections = detector.detect(resizedImg);
//
//       // Convert Mat to a List to access its elements
//       List<dynamic> detectionsList = detections.toList();
//       if (detectionsList.isNotEmpty) {
//         // Crop faces from the image
//         await cropAndResizeFaces(img1, detectionsList, wi, he);
//       }
//     } catch (e) {
//       print("Error processing image: $e");
//     }
//   }
//
//   Future<void> cropAndResizeFaces(cv2.Mat img1, List<dynamic> faces, double w, double h) async {
//     List<Uint8List> croppedFacesBatch = [];
//
//     // Loop through detected faces and crop them using OpenCV
//     for (var face in faces) {
//       try {
//         double x1 = face[0] * w; // Top-left x
//         double y1 = face[1] * h; // Top-left y
//         double width = face[2] * w; // Width
//         double height = face[3] * h; // Height
//
//         cv2.Point2f center = cv2.Point2f(x1.toInt() + width.toInt() / 2, y1.toInt() + height.toInt() / 2);
//
//         cv2.Mat croppedFace = cv2.getRectSubPix(img1, (width.toInt(), height.toInt()), center);
//
//         // Resize the cropped face to a fixed size (160x160)
//         cv2.Mat resizedFace = cv2.resize(croppedFace, (160, 160));
//
//         // Encode the resized face to PNG format and convert it to Uint8List
//         final imencodeResult = cv2.imencode('.png', resizedFace);
//         final success = imencodeResult.$1;
//         final resizedFaceBytes = imencodeResult.$2;
//
//         if (!success) {
//           print("Image encoding failed.");
//           continue;
//         }
//
//         // Add the face to the list to display
//         croppedFacesBatch.add(resizedFaceBytes);
//       } catch (e) {
//         print("Error cropping/resizing face: $e");
//       }
//     }
//
//     // Add the batch of cropped faces to the state
//     setState(() {
//       croppedFaces.addAll(croppedFacesBatch);
//     });
//   }
//
//   // Function to clear memory
//   // Future<void> clearMemory() async {
//   //   // Call OpenCV garbage collection or manually clean large objects
//   //   // For example, clear large matrices if ne;eded
//   //
//   //
//   //   print("Memory cleared.");
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Face Detection')),
//       body: Column(
//         children: [
//           if (isProcessing) const CircularProgressIndicator(),
//           if (!isProcessing && croppedFaces.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: croppedFaces.length,
//                 itemBuilder: (context, index) {
//                   return Image.memory(croppedFaces[index]);
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
