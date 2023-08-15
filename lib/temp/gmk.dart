// // import 'package:flutter/material.dart';
// // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// // import 'package:photo_gallery/photo_gallery.dart';
// // import 'dart:io';
// // import 'package:image/image.dart' as img; // For image manipulation
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'dart:typed_data';
// // import 'dart:math';
// // import 'package:image/image.dart' as imglib;
// //
// // class FaceDetectionScreen extends StatefulWidget {
// //   final List<Medium> pictureList;
// //   final Medium currentImage;
// //
// //   FaceDetectionScreen({required this.pictureList, required this.currentImage});
// //
// //   @override
// //   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// // }
// //
// // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// //   List<File> facePhotos = [];
// //   List<List<double>?> embeddings = []; // Store embeddings
// //   List<String> labels = []; // Store labels
// //   List<File> matchingImages = []; // Store matching images
// //   Interpreter? _interpreter; // TFLite interpreter
// //   List<List<double>?> currentImageEmbedding = [];
// //   int counter =0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadModel();
// //     detectFacesInPhotos();
// //   }
// //
// //   Future<void> loadModel() async {
// //     try {
// //       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
// //       print("Model loaded successfully.");
// //     } catch (e) {
// //       print("Error loading model: $e");
// //     }
// //   }
// //
// //   Future<void> detectFacesInPhotos() async {
// //     int limit = widget.pictureList.length < 1000 ? widget.pictureList.length : 1000;
// //     List<Medium> limitedPictures = widget.pictureList.sublist(0, limit);
// //     print("Processing ${limitedPictures.length} images.");
// //
// //     for (var medium in limitedPictures) {
// //       File? imageFile = await medium.getFile();
// //       if (imageFile != null) {
// //         print("Starting face detection");
// //         await detectFaces(imageFile, medium.title!);
// //         counter++;
// //         print("....................");
// //         print(counter);
// //         print("....................");
// //
// //       }
// //     }
// //
// //     // Get embedding for current image
// //     File? currentImageFile = await widget.currentImage.getFile();
// //     if (currentImageFile != null) {
// //       print("Detecting face in current image");
// //       await detectFaces(currentImageFile, widget.currentImage.title!);
// //       // Compare embeddings
// //       await compareEmbeddings();
// //     }
// //
// //     print("Face detection complete, found ${facePhotos.length} face photos.");
// //   }
// //
// //   Future<void> detectFaces(File imageFile, String label) async {
// //     print("Detecting faces...");
// //
// //     final inputImage = InputImage.fromFile(imageFile);
// //     final faceDetector = FaceDetector(
// //       options: FaceDetectorOptions(
// //         performanceMode: FaceDetectorMode.fast,
// //       ),
// //     );
// //
// //     final List<Face> faces = await faceDetector.processImage(inputImage);
// //     if (faces.isNotEmpty) {
// //       print("Face(s) detected in image: ${imageFile.path}");
// //
// //       for (var face in faces) {
// //         final croppedFace = await cropAndResizeFace(imageFile, face);
// //         if (croppedFace != null) {
// //           facePhotos.add(croppedFace);
// //           embeddings.add(await getFaceEmbedding(croppedFace));
// //           labels.add(label); // Store the label
// //         }
// //       }
// //     }
// //
// //     faceDetector.close();
// //     setState(() {});
// //   }
// //
// //   Future<File?> cropAndResizeFace(File imageFile, Face face) async {
// //     final bytes = await imageFile.readAsBytes();
// //     img.Image? originalImage = img.decodeImage(bytes);
// //
// //     if (originalImage == null) return null;
// //
// //     final boundingBox = face.boundingBox;
// //
// //     int left = boundingBox.left.toInt();
// //     int top = boundingBox.top.toInt();
// //     int width = boundingBox.width.toInt();
// //     int height = boundingBox.height.toInt();
// //
// //     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
// //     img.Image resizedImage = img.copyResize(croppedImage, width: 160, height: 160);
// //
// //     List<int> pngData = img.encodePng(resizedImage);
// //     final tempDir = Directory.systemTemp;
// //     File croppedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
// //     await croppedFile.writeAsBytes(pngData);
// //     print("Cropping face complete.");
// //
// //     return croppedFile;
// //   }
// //
// //   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
// //     if (_interpreter == null) {
// //       print("Interpreter not initialized.");
// //       return null;
// //     }
// //
// //     // Preprocess the image
// //     final inputImage = await croppedFace.readAsBytes();
// //     img.Image? imgCropped = img.decodeImage(inputImage);
// //     if (imgCropped == null) return null;
// //
// //     // Preprocess and reshape the input
// //     var input = _preprocessImage(imgCropped);
// //
// //     // Reshape the input to [1, 160, 160, 3]
// //     var reshapedInput = input.reshape([1, 160, 160, 3]);
// //
// //     // Allocate buffer for output (embedding size of 10)
// //     var output = List.filled(512, 0.0).reshape([1, 512]);  // Adjust the size to match the model's embedding size
// //
// //     // Run inference
// //     _interpreter!.run(reshapedInput, output);
// //
// //     print("Embedding generated: ${output[0]}");
// //     return output[0];
// //   }
// //
// //   // Function to convert image to Float32List
// //   Float32List _preprocessImage(img.Image image) {
// //     var convertedBytes = Float32List(160 * 160 * 3); // 160x160 pixels, 3 channels
// //     int pixelIndex = 0;
// //
// //     for (var i = 0; i < 160; i++) {
// //       for (var j = 0; j < 160; j++) {
// //         // Fetch the pixel at (j, i)
// //         var pixel = image.getPixel(j, i);
// //
// //         // Extract RGB components directly from the Pixel object
// //         num r = pixel.r; // Extract the red component
// //         num g = pixel.g; // Extract the green component
// //         num b = pixel.b; // Extract the blue component
// //
// //         // Normalize the values between -1 and 1
// //         convertedBytes[pixelIndex++] = (r - 128) / 128.0; // Normalize red
// //         convertedBytes[pixelIndex++] = (g - 128) / 128.0; // Normalize green
// //         convertedBytes[pixelIndex++] = (b - 128) / 128.0; // Normalize blue
// //       }
// //     }
// //
// //     return convertedBytes;
// //   }
// //
// //   double cosineSimilarity(List<double> vecA, List<double> vecB) {
// //     double dotProduct = 0.0;
// //     double normA = 0.0;
// //     double normB = 0.0;
// //
// //     for (int i = 0; i < vecA.length; i++) {
// //       dotProduct += vecA[i] * vecB[i];
// //       normA += vecA[i] * vecA[i];
// //       normB += vecB[i] * vecB[i];
// //     }
// //
// //     return dotProduct / (sqrt(normA) * sqrt(normB));
// //   }
// //
// //   Future<void> compareEmbeddings() async {
// //     if (embeddings.isNotEmpty) {
// //       List<double>? currentEmbedding = embeddings.last; // Last embedding is the current image
// //       for (int i = 0; i < embeddings.length - 1; i++) {
// //         double similarity = cosineSimilarity(currentEmbedding!, embeddings[i]!);
// //         print("similary...................................$similarity");
// //         // Define a similarity threshold
// //         if (similarity > 0.75) { // Adjust threshold as necessary
// //           matchingImages.add(facePhotos[i]);
// //           print("natching photo found");
// //         }
// //       }
// //     }
// //     setState(() {});
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Detecting Faces')),
// //       body: matchingImages.isEmpty
// //           ? Center(child: CircularProgressIndicator())
// //           : GridView.builder(
// //         itemCount: matchingImages.length,
// //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
// // //         itemBuilder: (context, index) {
// // //           return Image.file(matchingImages[index], fit: BoxFit.cover);
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// // import 'package:photo_gallery/photo_gallery.dart';
// // import 'dart:io';
// // import 'package:image/image.dart' as img;
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'dart:typed_data';
// // import 'dart:async';
// //
// // class FaceDetectionScreen extends StatefulWidget {
// //   final List<Medium> pictureList;
// //   final Medium currentImage;
// //
// //   FaceDetectionScreen({required this.pictureList, required this.currentImage});
// //
// //   @override
// //   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// // }
// //
// // class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
// //   List<List<double>?> embeddings = [];
// //   List<String> labels = [];
// //   Interpreter? _interpreter;
// //   int imageCounter = 0;
// //   bool isProcessing = false;
// //   bool isComplete = false;
// //   final int batchSize = 50;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadModel();
// //     processImagesInBatches();
// //   }
// //
// //   Future<void> loadModel() async {
// //     try {
// //       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
// //       print("Model loaded successfully.");
// //     } catch (e) {
// //       print("Error loading model: $e");
// //     }
// //   }
// //
// //   Future<void> processImagesInBatches() async {
// //     while (imageCounter < widget.pictureList.length) {
// //       if (isProcessing) return;
// //       isProcessing = true;
// //
// //       final int end = (imageCounter + batchSize > widget.pictureList.length)
// //           ? widget.pictureList.length
// //           : imageCounter + batchSize;
// //
// //       List<Medium> batch = widget.pictureList.sublist(imageCounter, end);
// //       await Future.wait(batch.map((medium) async {
// //         File? imageFile = await medium.getFile();
// //         if (imageFile != null) {
// //           await detectFaces(imageFile, medium.title!);
// //         }
// //       }));
// //
// //       imageCounter += batch.length;
// //       setState(() {});
// //       isProcessing = false;
// //
// //       // Clear memory (if applicable)
// //       await Future.delayed(Duration(milliseconds: 100)); // Short delay for resource release
// //     }
// //     isComplete = true;
// //   }
// //
// //   Future<void> detectFaces(File imageFile, String label) async {
// //     final inputImage = InputImage.fromFile(imageFile);
// //     final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));
// //     final List<Face> faces = await faceDetector.processImage(inputImage);
// //
// //     if (faces.isNotEmpty) {
// //       for (var face in faces) {
// //         final croppedFace = await cropAndResizeFace(imageFile, face);
// //         if (croppedFace != null) {
// //           final embedding = await getFaceEmbedding(croppedFace);
// //           if (embedding != null) {
// //             embeddings.add(embedding);
// //             labels.add(label);
// //           }
// //         }
// //       }
// //     }
// //
// //     faceDetector.close();
// //   }
// //
// //   Future<File?> cropAndResizeFace(File imageFile, Face face) async {
// //     final bytes = await imageFile.readAsBytes();
// //     img.Image? originalImage = img.decodeImage(bytes);
// //
// //     if (originalImage == null) return null;
// //
// //     final boundingBox = face.boundingBox;
// //     int left = boundingBox.left.toInt();
// //     int top = boundingBox.top.toInt();
// //     int width = boundingBox.width.toInt();
// //     int height = boundingBox.height.toInt();
// //
// //     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
// //     img.Image resizedImage = img.copyResize(croppedImage, width: 160, height: 160);
// //
// //     // Temporary storage for cropped image
// //     final tempDir = Directory.systemTemp;
// //     File croppedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
// //     await croppedFile.writeAsBytes(img.encodePng(resizedImage));
// //     return croppedFile;
// //   }
// //
// //   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
// //     if (_interpreter == null) return null;
// //
// //     final inputImage = await croppedFace.readAsBytes();
// //     img.Image? imgCropped = img.decodeImage(inputImage);
// //     if (imgCropped == null) return null;
// //
// //     var input = _preprocessImage(imgCropped);
// //     var reshapedInput = input.reshape([1, 160, 160, 3]);
// //     var output = List.filled(512, 0.0).reshape([1, 512]);
// //
// //     _interpreter!.run(reshapedInput, output);
// //     return output[0];
// //   }
// //
// //   Float32List _preprocessImage(img.Image image) {
// //     var convertedBytes = Float32List(160 * 160 * 3);
// //     int pixelIndex = 0;
// //
// //     for (var i = 0; i < 160; i++) {
// //       for (var j = 0; j < 160; j++) {
// //         var pixel = image.getPixel(j, i);
// //         num r = pixel.r;
// //         num g = pixel.g;
// //         num b = pixel.b;
// //         convertedBytes[pixelIndex++] = (r - 128) / 128.0;
// //         convertedBytes[pixelIndex++] = (g - 128) / 128.0;
// //         convertedBytes[pixelIndex++] = (b - 128) / 128.0;
// //       }
// //     }
// //
// //     return convertedBytes;
// //   }
// //
// //   Future<void> saveEmbeddingsToFile() async {
// //     final file = File('${Directory.systemTemp.path}/embeddings.txt');
// //     final embeddingsString = embeddings.map((e) => e!.join(',')).join('\n');
// //     final labelsString = labels.join('\n');
// //
// //     await file.writeAsString('$embeddingsString\n$labelsString');
// //     print('Embeddings and labels saved to file.');
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Detecting Faces')),
// //       body: isComplete
// //           ? const Center(child: Text('Processing complete!'))
// //           : const Center(child: CircularProgressIndicator()),
// //     );
// //   }
// //Working  code.
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'dart:typed_data';
// import 'dart:async';
// import 'dart:math';
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//   final Medium currentImage;
//
//   FaceDetectionScreen({required this.pictureList, required this.currentImage});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<List<double>?> embeddings = [];
//   List<String> labels = [];
//   Interpreter? _interpreter;
//   int imageCounter = 0;
//   bool isProcessing = false;
//   bool isComplete = false;
//   final int batchSize = 25;
//   List<File> matchingImages = [];
//   int hoho =0;
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//     processImagesInBatches();
//   }
//
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> processImagesInBatches() async {
//     while (imageCounter < 50) {
//       if (isProcessing) return;
//       isProcessing = true;
//
//       final int end = (imageCounter + batchSize > widget.pictureList.length)
//           ? widget.pictureList.length
//           : imageCounter + batchSize;
//
//       List<Medium> batch = widget.pictureList.sublist(imageCounter, end);
//       await Future.wait(batch.map((medium) async {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           print("Processing image ${medium.title}");
//           await detectFaces(imageFile, medium.title!);
//           print(hoho);
//           hoho++;
//
//         }
//       }));
//       print("maza agya bhi ");
//
//       imageCounter += batch.length;
//       setState(() {});
//       isProcessing = false;
//       print("maza agya bhi hhhhhhhhhhhhhooooooooooooooohhhhhhhhhhhhhhho 2");
//       // Clear memory (if applicable)
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     // After processing all batches, perform the cosine similarity check
//     await compareEmbeddings();
//
//     isComplete = true;
//   }
//
//   Future<void> detectFaces(File imageFile, String label) async {
//     print("Resizing image: $label");
//
//     final resizedImage = await resizeImage(imageFile, 480, 360);
//     if (resizedImage == null) {
//       print("Skipping image: $label due to processing issues.");
//       return;
//     }
//
//     print("Resized image: $label");
//     final inputImage = InputImage.fromFile(resizedImage!);
//     final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
//     final List<Face> faces = await faceDetector.processImage(inputImage);
//
//     print("Detected ${faces.length} faces in image: $label");
//     if (faces.isNotEmpty) {
//       for (var face in faces) {
//         print("Cropping face in image: $label");
//         final croppedFace = await cropAndResizeFace(resizedImage!, face);
//         if (croppedFace != null) {
//           print("Generating embedding for face in image: $label");
//           final embedding = await getFaceEmbedding(croppedFace);
//           if (embedding != null) {
//             embeddings.add(embedding);
//             labels.add(label);
//             print("Embedding generated for image: $label");
//           }
//         }
//       }
//     }
//
//     faceDetector.close();
//   }
//
//   Future<File?> resizeImage(File imageFile, int targetWidth, int targetHeight) async {
//     // Check if the image is in HEIC format
//     if (imageFile.path.toLowerCase().endsWith('.heic')) {
//       print("Skipping HEIC image: ${imageFile.path}");
//       return null; // Skip HEIC images
//     }
//
//     try {
//       final bytes = await imageFile.readAsBytes();
//       img.Image? originalImage = img.decodeImage(bytes);
//       if (originalImage == null) throw Exception('Could not decode image');
//
//       img.Image resizedImage = img.copyResize(originalImage, width: targetWidth, height: targetHeight);
//       final tempDir = Directory.systemTemp;
//       File resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//       await resizedFile.writeAsBytes(img.encodePng(resizedImage));
//
//       return resizedFile;
//     } catch (e) {
//       print("Error processing image ${imageFile.path}: $e");
//       return null; // Skip images that can't be processed
//     }
//   }
//
//   Future<File?> cropAndResizeFace(File imageFile, Face face) async {
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//
//     if (originalImage == null) return null;
//
//     final boundingBox = face.boundingBox;
//     int left = boundingBox.left.toInt();
//     int top = boundingBox.top.toInt();
//     int width = boundingBox.width.toInt();
//     int height = boundingBox.height.toInt();
//
//     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//     img.Image resizedImage = img.copyResize(croppedImage, width: 160, height: 160);
//
//     final tempDir = Directory.systemTemp;
//     File croppedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
//     await croppedFile.writeAsBytes(img.encodePng(resizedImage));
//     return croppedFile;
//   }
//
//   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
//     // Check if the interpreter is available
//     if (_interpreter == null) {
//       print("Interpreter is not initialized.");
//       return null;
//     }
//
//     try {
//       // Read bytes from the cropped face image
//       final inputImage = await croppedFace.readAsBytes();
//       img.Image? imgCropped = img.decodeImage(inputImage);
//
//       // Check if the image was decoded successfully
//       if (imgCropped == null) {
//         print("Failed to decode cropped face image: ${croppedFace.path}");
//         return null;
//       }
//
//       // Preprocess the image for input to the model
//       var input = _preprocessImage(imgCropped);
//       // Ensure the input has the correct shape
//       if (input.length != 160 * 160 * 3) {
//         print("Preprocessed input does not have the expected length: ${input.length}");
//         return null; // Skip processing if shape is incorrect
//       }
//
//       // Reshape the input for the model
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//
//       // Run the model inference
//       _interpreter!.run(reshapedInput, output);
//
//       // Return the first embedding
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding for cropped face image: ${croppedFace.path}, Error: $e");
//       return null; // Return null on error
//     }
//   }
//
//
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         num r = pixel.r;
//         num g = pixel.g;
//         num b = pixel.b;
//         convertedBytes[pixelIndex++] = (r - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (g - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (b - 128) / 128.0;
//       }
//     }
//
//     return convertedBytes;
//   }
//
//   // Function to compute cosine similarity between two embeddings
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   // Compare embeddings to find similar images
// // Compare embeddings to find similar images
//   Future<void> compareEmbeddings() async {
//     if (embeddings.isEmpty) return;
//     print("embeddings.length");
//
//     print(embeddings.length);
//     // Loop through embeddings and find matching images
//     for (int i = 0; i < embeddings.length; i++) {
//       {
//         double similarity = cosineSimilarity(embeddings[0]!, embeddings[i]!);
//         if (similarity > 0.70) { // Threshold for matching images
//           // Get the actual file for the matching image
//           File? matchingFileI = await widget.pictureList[i].getFile();
//           print(similarity);
//           matchingImages.add(matchingFileI);
//
//           print('Matching image found with similarity: $similarity');
//           }
//         }
//
//     }
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(title: Text('Detecting Faces', style: TextStyle(fontSize: 22, color: Colors.white),), backgroundColor: Colors.black26,),
//       body: isComplete
//           ? Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         child: GridView.builder(
//             padding: EdgeInsets.zero,
//             gridDelegate:
//             const SliverGridDelegateWithFixedCrossAxisCount(
//
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 2,
//                 crossAxisSpacing: 5,
//                 childAspectRatio: 0.95),
//             itemBuilder: (BuildContext ctx, int index) {
//
//               return InkWell(
//
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(6),
//                       child: Container(
//                         width: 120,
//                         height: 120,
//                         child: Image.file(matchingImages[index], fit: BoxFit.cover,)
//                       ),
//                     ),
//
//                   ],
//                 ),
//               );
//             },
//             itemCount: matchingImages.length
//         ),
//       )
//           : Center(child: Text('$hoho', style: TextStyle(fontSize: 22, color: Colors.white),)),
//     );
//   }
// }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'dart:typed_data';
// import 'dart:async';
// import 'dart:math';
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//   final Medium currentImage;
//
//   FaceDetectionScreen({required this.pictureList, required this.currentImage});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<List<double>?> embeddings = [];
//   List<String> labels = [];
//   Interpreter? _interpreter;
//   int imageCounter = 0;
//   bool isProcessing = false;
//   bool isComplete = false;
//   final int batchSize = 100;
//   List<File> matchingImages = [];
//   int hoho = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//     processImagesInBatches();
//   }
//
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> processImagesInBatches() async {
//     while (imageCounter < widget.pictureList.length) {
//       if (isProcessing) return;
//       isProcessing = true;
//
//       final int end = (imageCounter + batchSize > widget.pictureList.length)
//           ? widget.pictureList.length
//           : imageCounter + batchSize;
//
//       List<Medium> batch = widget.pictureList.sublist(imageCounter, end);
//       await Future.wait(batch.map((medium) async {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           print("Processing image ${medium.title}");
//           final bytes = await imageFile.readAsBytes();
//           await detectFaces(bytes, medium.title!);
//           hoho++;
//         }
//       }));
//
//       imageCounter += batch.length;
//       setState(() {});
//       isProcessing = false;
//
//       // Clear memory (if applicable)
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     // After processing all batches, perform the cosine similarity check
//     await compareEmbeddings();
//
//     isComplete = true;
//   }
//
//   Future<void> detectFaces(Uint8List imageBytes, String label) async {
//     print("Resizing image: $label");
//
//     final resizedImage = await resizeImage(imageBytes, 640, 480);
//     if (resizedImage == null) {
//       print("Skipping image: $label due to processing issues.");
//       return;
//     }
//
//     final inputImage = InputImage.fromBytes(
//       bytes: resizedImage,
//       metadata: InputImageMetadata(
//         size: Size(640, 480),
//         rotation: InputImageRotation.rotation0deg,
//         format: InputImageFormat.yuv_420_888,
//         bytesPerRow: 640 * 4,
//       ),
//     );
//     final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
//     final List<Face> faces = await faceDetector.processImage(inputImage);
//
//     print("Detected ${faces.length} faces in image: $label");
//     if (faces.isNotEmpty) {
//       for (var face in faces) {
//         print("Cropping face in image: $label");
//         final croppedFace = await cropAndResizeFaceBytes(resizedImage, face);
//         if (croppedFace != null) {
//           print("Generating embedding for face in image: $label");
//           final embedding = await getFaceEmbedding(croppedFace);
//           if (embedding != null) {
//             embeddings.add(embedding);
//             labels.add(label);
//             print("Embedding generated for image: $label");
//           }
//         }
//       }
//     }
//
//     faceDetector.close();
//   }
//
//   Future<Uint8List?> resizeImage(Uint8List imageBytes, int targetWidth, int targetHeight) async {
//     try {
//       img.Image? originalImage = img.decodeImage(imageBytes);
//       if (originalImage == null) throw Exception('Could not decode image');
//
//       img.Image resizedImage = img.copyResize(originalImage, width: targetWidth, height: targetHeight);
//       return Uint8List.fromList(img.encodePng(resizedImage));
//     } catch (e) {
//       print("Error processing image: $e");
//       return null;
//     }
//   }
//
//   Future<Uint8List?> cropAndResizeFaceBytes(Uint8List imageBytes, Face face) async {
//     img.Image? originalImage = img.decodeImage(imageBytes);
//     if (originalImage == null) {
//       print("Failed to decode original image for cropping.");
//       return null;
//     }
//
//     final boundingBox = face.boundingBox;
//     int left = boundingBox.left.toInt();
//     int top = boundingBox.top.toInt();
//     int width = boundingBox.width.toInt();
//     int height = boundingBox.height.toInt();
//
//     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//     img.Image resizedImage = img.copyResize(croppedImage, width: 160, height: 160);
//
//     return Uint8List.fromList(img.encodePng(resizedImage));
//   }
//
//   Future<List<double>?> getFaceEmbedding(Uint8List croppedFace) async {
//     if (_interpreter == null) {
//       print("Interpreter is not initialized.");
//       return null;
//     }
//
//     try {
//       img.Image? imgCropped = img.decodeImage(croppedFace);
//       if (imgCropped == null) {
//         print("Failed to decode cropped face image.");
//         return null;
//       }
//
//       var input = _preprocessImage(imgCropped);
//       if (input.length != 160 * 160 * 3) {
//         print("Preprocessed input does not have the expected length: ${input.length}");
//         return null;
//       }
//
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//
//       _interpreter!.run(reshapedInput, output);
//
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding for cropped face image: Error: $e");
//       return null;
//     }
//   }
//
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         num r = pixel.r;
//         num g = pixel.g;
//         num b = pixel.b;
//         convertedBytes[pixelIndex++] = (r - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (g - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (b - 128) / 128.0;
//       }
//     }
//
//     return convertedBytes;
//   }
//
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   Future<void> compareEmbeddings() async {
//     if (embeddings.isEmpty) return;
//     print("Number of embeddings: ${embeddings.length}");
//
//     for (int i = 0; i < embeddings.length; i++) {
//       double similarity = cosineSimilarity(embeddings[0]!, embeddings[i]!);
//       if (similarity > 0.70) {
//         File? matchingFileI = await widget.pictureList[i].getFile();
//         if (matchingFileI != null) {
//           matchingImages.add(matchingFileI);
//           print('Matching image found with similarity: $similarity');
//         }
//       }
//     }
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detecting Faces')),
//       body: isComplete
//           ? GridView.builder(
//         itemCount: matchingImages.length,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//         itemBuilder: (context, index) {
//           return Image.file(matchingImages[index], fit: BoxFit.cover);
//         },
//       )
//           : Center(child: Text('$hoho')),
//     );
//   }
// }
//
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'dart:typed_data';
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//   final Medium currentImage;
//
//   FaceDetectionScreen({required this.pictureList, required this.currentImage});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   Interpreter? _interpreter;
//   Map<String, List<double>> embeddings = {};
//   bool isProcessing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//     processImages();
//   }
//
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> processImages() async {
//     if (isProcessing) return;
//     isProcessing = true;
//
//     for (var medium in widget.pictureList) {
//       File? imageFile = await medium.getFile();
//       if (imageFile != null) {
//         print("Processing image: ${medium.title}");
//         List<double>? embedding = await processImage(imageFile, medium.title!);
//         if (embedding != null) {
//           embeddings[medium.title!] = embedding;
//         }
//       }
//     }
//
//     // Process current image
//     File? currentImageFile = await widget.currentImage.getFile();
//     if (currentImageFile != null) {
//       List<double>? currentEmbedding = await processImage(currentImageFile, widget.currentImage.title!);
//       if (currentEmbedding != null) {
//         compareEmbeddings(currentEmbedding);
//       }
//     }
//
//     isProcessing = false;
//   }
//
//   Future<List<double>?> processImage(File imageFile, String title) async {
//     final resizedImage = await resizeImage(imageFile, 480, 360);
//     if (resizedImage == null) {
//       print("Skipping image: $title due to processing issues.");
//       return null;
//     }
//
//     final inputImage = InputImage.fromFile(resizedImage);
//     final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));
//     final List<Face> faces = await faceDetector.processImage(inputImage);
//
//     if (faces.isNotEmpty) {
//       final croppedFace = await cropAndResizeFace(resizedImage, faces.first);
//       if (croppedFace != null) {
//         return await getFaceEmbedding(croppedFace);
//       }
//     }
//
//     faceDetector.close();
//     return null;
//   }
//
//   Future<File?> resizeImage(File imageFile, int targetWidth, int targetHeight) async {
//     try {
//       final bytes = await imageFile.readAsBytes();
//       img.Image? originalImage = img.decodeImage(bytes);
//       if (originalImage == null) return null;
//
//       img.Image resizedImage = img.copyResize(originalImage, width: targetWidth, height: targetHeight);
//       final tempDir = Directory.systemTemp;
//       File resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//       await resizedFile.writeAsBytes(img.encodePng(resizedImage));
//       return resizedFile;
//     } catch (e) {
//       print("Error processing image ${imageFile.path}: $e");
//       return null;
//     }
//   }
//
//   Future<File?> cropAndResizeFace(File imageFile, Face face) async {
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//     if (originalImage == null) return null;
//
//     final boundingBox = face.boundingBox;
//     int left = boundingBox.left.toInt();
//     int top = boundingBox.top.toInt();
//     int width = boundingBox.width.toInt();
//     int height = boundingBox.height.toInt();
//
//     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//     img.Image resizedImage = img.copyResize(croppedImage, width: 160, height: 160);
//
//     final tempDir = Directory.systemTemp;
//     File croppedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
//     await croppedFile.writeAsBytes(img.encodePng(resizedImage));
//     return croppedFile;
//   }
//
//   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
//     if (_interpreter == null) {
//       print("Interpreter is not initialized.");
//       return null;
//     }
//
//     try {
//       final inputImage = await croppedFace.readAsBytes();
//       img.Image? imgCropped = img.decodeImage(inputImage);
//       if (imgCropped == null) return null;
//
//       var input = _preprocessImage(imgCropped);
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//
//       _interpreter!.run(reshapedInput, output);
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding for cropped face image: ${croppedFace.path}, Error: $e");
//       return null;
//     }
//   }
//
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         convertedBytes[pixelIndex++] = (pixel.r - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.g - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.b - 128) / 128.0;
//       }
//     }
//     return convertedBytes;
//   }
//
//   void compareEmbeddings(List<double> currentEmbedding) {
//     embeddings.forEach((title, embedding) {
//       double similarity = cosineSimilarity(currentEmbedding, embedding);
//       if (similarity > 0.70) {
//         print('Matching image found: $title with similarity: $similarity');
//       }
//     });
//   }
//
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(title: Text('Face Detection', style: TextStyle(color: Colors.white)), backgroundColor: Colors.black26),
//       body: Center(child: Text('Processing...', style: TextStyle(color: Colors.white))),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'dart:typed_data';
// import 'dart:async';
// import 'dart:math';
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//   final Medium currentImage;
//
//   FaceDetectionScreen({required this.pictureList, required this.currentImage});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   final int batchSize = 50;
//   final Map<String, List<double>> embeddings = {};
//   Interpreter? _interpreter;
//   bool isProcessing = false;
//   bool isComplete = false;
//   List<File> matchingImages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel().then((_) => processImages());
//   }
//
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> processImages() async {
//     for (int i = 0; i < min(widget.pictureList.length, 50); i += batchSize) {
//       if (isProcessing) return;
//       isProcessing = true;
//
//       final end = min(i + batchSize, widget.pictureList.length);
//       final batch = widget.pictureList.sublist(i, end);
//       await Future.wait(batch.map((medium) async {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           print("Processing image ${medium.title}");
//           await detectAndStoreEmbedding(imageFile, medium.title!);
//         }
//       }));
//
//       isProcessing = false;
//     }
//
//     await compareEmbeddings();
//     isComplete = true;
//     setState(() {});
//   }
//
//   Future<void> detectAndStoreEmbedding(File imageFile, String label) async {
//     if (imageFile.path.toLowerCase().endsWith('.heic')) {
//       print("Skipping HEIC image: ${imageFile.path}");
//       return; // Skip HEIC images
//     }
//
//     final resizedImage = await resizeImage(imageFile, 480, 360);
//     if (resizedImage == null) return;
//
//     final inputImage = InputImage.fromFile(resizedImage);
//     final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast, enableClassification: false));
//
//     final faces = await faceDetector.processImage(inputImage);
//     if (faces.isNotEmpty) {
//       for (var face in faces) {
//         final croppedFace = await cropAndResizeFace(resizedImage, face);
//         if (croppedFace != null) {
//           final embedding = await getFaceEmbedding(croppedFace);
//           if (embedding != null) {
//             embeddings[label] = embedding;
//             print("Embedding generated for image: $label");
//           }
//         }
//       }
//     }
//
//     faceDetector.close();
//   }
//
//   Future<File?> resizeImage(File imageFile, int targetWidth, int targetHeight) async {
//     try {
//       final bytes = await imageFile.readAsBytes();
//       img.Image? originalImage = img.decodeImage(bytes);
//       if (originalImage == null) return null;
//
//       img.Image resizedImage = img.copyResize(originalImage, width: targetWidth, height: targetHeight);
//       final tempDir = Directory.systemTemp;
//       File resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//       await resizedFile.writeAsBytes(img.encodePng(resizedImage));
//
//       return resizedFile;
//     } catch (e) {
//       print("Error processing image ${imageFile.path}: $e");
//       return null;
//     }
//   }
//
//   Future<File?> cropAndResizeFace(File imageFile, Face face) async {
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//     if (originalImage == null) return null;
//
//     final boundingBox = face.boundingBox;
//     int left = boundingBox.left.toInt();
//     int top = boundingBox.top.toInt();
//     int width = boundingBox.width.toInt();
//     int height = boundingBox.height.toInt();
//
//     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//     img.Image resizedImage = img.copyResize(croppedImage, width: 160, height: 160);
//
//     final tempDir = Directory.systemTemp;
//     File croppedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
//     await croppedFile.writeAsBytes(img.encodePng(resizedImage));
//     return croppedFile;
//   }
//
//   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
//     if (_interpreter == null) return null;
//
//     try {
//       final inputImage = await croppedFace.readAsBytes();
//       img.Image? imgCropped = img.decodeImage(inputImage);
//       if (imgCropped == null) return null;
//
//       var input = _preprocessImage(imgCropped);
//       if (input.length != 160 * 160 * 3) return null;
//
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//       _interpreter!.run(reshapedInput, output);
//
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding: $e");
//       return null;
//     }
//   }
//
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         convertedBytes[pixelIndex++] = (pixel.r - 127.5) / 127.5;
//         convertedBytes[pixelIndex++] = (pixel.g - 127.5) / 127.5;
//         convertedBytes[pixelIndex++] = (pixel.b - 127.5) / 127.5;
//       }
//     }
//
//     return convertedBytes;
//   }
//
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   Future<void> compareEmbeddings() async {
//     print("generating embedding for current images");
//     if (embeddings.isEmpty) return;
//     final currentEmbedding = await getFaceEmbedding(await widget.currentImage.getFile());
//
//     if (currentEmbedding != null) {
//       print("inside loop current images");
//
//       for (var entry in embeddings.entries) {
//         double similarity = cosineSimilarity(currentEmbedding, entry.value);
//         print(similarity);
//         if (similarity > 0.1) { // Threshold for matching images
//           File? matchingFile = await widget.pictureList.firstWhere((medium) => medium.title == entry.key).getFile();
//           if (matchingFile != null) {
//             matchingImages.add(matchingFile);
//             print('Matching image found: ${entry.key} with similarity: $similarity');
//           }
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('Detecting Faces', style: TextStyle(fontSize: 22, color: Colors.white)),
//         backgroundColor: Colors.black26,
//       ),
//       body: isComplete
//           ? Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         child: GridView.builder(
//             padding: EdgeInsets.zero,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 2,
//                 crossAxisSpacing: 5,
//                 childAspectRatio: 0.95),
//             itemCount: matchingImages.length,
//             itemBuilder: (BuildContext ctx, int index) {
//               return ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: Image.file(
//                   matchingImages[index],
//                   fit: BoxFit.cover,
//                 ),
//               );
//             }),
//       )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img;
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//
//   FaceDetectionScreen({required this.pictureList});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<File> detectedFaces = [];
//   bool isProcessing = false;
//   final int batchSize = 50; // Number of images to process at a time
//
//   @override
//   void initState() {
//     super.initState();
//     processImages();
//   }
//
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//     });
//
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableLandmarks: false,
//         enableClassification: false,
//       ),
//     );
//
//     for (var i = 0; i < 200; i += batchSize) {
//       // Get a batch of images
//       final batch = widget.pictureList.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           batchFiles.add(imageFile); // Add to batch files
//         }
//       }
//
//       await detectFaces(batchFiles, faceDetector);
//     }
//
//     faceDetector.close(); // Close the detector after processing all images
//
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   Future<void> detectFaces(List<File> imageFiles, FaceDetector faceDetector) async {
//     for (var imageFile in imageFiles) {
//       // Resize image to 480x360
//       final resizedImage = await resizeImage(imageFile, 160, 160);
//       if (resizedImage == null) {
//         print("Skipping image: ${imageFile.path} due to processing issues.");
//         continue;
//       }
//
//       // Create an InputImage from the resized image
//       final inputImage = InputImage.fromFile(resizedImage);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         for (var face in faces) {
//           // Crop and resize face image
//           final croppedFace = await cropFace(resizedImage, face);
//           if (croppedFace != null) {
//             detectedFaces.add(croppedFace); // Add detected face to the list
//           }
//         }
//       }
//     }
//   }
//
//   Future<File?> resizeImage(File imageFile, int targetWidth, int targetHeight) async {
//     try {
//       final bytes = await imageFile.readAsBytes();
//       img.Image? originalImage = img.decodeImage(bytes);
//       if (originalImage == null) throw Exception('Could not decode image');
//
//       img.Image resizedImage = img.copyResize(originalImage, width: targetWidth, height: targetHeight);
//       final tempDir = Directory.systemTemp;
//       File resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//       await resizedFile.writeAsBytes(img.encodePng(resizedImage));
//
//       return resizedFile;
//     } catch (e) {
//       print("Error processing image ${imageFile.path}: $e");
//       return null; // Skip images that can't be processed
//     }
//   }
//
//   Future<File?> cropFace(File imageFile, Face face) async {
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//
//     if (originalImage == null) return null;
//
//     final boundingBox = face.boundingBox;
//     int left = boundingBox.left.toInt();
//     int top = boundingBox.top.toInt();
//     int width = boundingBox.width.toInt();
//     int height = boundingBox.height.toInt();
//
//     img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//     final tempDir = Directory.systemTemp;
//     File croppedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
//     await croppedFile.writeAsBytes(img.encodePng(croppedImage));
//
//     return croppedFile;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detected Faces')),
//       body: isProcessing
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 4,
//           crossAxisSpacing: 4,
//         ),
//         itemCount: detectedFaces.length,
//         itemBuilder: (context, index) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               detectedFaces[index],
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// perfect workin code.
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img;
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//
//   FaceDetectionScreen({required this.pictureList});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<File> detectedFaces = [];
//   bool isProcessing = false;
//   final int batchSize = 200; // Number of images to process at a time
//
//   @override
//   void initState() {
//     super.initState();
//     processImages();
//   }
//
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//     });
//
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableLandmarks: false,
//         enableClassification: false,
//         enableContours: false,
//         enableTracking: false
//       ),
//     );
//
//     for (var i = 0; i < 1000; i += batchSize) {
//       // Get a batch of images
//       final batch = widget.pictureList.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           batchFiles.add(imageFile); // Add to batch files
//         }
//       }
//
//       // Resize batch images
//       final List<File?> resizedImages =
//           await resizeImages(batchFiles, 160, 160);
//       // Detect faces in resized images
//       await detectFaces(resizedImages, faceDetector);
//     }
//
//     faceDetector.close(); // Close the detector after processing all images
//
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   Future<List<File?>> resizeImages(
//       List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<File?> resizedFiles = [];
//
//     for (var imageFile in imageFiles) {
//       try {
//         final bytes = await imageFile.readAsBytes();
//         img.Image? originalImage = img.decodeImage(bytes);
//         if (originalImage == null) throw Exception('Could not decode image');
//
//         img.Image resizedImage = img.copyResize(originalImage,
//             width: targetWidth, height: targetHeight);
//         final tempDir = Directory.systemTemp;
//         File resizedFile = File(
//             '${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//         await resizedFile.writeAsBytes(img.encodePng(resizedImage));
//
//         resizedFiles.add(resizedFile);
//       } catch (e) {
//         print("Error processing image ${imageFile.path}: $e");
//         resizedFiles.add(null); // Add null for failed images
//       }
//     }
//
//     return resizedFiles;
//   }
//
//   Future<void> detectFaces(
//       List<File?> resizedImages, FaceDetector faceDetector) async {
//     for (var resizedImage in resizedImages) {
//       if (resizedImage == null)
//         continue; // Skip if the image was not resized successfully
//
//       // Create an InputImage from the resized image
//       final inputImage = InputImage.fromFile(resizedImage);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         // Crop the detected faces
//         final croppedFaces = await cropFaces(resizedImage, faces);
//         detectedFaces.addAll(croppedFaces.whereType<File>()); // Use whereType<File>() to filter out nulls
// // Add only non-null cropped faces
//       }
//     }
//   }
//
//   Future<List<File?>> cropFaces(File imageFile, List<Face> faces) async {
//     List<File?> croppedFiles = [];
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//
//     if (originalImage == null)
//       return croppedFiles; // Return empty if decoding failed
//
//     for (var face in faces) {
//       final boundingBox = face.boundingBox;
//       int left = boundingBox.left.toInt();
//       int top = boundingBox.top.toInt();
//       int width = boundingBox.width.toInt();
//       int height = boundingBox.height.toInt();
//
//       img.Image croppedImage = img.copyCrop(originalImage,
//           x: left, y: top, width: width, height: height);
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File(
//           '${tempDir.path}/${imageFile.uri.pathSegments.last}_cropped.png');
//       await croppedFile.writeAsBytes(img.encodePng(croppedImage));
//
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detected Faces')),
//       body: isProcessing
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 4,
//                 crossAxisSpacing: 4,
//               ),
//               itemCount: detectedFaces.length,
//               itemBuilder: (context, index) {
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.file(
//                     detectedFaces[index],
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
//
// best rezing code/...........................................................................................................................
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:fast_image_resizer/fast_image_resizer.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img; // Ensure you import image package for cropping
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//
//   FaceDetectionScreen({required this.pictureList});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<File> detectedFaces = [];
//   List<Uint8List?> resizedImages = []; // List to hold resized images
//   bool isProcessing = false;
//   final int batchSize = 400; // Number of images to process at a time
//
//   @override
//   void initState() {
//     super.initState();
//     processImages();
//   }
//
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//       resizedImages.clear(); // Clear previous images
//     });
//
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableLandmarks: false,
//         enableClassification: false,
//         enableContours: false,
//         enableTracking: false,
//       ),
//     );
//
//     for (var i = 0; i < 400; i += batchSize) {
//       // Get a batch of images
//       final batch = widget.pictureList.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           batchFiles.add(imageFile); // Add to batch files
//         }
//       }
//
//       // Resize batch images in memory
//       final List<Uint8List?> resizedBatchImages = await resizeImagesInMemory(batchFiles, 160, 160);
//       setState(() {
//         resizedImages.addAll(resizedBatchImages); // Store resized images for UI
//       });
//
//       // Detect faces in resized images
//       await detectFaces(resizedBatchImages, faceDetector);
//     }
//
//     faceDetector.close(); // Close the detector after processing all images
//
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   Future<List<Uint8List?>> resizeImagesInMemory(List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<Uint8List?> resizedImages = [];
//     print("Resizing images in memory...");
//
//     for (var imageFile in imageFiles) {
//       try {
//         final bytes = await imageFile.readAsBytes();
//         // Resize the image and convert to Uint8List
//         final ByteData? resizedBytes = await resizeImage(Uint8List.fromList(bytes), width: targetWidth, height: targetHeight);
//
//         // Check if resizedBytes is not null and convert it to Uint8List
//         if (resizedBytes != null) {
//           resizedImages.add(Uint8List.view(resizedBytes.buffer));
//         } else {
//           resizedImages.add(null); // Add null for failed resizing
//         }
//       } catch (e) {
//         print("Error processing image ${imageFile.path}: $e");
//         resizedImages.add(null); // Add null for failed images
//       }
//     }
//
//
//
//     return resizedImages;
//   }
//
//   Future<void> detectFaces(List<Uint8List?> resizedImages, FaceDetector faceDetector) async {
//     for (var resizedImage in resizedImages) {
//       if (resizedImage == null) continue; // Skip if the image was not resized successfully
//
//       // Create an InputImage from the resized image bytes
//       final inputImage = InputImage.fromBytes(
//         bytes: resizedImage,
//         metadata: InputImageMetadata(
//           size: Size(160.0, 160.0), // Size of the resized image
//           rotation: InputImageRotation.rotation0deg, // Adjust as necessary
//           format: InputImageFormat.nv21, // Use the correct format for your images
//           bytesPerRow: 480, // Adjust this based on the image format
//         ),
//       );
//       print(inputImage.filePath);
//       print("........................................");
//       print(inputImage.metadata);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         // Crop the detected faces
//         final croppedFaces = await cropFaces(resizedImage, faces);
//         detectedFaces.addAll(croppedFaces.whereType<File>()); // Use whereType<File>() to filter out nulls
//       }
//     }
//   }
//
//   Future<List<File?>> cropFaces(Uint8List resizedImage, List<Face> faces) async {
//     List<File?> croppedFiles = [];
//     img.Image? originalImage = img.decodeImage(resizedImage);
//
//     if (originalImage == null) return croppedFiles; // Return empty if decoding failed
//
//     for (var face in faces) {
//       final boundingBox = face.boundingBox;
//       int left = boundingBox.left.toInt();
//       int top = boundingBox.top.toInt();
//       int width = boundingBox.width.toInt();
//       int height = boundingBox.height.toInt();
//
//       img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
//       await croppedFile.writeAsBytes(img.encodePng(croppedImage));
//
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detected Faces')),
//       body: isProcessing
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 4,
//           crossAxisSpacing: 4,
//         ),
//         itemCount: resizedImages.length, // Use resizedImages length
//         itemBuilder: (context, index) {
//           final imageData = resizedImages[index];
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: imageData != null
//                 ? Image.memory(
//               imageData,
//               fit: BoxFit.cover,
//             )
//                 : Container(color: Colors.grey), // Placeholder for null images
//           );
//         },
//       ),
//     );
// //   }
// // }
//
// ......................................................best final face detecion......................................
//
//
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as i;
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:fast_image_resizer/fast_image_resizer.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img; // Ensure you import image package for cropping
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//
//   FaceDetectionScreen({required this.pictureList});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<File> detectedFaces = [];
//   List<File> resizedImages = []; // List to hold resized images as files
//   bool isProcessing = false;
//   final int batchSize = 50; // Number of images to process at a time
//
//   @override
//   void initState() {
//     super.initState();
//     processImages();
//   }
//
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//       resizedImages.clear(); // Clear previous images
//     });
//
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableLandmarks: false,
//         enableClassification: false,
//         enableContours: false,
//         enableTracking: false,
//       ),
//     );
//
//     for (var i = 0; i < 100; i += batchSize) {
//       // Get a batch of images
//       final batch = widget.pictureList.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           batchFiles.add(imageFile); // Add to batch files
//         }
//       }
//
//       // Resize batch images and save them as files
//       final List<File?> resizedBatchFiles = await resizeImagesAndSave(batchFiles, 480, 360);
//       setState(() {
//         resizedImages.addAll(resizedBatchFiles.whereType<File>()); // Store resized image files for UI
//       });
//
//       // Detect faces in resized images
//       await detectFaces(resizedBatchFiles, faceDetector);
//     }
//
//     faceDetector.close(); // Close the detector after processing all images
//
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   Future<List<File?>> resizeImagesAndSave(List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<File?> resizedFiles = [];
//     print("Resizing images and saving as files...");
//
//     for (var imageFile in imageFiles) {
//       try {
//         final originalBytes = await imageFile.readAsBytes();
//         // Resize the image and convert to ByteData
//         final ByteData? resizedBytes = await resizeImage(Uint8List.fromList(originalBytes), width: targetWidth, height: targetHeight);
//
//         // Save the resized image to a file
//         if (resizedBytes != null) {
//           final tempDir = Directory.systemTemp;
//           final resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//           await resizedFile.writeAsBytes(Uint8List.view(resizedBytes.buffer));
//           resizedFiles.add(resizedFile); // Add resized file to the list
//         } else {
//           resizedFiles.add(null); // Add null for failed resizing
//         }
//       } catch (e) {
//         print("Error processing image ${imageFile.path}: $e");
//         resizedFiles.add(null); // Add null for failed images
//       }
//     }
//
//     return resizedFiles;
//   }
//
//   Future<void> detectFaces(List<File?> resizedFiles, FaceDetector faceDetector) async {
//     for (var resizedFile in resizedFiles) {
//       if (resizedFile == null) continue; // Skip if the image was not resized successfully
//
//       // Create an InputImage from the resized image file
//       final inputImage = InputImage.fromFile(resizedFile);
//
//       // Detect faces
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         // Crop the detected faces
//         final croppedFaces = await cropFaces(resizedFile, faces);
//         detectedFaces.addAll(croppedFaces.whereType<File>()); // Use whereType<File>() to filter out nulls
//       }
//     }
//   }
//
//   Future<List<File?>> cropFaces(File imageFile, List<Face> faces) async {
//     List<File?> croppedFiles = [];
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//
//     if (originalImage == null) return croppedFiles; // Return empty if decoding failed
//
//     for (var face in faces) {
//       final boundingBox = face.boundingBox;
//       int left = boundingBox.left.toInt();
//       int top = boundingBox.top.toInt();
//       int width = boundingBox.width.toInt();
//       int height = boundingBox.height.toInt();
//
//       // Crop the image
//       img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//
//       // Resize the cropped image to 160x160
//       img.Image resizedCroppedImage = img.copyResize(croppedImage, width: 160, height: 160, interpolation:i.Interpolation.cubic );
//       print('Resized cropped face dimensions: Width: ${croppedImage.width}, Height: ${croppedImage.height}');
//       print("...........................................................");
//       // Check the dimensions of the resized cropped face
//       print('Resized cropped face dimensions: Width: ${resizedCroppedImage.width}, Height: ${resizedCroppedImage.height}');
//
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
//       await croppedFile.writeAsBytes(img.encodePng(resizedCroppedImage)); // Save the resized image
//
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detected Faces')),
//       body: isProcessing
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 4,
//           crossAxisSpacing: 4,
//         ),
//         itemCount: detectedFaces.length,
//         itemBuilder: (context, index) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               detectedFaces[index],
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// ..............................................full code...............................................
//
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as i;
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:fast_image_resizer/fast_image_resizer.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img; // Ensure you import image package for cropping
// import 'package:tflite_flutter/tflite_flutter.dart'; // Import the tflite_flutter package
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//
//   FaceDetectionScreen({required this.pictureList});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   List<File> detectedFaces = [];
//   List<File> resizedImages = []; // List to hold resized images as files
//   Map<String, List<double>> faceEmbeddings = {}; // Map to hold embeddings with file paths as keys
//   bool isProcessing = false;
//   final int batchSize = 50; // Number of images to process at a time
//   Interpreter? _interpreter; // Declare interpreter
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel(); // Load the model when the widget is initialized
//     processImages();
//   }
//
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//       resizedImages.clear(); // Clear previous images
//       detectedFaces.clear(); // Clear previous detected faces
//       faceEmbeddings.clear(); // Clear previous embeddings
//     });
//
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableLandmarks: false,
//         enableClassification: false,
//         enableContours: false,
//         enableTracking: false,
//       ),
//     );
//
//     for (var i = 0; i < 100; i += batchSize) {
//       // Get a batch of images
//       final batch = widget.pictureList.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           batchFiles.add(imageFile); // Add to batch files
//         }
//       }
//
//       // Resize batch images and save them as files
//       final List<File?> resizedBatchFiles = await resizeImagesAndSave(batchFiles, 480, 360);
//       setState(() {
//         resizedImages.addAll(resizedBatchFiles.whereType<File>()); // Store resized image files for UI
//       });
//
//       // Detect faces in resized images
//       await detectFaces(resizedBatchFiles, faceDetector);
//     }
//
//     faceDetector.close(); // Close the detector after processing all images
//
//     // Now process the detected faces for embeddings
//     await processFaceEmbeddings();
//
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   Future<List<File?>> resizeImagesAndSave(List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<File?> resizedFiles = [];
//     print("Resizing images and saving as files...");
//
//     for (var imageFile in imageFiles) {
//       try {
//         final originalBytes = await imageFile.readAsBytes();
//         // Resize the image and convert to ByteData
//         final ByteData? resizedBytes = await resizeImage(Uint8List.fromList(originalBytes), width: targetWidth, height: targetHeight);
//
//         // Save the resized image to a file
//         if (resizedBytes != null) {
//           final tempDir = Directory.systemTemp;
//           final resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}_resized.png');
//           await resizedFile.writeAsBytes(Uint8List.view(resizedBytes.buffer));
//           resizedFiles.add(resizedFile); // Add resized file to the list
//         } else {
//           resizedFiles.add(null); // Add null for failed resizing
//         }
//       } catch (e) {
//         print("Error processing image ${imageFile.path}: $e");
//         resizedFiles.add(null); // Add null for failed images
//       }
//     }
//
//     return resizedFiles;
//   }
//
//   Future<void> detectFaces(List<File?> resizedFiles, FaceDetector faceDetector) async {
//     for (var resizedFile in resizedFiles) {
//       if (resizedFile == null) continue; // Skip if the image was not resized successfully
//
//       // Create an InputImage from the resized image file
//       final inputImage = InputImage.fromFile(resizedFile);
//
//       // Detect faces
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         // Crop the detected faces
//         final croppedFaces = await cropFaces(resizedFile, faces);
//         detectedFaces.addAll(croppedFaces.whereType<File>()); // Use whereType<File>() to filter out nulls
//       }
//     }
//   }
//
//   Future<List<File?>> cropFaces(File imageFile, List<Face> faces) async {
//     List<File?> croppedFiles = [];
//     final bytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//
//     if (originalImage == null) return croppedFiles; // Return empty if decoding failed
//
//     for (var face in faces) {
//       final boundingBox = face.boundingBox;
//       int left = boundingBox.left.toInt();
//       int top = boundingBox.top.toInt();
//       int width = boundingBox.width.toInt();
//       int height = boundingBox.height.toInt();
//
//       // Crop the image
//       img.Image croppedImage = img.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//
//       // Resize the cropped image to 160x160
//       img.Image resizedCroppedImage = img.copyResize(croppedImage, width: 160, height: 160, interpolation: i.Interpolation.cubic);
//       print('Resized cropped face dimensions: Width: ${croppedImage.width}, Height: ${croppedImage.height}');
//       print("...........................................................");
//       // Check the dimensions of the resized cropped face
//       print('Resized cropped face dimensions: Width: ${resizedCroppedImage.width}, Height: ${resizedCroppedImage.height}');
//
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
//       await croppedFile.writeAsBytes(img.encodePng(resizedCroppedImage)); // Save the resized image
//
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
//   }
//
//   Future<void> processFaceEmbeddings() async {
//     for (var faceFile in detectedFaces) {
//       final embedding = await getFaceEmbedding(faceFile);
//       if (embedding != null) {
//         faceEmbeddings[faceFile.path] = embedding; // Store the embedding with the file path as the key
//       }
//     }
//     // Now you can calculate cosine similarities or any other processing on faceEmbeddings
//   }
//
//   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
//     if (_interpreter == null) {
//       print("Interpreter is not initialized.");
//       return null;
//     }
//
//     try {
//       final inputImage = await croppedFace.readAsBytes();
//       img.Image? imgCropped = img.decodeImage(inputImage);
//       if (imgCropped == null) return null;
//
//       var input = _preprocessImage(imgCropped);
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//
//       _interpreter!.run(reshapedInput, output);
//       print("generating emeding");
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding for cropped face image: ${croppedFace.path}, Error: $e");
//       return null;
//     }
//   }
//
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         convertedBytes[pixelIndex++] = (pixel.r - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.g - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.b - 128) / 128.0;
//       }
//     }
//     return convertedBytes;
//   }
//
//   // Function to calculate cosine similarity
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//
//     return dotProduct / (sqrt(normA) * sqrt(normB)); // Handle zero division if needed
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Face Detection'),
//       ),
//       body: Center(
//         child: isProcessing
//             ? CircularProgressIndicator()
//             : Column(
//           children: [
//             // Your UI for displaying images and embeddings goes here
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:fast_image_resizer/fast_image_resizer.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as i;
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//   final Medium currentImage;
//
//   FaceDetectionScreen({required this.pictureList, required this.currentImage});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   Map<String, List<double>> allEmbeddings = {}; // Store embeddings for all images
//   Map<String, List<double>> currentEmbedding = {}; // Store embedding for current image
//   Interpreter? _interpreter;
//   List<File> detectedFaces = [];
//   List<File> resizedImages = [];
//   bool isProcessing = false;
//   final int batchSize = 50;
//   List<File> matchingImages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel().then((_) => processImages());
//
//   }
//
//   // Load the TFLite model for face embeddings
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   // Process images (resizing, face detection, cropping, embedding generation)
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//       resizedImages.clear(); // Clear previous images
//     });
//
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableLandmarks: false,
//         enableClassification: false,
//         enableContours: false,
//         enableTracking: false,
//       ),
//     );
//     Map<String, List<double>> allEmbeddings = await loadEmbeddingsFromLocalStorage();
//     final totalImages = widget.pictureList.length;
//     final storedEmbeddingsCount = allEmbeddings.length;
//
//     // Check if stored embeddings are at least 95% of the total images
//     if (storedEmbeddingsCount >= (totalImages * 0.001).round()) {
//       print("Stored embeddings meet the threshold. Skipping face detection and embedding generation.");
//
//       // Proceed to compare embeddings instead
//       await compareEmbeddings( allEmbeddings.values as List<double>);
//     } else {
//       print("Stored embeddings are less than 95% of total images. Generating new embeddings.");
//
//       for (var i = 0; i < 1000; i += batchSize) {
//         final batch = widget.pictureList.skip(i).take(batchSize);
//         List<File> batchFiles = [];
//
//         for (var medium in batch) {
//           File? imageFile = await medium.getFile();
//           if (imageFile != null) {
//             var imageFileName = p.basenameWithoutExtension(imageFile.path);
//
//             // Check if this image already has a stored embedding
//             if (allEmbeddings.containsKey(imageFileName)) {
//               print("Skipping face detection and embedding generation for: ${imageFile.path}");
//               // Use the stored embedding and proceed to comparison
//             } else {
//               print("Processing image: $imageFileName");
//               batchFiles.add(imageFile); // Process images without stored embeddings
//             }
//           }
//         }
//
//         if (batchFiles.isNotEmpty) {
//           final List<File?> resizedBatchFiles = await resizeImagesAndSave(batchFiles, 300, 300);
//           setState(() {
//             resizedImages.addAll(resizedBatchFiles.whereType<File>());
//           });
//
//           await detectFacesAndGenerateEmbeddings(resizedBatchFiles, faceDetector, allEmbeddings);
//
//           // After generating new embeddings, save them to local storage
//           await saveEmbeddingsToLocalStorage(allEmbeddings);
//         }
//       }
//     }
//
//     faceDetector.close(); // Close the detector after processing all images
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//
//
//   // Resize images and save them
//   Future<List<File?>> resizeImagesAndSave(List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<File?> resizedFiles = [];
//     print("Resizing images and saving as files...");
//
//     for (var imageFile in imageFiles) {
//       try {
//         final originalBytes = await imageFile.readAsBytes();
//         final ByteData? resizedBytes = await resizeImage(Uint8List.fromList(originalBytes), width: targetWidth, height: targetHeight);
//
//         if (resizedBytes != null) {
//           final tempDir = Directory.systemTemp;
//           final resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}.png');
//           await resizedFile.writeAsBytes(Uint8List.view(resizedBytes.buffer));
//           resizedFiles.add(resizedFile);
//         } else {
//           resizedFiles.add(null);
//         }
//       } catch (e) {
//         print("Error processing image ${imageFile.path}: $e");
//         resizedFiles.add(null);
//       }
//     }
//
//     return resizedFiles;
//   }
//
//   // Detect faces and generate embeddings for a batch of images
//   Future<void> detectFacesAndGenerateEmbeddings(List<File?> resizedFiles, FaceDetector faceDetector, Map<String, List<double>> embeddingsMap) async {
//     for (var resizedFile in resizedFiles) {
//       if (resizedFile == null) continue;
//
//       final inputImage = InputImage.fromFile(resizedFile);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         final croppedFaces = await cropFaces(resizedFile, faces);
//         for (var croppedFace in croppedFaces) {
//           if (croppedFace != null) {
//             final embedding = await getFaceEmbedding(croppedFace);
//             if (embedding != null) {
//               embeddingsMap[resizedFile.path] = embedding; // Store embedding in the map
//             }
//           }
//         }
//       }
//     }
//   }
//
//   // Process the current image
//   Future<void> processCurrentImage(FaceDetector faceDetector) async {
//     File? currentImageFile = await widget.currentImage.getFile();
//     if (currentImageFile == null) return;
//
//     List<File?> resizedCurrentImageList = await resizeImagesAndSave([currentImageFile], 300, 300);
//     File? resizedCurrentImageFile = resizedCurrentImageList.isNotEmpty ? resizedCurrentImageList.first : null;
//
//     if (resizedCurrentImageFile != null) {
//       final inputImage = InputImage.fromFile(resizedCurrentImageFile);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         final croppedFaces = await cropFaces(resizedCurrentImageFile, faces);
//         for (var croppedFace in croppedFaces) {
//           if (croppedFace != null) {
//             final embedding = await getFaceEmbedding(croppedFace);
//             if (embedding != null) {
//               currentEmbedding[currentImageFile.path] = embedding;
//               await compareEmbeddings(embedding); // Compare with other embeddings
//             }
//           }
//         }
//       }
//     }
//   }
//
//   Future<void> saveEmbeddingsToLocalStorage(Map<String, List<double>> embeddings) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/embeddings_data.json';
//       print(filePath);
//       final file = File(filePath);
//
//       // Convert embeddings map to JSON format
//       Map<String, dynamic> jsonData = embeddings.map((key, value) => MapEntry(key, value));
//       String jsonString = json.encode(jsonData);
//
//       // Write JSON string to file
//       await file.writeAsString(jsonString);
//       print("Embeddings saved successfully.");
//     } catch (e) {
//       print("Error saving embeddings to storage: $e");
//     }
//   }
//
//   /// Loads the embedding data (file path and embeddings) from local storage
//   Future<Map<String, List<double>>> loadEmbeddingsFromLocalStorage() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/embeddings_data.json';
//       final file = File(filePath);
//
//       if (await file.exists()) {
//         // Read JSON string from file
//         String jsonString = await file.readAsString();
//         Map<String, dynamic> jsonData = json.decode(jsonString);
//
//         // Convert JSON data back to Map<String, List<double>>
//         Map<String, List<double>> embeddings = jsonData.map((key, value) => MapEntry(key, List<double>.from(value)));
//         print("Embeddings loaded successfully.");
//         return embeddings;
//       } else {
//         print("No saved embeddings found.");
//         return {};
//       }
//     } catch (e) {
//       print("Error loading embeddings from storage: $e");
//       return {};
//     }
//   }
//
//   // Generate face embedding using the TFLite model
//   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
//     if (_interpreter == null) {
//       print("Interpreter is not initialized.");
//       return null;
//     }
//
//     try {
//       final inputImage = await croppedFace.readAsBytes();
//       img.Image? imgCropped = img.decodeImage(inputImage);
//       if (imgCropped == null) return null;
//
//       var input = _preprocessImage(imgCropped);
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//
//       _interpreter!.run(reshapedInput, output);
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding for cropped face image: ${croppedFace.path}, Error: $e");
//       return null;
//     }
//   }
//   Future<List<File?>> cropFaces(File imageFile, List<Face> faces) async {
//     List<File?> croppedFiles = [];
//     final bytes = await imageFile.readAsBytes();
//     i.Image? originalImage = i.decodeImage(bytes);
//
//     if (originalImage == null) return croppedFiles;
//
//     for (var face in faces) {
//       final boundingBox = face.boundingBox;
//       int left = boundingBox.left.toInt();
//       int top = boundingBox.top.toInt();
//       int width = boundingBox.width.toInt();
//       int height = boundingBox.height.toInt();
//
//       i.Image croppedImage = i.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//       i.Image resizedCroppedImage = i.copyResize(croppedImage, width: 160, height: 160, interpolation: i.Interpolation.cubic);
//
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
//       await croppedFile.writeAsBytes(i.encodePng(resizedCroppedImage));
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
//   }
//
//   // Preprocess the image before feeding it into the TFLite model
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         convertedBytes[pixelIndex++] = (pixel.r - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.g - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.b - 128) / 128.0;
//       }
//     }
//     return convertedBytes;
//   }
//
//   // Compare the current image embedding with all embeddings
//   Future<void> compareEmbeddings(List<double> currentEmbeddingVector) async {
//     if (allEmbeddings.isEmpty) return;
//
//     for (var entry in allEmbeddings.entries) {
//       double similarity = cosineSimilarity(currentEmbeddingVector, entry.value);
//       if (similarity > 0.60) {
//         matchingImages.add(File(entry.key));
//         print('Found similar image: ${entry.key} with similarity: $similarity');
//         // You can handle displaying or storing matching images here
//       }
//       else
//         {
//           print( 'no fond');
//         }
//     }
//   }
//
//   // Calculate cosine similarity between two embeddings
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detected Faces')),
//       body: isProcessing
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 4,
//           crossAxisSpacing: 4,
//         ),
//         itemCount: matchingImages.length,
//         itemBuilder: (context, index) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               matchingImages[index],
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// .......................................................................
//
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:fast_image_resizer/fast_image_resizer.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as i;
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' images img;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
//
// class FaceDetectionScreen extends StatefulWidget {
//   final List<Medium> pictureList;
//   final Medium currentImage;
//
//   FaceDetectionScreen({required this.pictureList, required this.currentImage});
//
//   @override
//   _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   Map<String, List<double>> allEmbeddings = {}; // Store embeddings for all images
//   Map<String, List<double>> currentEmbedding = {}; // Store embedding for current image
//   Interpreter? _interpreter;
//   List<File> detectedFaces = [];
//   List<File> resizedImages = [];
//   bool isProcessing = false;
//   final int batchSize = 50;
//   List<File> matchingImages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel().then((_) => processImages());
//   }
//
//   // Load the TFLite model for face embeddings
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   // Main image processing logic with new logic added to skip already processed embeddings
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//       resizedImages.clear(); // Clear previous images
//     });
//
//     // Load saved embeddings from local storage
//     Map<String, List<double>> allEmbeddings = await loadEmbeddingsFromLocalStorage();
//     print(allEmbeddings.length);
//     print("..........................................");
//
//     final totalImages = 53;
//     final storedEmbeddingsCount = allEmbeddings.length;
//
//     // Check if stored embeddings match the total number of images
//     if (storedEmbeddingsCount >= totalImages) {
//       // Skip face detection and embedding generation
//       print("Stored embeddings are up-to-date. Skipping face detection and embedding generation.");
//       await processNewImages(storedEmbeddingsCount, currentEmbedding, totalImages);
//       await compareEmbeddings(allEmbeddings.values.toList());
//     } else {
//       // Process only new images
//       print("Found new images. Processing embeddings for new images.");
//       await processNewImages(storedEmbeddingsCount, allEmbeddings, totalImages);
//     }
//
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   // Process only new images that don't have embeddings yet
//   Future<void> processNewImages(int storedEmbeddingsCount, Map<String, List<double>> allEmbeddings, int totalImages) async {
//     final newImagesCount = totalImages - storedEmbeddingsCount;
//
//     // Process the new images only
//     for (var i = storedEmbeddingsCount; i < storedEmbeddingsCount + newImagesCount; i += batchSize) {
//       final batch = widget.pictureList.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           var imageFileName = p.basenameWithoutExtension(imageFile.path);
//
//           if (!allEmbeddings.containsKey(imageFileName)) {
//             // Only process images without stored embeddings
//             print("Processing new image: $imageFileName");
//             batchFiles.add(imageFile);
//           }
//         }
//       }
//
//       if (batchFiles.isNotEmpty) {
//         final List<File?> resizedBatchFiles = await resizeImagesAndSave(batchFiles, 300, 300);
//         setState(() {
//           resizedImages.addAll(resizedBatchFiles.whereType<File>());
//         });
//
//         // Detect faces and generate embeddings for new images
//         final faceDetector = FaceDetector(
//           options: FaceDetectorOptions(
//             performanceMode: FaceDetectorMode.fast,
//             enableLandmarks: false,
//             enableClassification: false,
//             enableContours: false,
//             enableTracking: false,
//           ),
//         );
//
//         await detectFacesAndGenerateEmbeddings(resizedBatchFiles, faceDetector, allEmbeddings);
//
//         // Save updated embeddings to local storage
//         await saveEmbeddingsToLocalStorage(allEmbeddings);
//
//         faceDetector.close(); // Close detector after use
//       }
//     }
//   }
//
//   // Detect faces, generate embeddings, and compare embeddings logic remains unchanged
//   Future<void> detectFacesAndGenerateEmbeddings(List<File?> resizedFiles, FaceDetector faceDetector, Map<String, List<double>> embeddingsMap) async {
//     for (var resizedFile in resizedFiles) {
//       if (resizedFile == null) continue;
//
//       final inputImage = InputImage.fromFile(resizedFile);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         final croppedFaces = await cropFaces(resizedFile, faces);
//         for (var croppedFace in croppedFaces) {
//           if (croppedFace != null) {
//             final embedding = await getFaceEmbedding(croppedFace);
//             if (embedding != null) {
//               embeddingsMap[resizedFile.path] = embedding; // Store embedding in the map
//             }
//           }
//         }
//       }
//     }
//   }
//
//   Future<List<File?>> cropFaces(File imageFile, List<Face> faces) async {
//     List<File?> croppedFiles = [];
//     final bytes = await imageFile.readAsBytes();
//     i.Image? originalImage = i.decodeImage(bytes);
//
//     if (originalImage == null) return croppedFiles;
//
//     for (var face in faces) {
//       final boundingBox = face.boundingBox;
//       int left = boundingBox.left.toInt();
//       int top = boundingBox.top.toInt();
//       int width = boundingBox.width.toInt();
//       int height = boundingBox.height.toInt();
//
//       i.Image croppedImage = i.copyCrop(originalImage, x: left, y: top, width: width, height: height);
//       i.Image resizedCroppedImage = i.copyResize(croppedImage, width: 160, height: 160, interpolation: i.Interpolation.cubic);
//
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
//       await croppedFile.writeAsBytes(i.encodePng(resizedCroppedImage));
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
//   }
//
//
//   Future<List<double>?> getFaceEmbedding(File croppedFace) async {
//     if (_interpreter == null) {
//       print("Interpreter is not initialized.");
//       return null;
//     }
//
//     try {
//       final inputImage = await croppedFace.readAsBytes();
//       img.Image? imgCropped = img.decodeImage(inputImage);
//       if (imgCropped == null) return null;
//
//       var input = _preprocessImage(imgCropped);
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//
//       _interpreter!.run(reshapedInput, output);
//       return output[0];
//     } catch (e) {
//       print("Error generating embedding for cropped face image: ${croppedFace.path}, Error: $e");
//       return null;
//     }
//   }
//
//
//   Float32List _preprocessImage(img.Image image) {
//     var convertedBytes = Float32List(160 * 160 * 3);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 160; i++) {
//       for (var j = 0; j < 160; j++) {
//         var pixel = image.getPixel(j, i);
//         convertedBytes[pixelIndex++] = (pixel.r - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.g - 128) / 128.0;
//         convertedBytes[pixelIndex++] = (pixel.b - 128) / 128.0;
//       }
//     }
//     return convertedBytes;
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   // Resize images and save them
//   Future<List<File?>> resizeImagesAndSave(List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<File?> resizedFiles = [];
//     print("Resizing images and saving as files...");
//
//     for (var imageFile in imageFiles) {
//       try {
//         final originalBytes = await imageFile.readAsBytes();
//         final ByteData? resizedBytes = await resizeImage(Uint8List.fromList(originalBytes), width: targetWidth, height: targetHeight);
//
//         if (resizedBytes != null) {
//           final tempDir = Directory.systemTemp;
//           final resizedFile = File('${tempDir.path}/${imageFile.uri.pathSegments.last}.png');
//           await resizedFile.writeAsBytes(Uint8List.view(resizedBytes.buffer));
//           resizedFiles.add(resizedFile);
//         } else {
//           resizedFiles.add(null);
//         }
//       } catch (e) {
//         print("Error processing image ${imageFile.path}: $e");
//         resizedFiles.add(null);
//       }
//     }
//
//     return resizedFiles;
//   }
//
//   // Save embeddings to local storage
//   Future<void> saveEmbeddingsToLocalStorage(Map<String, List<double>> embeddings) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/embeddings_data.json';
//       final file = File(filePath);
//
//       Map<String, dynamic> jsonData = embeddings.map((key, value) => MapEntry(key, value));
//       String jsonString = json.encode(jsonData);
//
//       await file.writeAsString(jsonString);
//       print("Embeddings saved successfully.");
//     } catch (e) {
//       print("Error saving embeddings to storage: $e");
//     }
//   }
//
//   // Load embeddings from local storage
//   Future<Map<String, List<double>>> loadEmbeddingsFromLocalStorage() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/embeddings_data.json';
//       final file = File(filePath);
//
//       if (await file.exists()) {
//         String jsonString = await file.readAsString();
//         Map<String, dynamic> jsonData = json.decode(jsonString);
//
//         Map<String, List<double>> embeddings = jsonData.map((key, value) => MapEntry(key, List<double>.from(value)));
//         print("Embeddings loaded successfully.");
//         return embeddings;
//       } else {
//         print("No saved embeddings found.");
//         return {};
//       }
//     } catch (e) {
//       print("Error loading embeddings from storage: $e");
//       return {};
//     }
//   }
//
//   // Compare the current image embedding with all embeddings
//   Future<void> compareEmbeddings(List<List<double>> allEmbeddingsList) async {
//     print(currentEmbedding);
//     if (allEmbeddings.isEmpty) return;
//
//     for (var entry in allEmbeddings.entries) {
//       double similarity = cosineSimilarity(currentEmbedding.values.first, entry.value);
//       if (similarity > 0.60) {
//         matchingImages.add(File(entry.key));
//         print('Found similar image: ${entry.key} with similarity: $similarity');
//       }
//     }
//   }
//
//   // Cosine similarity function
//   double cosineSimilarity(List<double> vecA, List<double> vecB) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//
//     for (int i = 0; i < vecA.length; i++) {
//       dotProduct += vecA[i] * vecB[i];
//       normA += vecA[i] * vecA[i];
//       normB += vecB[i] * vecB[i];
//     }
//
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detected Faces')),
//       body: isProcessing
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 4,
//           crossAxisSpacing: 4,
//         ),
//         itemCount: matchingImages.length,
//         itemBuilder: (context, index) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               matchingImages[index],
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
