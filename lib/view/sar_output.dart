import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class OutputPage extends StatelessWidget {
  final Uint8List imageFile;

  const OutputPage({Key? key, required this.imageFile}) : super(key: key);

  Future<void> saveImage(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      String filePath = '${directory.path}/output_image.png';

      File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      await GallerySaver.saveImage(file.path);

      print('Image saved successfully to gallery!');
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Generated Image"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save_alt,
              color: Colors.white,
            ),
            onPressed: () async {
              await saveImage(imageFile);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image saved to gallery!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: imageFile.isNotEmpty
                    ? Image.memory(
                        imageFile,
                        fit: BoxFit.contain,
                      )
                    : const Text("Error Occurred",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await saveImage(imageFile);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image saved to gallery!')),
                );
              },
              child: Container(
                width: 250,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent,
                      Colors.orange,
                    ], // Gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2), // Slight shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save, color: Colors.white), // Icon in the button
                    SizedBox(width: 8),
                    Text(
                      'Save Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
