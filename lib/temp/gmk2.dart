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
// import 'package:transparent_image/transparent_image.dart';
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
//   Map<String, List<double>> allEmbeddings =
//       {}; // Store embeddings for all images
//   List<double>? currentEmbedding; // Store embedding for current image
//   Interpreter? _interpreter;
//   List<File> detectedFaces = [];
//   List<File> resizedImages = [];
//   bool isProcessing = false;
//   final int batchSize = 5;
//   List<File> matchingImages = [];
//   Set<String> processedFiles = {}; // Set to track processed image filenames
//    List<Medium> matchingimagelist = [];
//   List<img.Image?> originalImages = [];
//   int batchcountr  = 1;
//   @override
//   void initState() {
//     super.initState();
//     loadModel().then((_) => processImages());
//   }
//
//   // Load the TFLite model for face embeddings
//   Future<void> loadModel() async {
//     try {
//       _interpreter =
//           await Interpreter.fromAsset('model/facenet_512_int_quantized.tflite');
//       print("Model loaded successfully.");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   // Main image processing logic
//   Future<void> processImages() async {
//     setState(() {
//       isProcessing = true; // Set processing state
//       resizedImages.clear(); // Clear previous images
//     });
//
//     // Load saved embeddings from local storage
//     allEmbeddings = await loadEmbeddingsFromLocalStorage();
//     print(allEmbeddings.length);
//     processedFiles = allEmbeddings.keys.toSet();
//     print(".........$batchcountr.........");
//     print(allEmbeddings.keys); // Track already processed filenames
//     print("Loaded ${processedFiles.length} embeddings from storage.");
//
//     // Check if all embeddings are already generated
//     final totalImages = 65;
//     final storedEmbeddingsCount = processedFiles.length;
//     print(storedEmbeddingsCount);
//     // Process only new images if embeddings are incomplete
//     if (storedEmbeddingsCount >= totalImages) {
//       print("All images are already processed. Skipping to comparison.");
//     } else {
//       print("Found new images. Processing new images only.");
//       await processNewImages(storedEmbeddingsCount);
//       batchcountr++;
//     }
//
//     // After processing new images, compare embeddings for similarity
//     await compareEmbeddings();
//     print("im back");
//     setState(() {
//       isProcessing = false; // Reset processing state
//     });
//   }
//
//   // Process only new images that don't have embeddings yet
//   Future<void> processNewImages(int storedEmbeddingsCount) async {
//     final newImagesCount = widget.pictureList.length - storedEmbeddingsCount;
//     final limitedImages = widget.pictureList.take(65).toList();
//
//     // Process new images only
//     for (var i = storedEmbeddingsCount;
//         i < storedEmbeddingsCount + newImagesCount;
//         i += batchSize) {
//       final batch = limitedImages.skip(i).take(batchSize);
//       List<File> batchFiles = [];
//
//       for (var medium in batch) {
//         File? imageFile = await medium.getFile();
//         if (imageFile != null) {
//           var imageFileName = p.basenameWithoutExtension(imageFile.path);
//
//           // Process only if embedding is not already generated
//           if (!processedFiles.contains(imageFileName)) {
//             print("Processing new image: $imageFileName");
//             batchFiles.add(imageFile);
//           }
//         }
//       }
//
//       if (batchFiles.isNotEmpty) {
//         // Resize images to 300x300 and process
//         final List<File?> resizedBatchFiles =
//             await resizeImagesAndSave(batchFiles, 640, 640);
//         setState(() {
//           resizedImages.addAll(resizedBatchFiles.whereType<File>());
//         });
//
//         // Detect faces and generate embeddings for new images
//         final faceDetector = FaceDetector(
//           options: FaceDetectorOptions(
//               performanceMode: FaceDetectorMode.accurate,
//               enableLandmarks: false,
//               enableClassification: false,
//               enableContours: false,
//               enableTracking: false,
//               minFaceSize: 0.2),
//         );
//
//         await detectFacesAndGenerateEmbeddings(batchFiles, faceDetector);
//
//         // Save updated embeddings to local storage
//         await saveEmbeddingsToLocalStorage(allEmbeddings);
//
//         //Close detector after use
//       }
//     }
//   }
//
//
//
//   Future<void> detectFacesAndGenerateEmbeddings(
//       List<File?> resizedFiles, FaceDetector faceDetector) async {
//     for (var resizedFile in resizedFiles) {
//       if (resizedFile == null) continue;
//
//       final inputImage = InputImage.fromFile(resizedFile);
//       final List<Face> faces = await faceDetector.processImage(inputImage);
//
//       if (faces.isNotEmpty) {
//         // If faces are detected, process them
//         final croppedFaces = await cropFaces(resizedFile, faces);
//         for (var croppedFace in croppedFaces) {
//           if (croppedFace != null) {
//             final embedding = await getFaceEmbedding(croppedFace);
//             if (embedding != null) {
//               allEmbeddings[resizedFile.path] = embedding; // Store embedding
//               processedFiles.add(resizedFile.path); // Mark as processed
//             }
//           }
//         }
//       } else {
//         // If no faces are detected, store the filename with a value of "non"
//         allEmbeddings[resizedFile.path] = []; // Store as non-human
//         processedFiles.add(resizedFile.path); // Mark as processed
//         print("Stored non-human image: ${resizedFile.path}");
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
//       i.Image croppedImage = i.copyCrop(originalImage,
//           x: left, y: top, width: width, height: height);
//       i.Image resizedCroppedImage = i.copyResize(croppedImage,
//           width: 160, height: 160, interpolation: i.Interpolation.cubic);
//
//       final tempDir = Directory.systemTemp;
//       File croppedFile = File(
//           '${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.png');
//       await croppedFile.writeAsBytes(i.encodePng(resizedCroppedImage));
//       croppedFiles.add(croppedFile);
//     }
//
//     return croppedFiles;
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
//
//       var reshapedInput = input.reshape([1, 160, 160, 3]);
//       var output = List.filled(512, 0.0).reshape([1, 512]);
//       print(reshapedInput);
//       _interpreter!.run(reshapedInput, output);
//       print(output);
//       return output[0];
//     } catch (e) {
//       print(
//           "Error generating embedding for cropped face image: ${croppedFace.path}, Error: $e");
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
//   // Resize images and save them
//   Future<List<File?>> resizeImagesAndSave(
//       List<File> imageFiles, int targetWidth, int targetHeight) async {
//     List<File?> resizedFiles = [];
//     print("Resizing images and saving as files...");
//
//     for (var imageFile in imageFiles) {
//       try {
//         final originalBytes = await imageFile.readAsBytes();
//         final ByteData? resizedBytes = await resizeImage(
//             Uint8List.fromList(originalBytes),
//             width: targetWidth,
//             height: targetHeight);
//
//         if (resizedBytes != null) {
//           final tempDir = Directory.systemTemp;
//           final resizedFile =
//               File('${tempDir.path}/${imageFile.uri.pathSegments.last}.png');
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
//   Future<void> saveEmbeddingsToLocalStorage(
//       Map<String, List<double>> embeddings) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/embeddings_data.json';
//       print(filePath);
//       final file = File(filePath);
//
//       // Convert embeddings map to JSON format
//       Map<String, dynamic> jsonData =
//           embeddings.map((key, value) => MapEntry(key, value));
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
//         Map<String, List<double>> embeddings = jsonData
//             .map((key, value) => MapEntry(key, List<double>.from(value)));
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
//   Future<void> detectCurrentFacesAndGenerateEmbeddings(
//       File? resizedFile) async {
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
//     if (resizedFile == null) return;
//
//     final inputImage = InputImage.fromFile(resizedFile);
//     final List<Face> faces = await faceDetector.processImage(inputImage);
//
//     if (faces.isNotEmpty) {
//       final croppedFaces = await cropFaces(resizedFile, faces);
//       for (var croppedFace in croppedFaces) {
//         if (croppedFace != null) {
//           final embedding = await getFaceEmbedding(croppedFace);
//           if (embedding != null) {
//             if (embedding.length < 2) {
//               allEmbeddings[resizedFile.path] = embedding; // Store embedding
//               processedFiles.add(resizedFile.path);
//             } else {
//               currentEmbedding = embedding; // Store embedding
//             }
//           }
//         }
//       }
//     }
//     faceDetector.close();
//   }
//
//   List<Medium> findMatchingImages(
//       List<File> matchingImages, List<Medium> pictureList) {
//     // Step 1: Extract filenames from matchingImages and store them in a set for quick lookup
//     final Set<String> matchingFilenames = matchingImages
//         .map((file) => p.basenameWithoutExtension(file.path))
//         .toSet();
//
//     // Step 2: Iterate over the pictureList and find matches
//     List<Medium> matchingImageList = pictureList.where((medium) {
//       // Extract the filename from Medium
//       final mediumFilename = p.basenameWithoutExtension(medium.filename ?? '');
//
//       // Step 3: Check if the filename is in the matchingFilenames set
//       return matchingFilenames.contains(mediumFilename);
//     }).toList();
//
//     // Step 4: Return the list of matching Medium objects
//     return matchingImageList;
//   }
//
//   // Compare embeddings and display matching images
//   Future<void> compareEmbeddings() async {
//     if (currentEmbedding == null) {
//       await detectCurrentFacesAndGenerateEmbeddings(
//           await widget.currentImage.getFile());
//       if (currentEmbedding == null) return;
//     }
//
//     List<File> matches = [];
//
//     // Iterate over all embeddings
//     allEmbeddings.forEach((filePath, embedding) {
//       // Skip embeddings that are marked as "non" or "0"
//       if (embedding.isEmpty) {
//         print("Skipping file: $filePath due to non-human or zero embedding.");
//         return; // Skip this entry
//       }
//
//       print('im inside this');
//       double similarity =
//           calculateCosineSimilarity(currentEmbedding!, embedding);
//
//       if (similarity > 0.65) {
//         print(similarity);
//
//         final filePathWithoutExtension = p.withoutExtension(filePath);
//
//         // Add the file without extension to matches
//         matches.add(File(filePathWithoutExtension));
//       } else {
//         print("No matching face found for: $filePath");
//       }
//     });
//
//     setState(() {
//       matchingImages = matches;
//     });
//
//     matchingimagelist = findMatchingImages(matchingImages, widget.pictureList);
//
//     // Debug output for the matching image list
//     if (matchingimagelist.isNotEmpty) {
//       print(matchingimagelist[0].filename);
//     } else {
//       print("No matching images found in the gallery.");
//     }
//   }
//
//   // Calculate cosine similarity
//   double calculateCosineSimilarity(
//       List<double> embedding1, List<double> embedding2) {
//     double dotProduct = 0.0;
//     double normA = 0.0;
//     double normB = 0.0;
//     for (int i = 0; i < embedding1.length; i++) {
//       dotProduct += embedding1[i] * embedding2[i];
//       normA += embedding1[i] * embedding1[i];
//       normB += embedding2[i] * embedding2[i];
//     }
//     return dotProduct / (sqrt(normA) * sqrt(normB));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//
//   }}
//
//
// // (
// // backgroundColor: Colors.black,
// // body: Column(
// // mainAxisAlignment: MainAxisAlignment.start,
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // SizedBox(height: 70),
// // Column(
// // children: [
// //
// // Center(
// // child: Stack(
// //
// // children :
// // [   Center(
// // child: Card(
// // clipBehavior: Clip.hardEdge,
// // color: Colors.grey.shade200,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(100),
// // ),
// // child: Container(
// // width: 116,
// // height: 116,
// // color: Colors.lightGreenAccent,
// //
// // ),
// // ),
// // ),
// //
// //
// // Positioned(
// // top: 3,
// // left: 133,
// // child: Center(
// // child: Card(
// // clipBehavior: Clip.hardEdge,
// // color: Colors.grey.shade200,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(100),
// // ),
// // child: Container(
// // width: 110,
// // height: 110,
// // child: FadeInImage(
// // placeholder: MemoryImage(kTransparentImage),
// // image: ThumbnailProvider(
// // mediumId: widget.currentImage.id,
// // mediumType: widget.currentImage.mediumType,
// // highQuality: true,
// // ),
// // fit: BoxFit.cover,
// // ),
// // ),
// // ),
// // ),
// // ),
// // ]
// // ),
// // ),
// // ],
// // ),
// // const SizedBox(height: 10),
// // const Column(
// // mainAxisAlignment: MainAxisAlignment.center,
// // crossAxisAlignment: CrossAxisAlignment.center,
// // children: [
// // Center(
// // child: Text(
// // 'Similar image found of this photo',
// // style: TextStyle(color: Colors.grey, fontSize: 13),
// // ),
// // )
// // ],
// // ),
// // const SizedBox(height: 80),
// // Expanded(
// // child: Container(
// // decoration: BoxDecoration(
// // color: Colors.grey.shade900,
// // borderRadius: BorderRadius.only(
// // topLeft: Radius.circular(25),
// // topRight: Radius.circular(25),
// // ),
// // ),
// // padding: const EdgeInsets.all(16),
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Divider(
// // thickness: 2,
// // height: 12,
// // color: Colors.lightGreenAccent,
// // indent: 140,
// // endIndent: 140,
// // ),
// // Padding(
// // padding: const EdgeInsets.all(8.0),
// // child: Text(
// // '${matchingimagelist.length} Results Found:',
// // style: TextStyle(color: Colors.white, fontSize: 14),
// // ),
// // ),
// // const SizedBox(height: 10),
// // matchingimagelist.isEmpty
// // ? Padding(
// // padding: const EdgeInsets.all(150.0),
// // child: Center(child: CircularProgressIndicator( color: Colors.lightGreenAccent,)),
// // )
// //     : Expanded(
// // child: GridView.count(
// // padding: EdgeInsets.zero,
// // crossAxisCount: 3,
// // crossAxisSpacing: 10,
// // mainAxisSpacing: 10,
// // children: List.generate(
// // matchingimagelist.length,
// // (index) {
// // final medium = matchingimagelist[index];
// //
// // return Card(
// // clipBehavior: Clip.hardEdge,
// // color: Colors.grey.shade200,
// // shape: RoundedRectangleBorder(
// // borderRadius: BorderRadius.circular(10),
// // ),
// // child: Container(
// // width: 60,
// // height: 60,
// // child: FadeInImage(
// // placeholder: MemoryImage(kTransparentImage),
// // image: ThumbnailProvider(
// // mediumId: medium.id,
// // mediumType: medium.mediumType,
// // highQuality: true,
// // ),
// // fit: BoxFit.cover,
// // ),
// // ),
// // );
// // },
// // ),
// // ),
// // ),
// // ],
// // ),
// // ),
// // ),
// // ],
// // ),
// // )