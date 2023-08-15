// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as imag;
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_gallery/photo_gallery.dart';
//
// import '../Model-View/sar_output.dart';
//
// class OutpaintPage extends StatefulWidget {
//   final Medium image;
//
//   const OutpaintPage({Key? key, required this.image}) : super(key: key);
//
//   @override
//   _OutpaintPageState createState() => _OutpaintPageState();
// }
//
// class _OutpaintPageState extends State<OutpaintPage> {
//   double leftOffset = 0;
//   double rightOffset = 0;
//   double topOffset = 0;
//   double bottomOffset = 0;
//
//   final double maxExpand = 100; // Max expansion in pixels for each direction
//   final double handleSize = 20;
//   final String apiKey = dotenv.env['API_Key0'] ?? 'default_key';
//   File? imageFile;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeImageFile();
//   }
//
//   Future<void> _initializeImageFile() async {
//     // Get the file from the Medium object
//     final imageFile = await widget.image.getFile();
//     setState(() {}); // Update the UI
//   }
// // Size of draggable handles
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Outpaint Image'),
//       ),
//       body: Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Display the image
//             imageFile!=null ?
//               Positioned(
//               left: leftOffset,
//               top: topOffset,
//               right: rightOffset,
//               bottom: bottomOffset,
//               child: Image.file(imageFile!),
//             ) : CircularProgressIndicator(),
//
//             // Draggable handles for top, bottom, left, and right
//             _buildDraggableHandle(
//               Alignment.topCenter,
//               onDrag: (delta) {
//                 setState(() {
//                   topOffset = (topOffset - delta.dy).clamp(-maxExpand, maxExpand);
//                 });
//               },
//             ),
//             _buildDraggableHandle(
//               Alignment.bottomCenter,
//               onDrag: (delta) {
//                 setState(() {
//                   bottomOffset = (bottomOffset + delta.dy).clamp(-maxExpand, maxExpand);
//                 });
//               },
//             ),
//             _buildDraggableHandle(
//               Alignment.centerLeft,
//               onDrag: (delta) {
//                 setState(() {
//                   leftOffset = (leftOffset - delta.dx).clamp(-maxExpand, maxExpand);
//                 });
//               },
//             ),
//             _buildDraggableHandle(
//               Alignment.centerRight,
//               onDrag: (delta) {
//                 setState(() {
//                   rightOffset = (rightOffset + delta.dx).clamp(-maxExpand, maxExpand);
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _submitOutpaintingRequest,
//         child: const Icon(Icons.done),
//       ),
//     );
//   }
//
//   /// Build a draggable handle
//   Widget _buildDraggableHandle(Alignment alignment, {required Function(Offset delta) onDrag}) {
//     return Positioned.fill(
//       child: Align(
//         alignment: alignment,
//         child: GestureDetector(
//           onPanUpdate: (details) => onDrag(details.delta),
//           child: Container(
//             width: handleSize,
//             height: handleSize,
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Submit the outpainting request to the API
//   Future<void> _submitOutpaintingRequest() async {
//     final originalImage = imageFile;
//
//     // Calculate expanded dimensions (offsets are negative for inward movement)
//     final expandedDimensions = {
//       'top': topOffset.abs(),
//       'bottom': bottomOffset.abs(),
//       'left': leftOffset.abs(),
//       'right': rightOffset.abs(),
//     };
//
//     // Replace this with your API request
//     print('Sending dimensions to API: $expandedDimensions');
//
//     // Example API call (use real implementation in your app)
//        if(originalImage!=null) {
//          await _callOutpaintingAPI(
//              imageFile: originalImage, dimensions: expandedDimensions);
//        }
//   }
//
//   /// Example function for sending API request (use your actual API logic)
//
//
//
//
//   Future<void> _callOutpaintingAPI({
//     required File imageFile,
//     required Map<String, double> dimensions,
//
//   }) async {
//     // Validate the image before proceeding
//     if (!await _validateImage(imageFile)) {
//       _showResponseMessage(
//         context,
//         "Ensure dimensions are valid. Try another image.",
//       );
//       return;
//     }
//
//     // Resize the image if needed
//     File resizedImage = await _resizeImageToPixelLimit(imageFile);
//
//     // Prepare the API request
//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://api.stability.ai/v2beta/stable-image/edit/outpainting'),
//       );
//
//       request.headers['Authorization'] = 'Bearer $apiKey';
//       request.headers['Accept'] = 'image/*';
//
//       // Attach the resized image
//       request.files.add(await http.MultipartFile.fromPath('image', resizedImage.path));
//
//       // Add dimensions to the request
//       request.fields['top'] = dimensions['top']?.toString() ?? '0';
//       request.fields['bottom'] = dimensions['bottom']?.toString() ?? '0';
//       request.fields['left'] = dimensions['left']?.toString() ?? '0';
//       request.fields['right'] = dimensions['right']?.toString() ?? '0';
//
//       // Send the request
//       final response = await http.Response.fromStream(await request.send());
//
//       // Handle the response
//       if (response.statusCode == 200) {
//         final imageBytes = response.bodyBytes;
//
//         // Navigate to the output page
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OutputPage(imageFile: imageBytes),
//           ),
//         );
//       } else {
//         _showResponseMessage(
//           context,
//           "API error: ${response.statusCode} - ${response.reasonPhrase}",
//         );
//       }
//     } catch (e) {
//       _showResponseMessage(context, "An error occurred: $e");
//     }
//   }
//
//   /// Validate image dimensions and aspect ratio
//   Future<bool> _validateImage(File imageFile) async {
//     final imag.Image? image = imag.decodeImage(await imageFile.readAsBytes());
//     if (image == null) return false;
//
//     int width = image.width;
//     int height = image.height;
//     int totalPixels = width * height;
//     double aspectRatio = width / height;
//
//     return width >= 64 &&
//         height >= 64 &&
//         totalPixels >= 4096 &&
//         totalPixels <= 9437184 &&
//         aspectRatio >= 1 / 2.5 &&
//         aspectRatio <= 2.5;
//   }
//
//   /// Resize the image to fit within pixel limits
//   Future<File> _resizeImageToPixelLimit(File imageFile) async {
//     final imag.Image originalImage = imag.decodeImage(await imageFile.readAsBytes())!;
//     int width = originalImage.width;
//     int height = originalImage.height;
//
//     const int maxPixels = 9437184;
//     const int minPixels = 4096;
//     int totalPixels = width * height;
//
//     if (totalPixels > maxPixels) {
//       double scaleFactor = sqrt(maxPixels / totalPixels);
//       width = (width * scaleFactor).floor();
//       height = (height * scaleFactor).floor();
//     } else if (totalPixels < minPixels) {
//       double scaleFactor = sqrt(minPixels / totalPixels);
//       width = (width * scaleFactor).floor();
//       height = (height * scaleFactor).floor();
//     }
//
//     final imag.Image resizedImage =
//     imag.copyResize(originalImage, width: width, height: height);
//
//     final tempDir = await getTemporaryDirectory();
//     final resizedImageFile = File('${tempDir.path}/resized_image.png');
//     await resizedImageFile.writeAsBytes(imag.encodePng(resizedImage));
//
//     return resizedImageFile;
//   }
//
//   /// Display a message to the user
//   void _showResponseMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//
// }
