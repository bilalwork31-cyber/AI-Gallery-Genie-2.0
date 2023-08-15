import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data'; // For handling byte data
import 'dart:io'; // For file operations

import '../Model/ImagelabelingProvider.dart';

class TextEmbedding extends StatefulWidget {
  const TextEmbedding({Key? key}) : super(key: key);

  @override
  State<TextEmbedding> createState() => _TextEmbeddingState();
}

class _TextEmbeddingState extends State<TextEmbedding> {
  Map<int, Map<String, dynamic>> ICM = {};
  List<String> mostSimilarPaths =
      []; // Store the paths of the most similar label's images

  @override
  void initState() {
    super.initState();
    callembeding();
  }

  // Method to load image categories
  Future<void> callembeding() async {
    ImageLabelingProvider provider = ImageLabelingProvider();
    await provider.loadImageCategories();
    print("imageloaded");
    print(provider.imageCategoryMap.length);
    ICM = provider.imageCategoryMap;
  }

  var data = "";
  final TextEditingController userInputController = TextEditingController();
  static const textChannel = MethodChannel("textPlatform");

  // Function to group labels
  List<String> getGroupedLabels() {
    Map<String, List<String>> groupedPaths = {};
    print("hello");
    print(ICM.length);
    ICM.forEach((key, value) {
      String label = value['label'] ?? '';
      String path = value['path'] ?? '';

      if (label == 'null' ||
          path == 'null' ||
          (path != null && label == "Christmas")) {
        return;
      }

      if (!groupedPaths.containsKey(label)) {
        groupedPaths[label] = [];
      }

      groupedPaths[label]!.add(path);
    });
    print("lenfht");
    print(groupedPaths.keys.length);
    return groupedPaths.keys.toList();
  }

  // Async function to find most similar label and display images
  Future<void> findMostSimilarLabel() async {
    try {
      List<String> labels = await getGroupedLabels();
      String userInput = userInputController.text;

      double highestScore = 0.0;
      String mostSimilarLabel = "";

      for (String label in labels) {
        print(label);
        var similarityScoreString = await textChannel.invokeMethod(
          "checkEmbedding",
          {
            "data": userInput,
            "data1": label,
          },
        );

        double similarityScore = double.tryParse(similarityScoreString) ?? 0.0;

        if (similarityScore > highestScore) {
          highestScore = similarityScore;
          mostSimilarLabel = label;

          // Store the paths for the most similar label
          mostSimilarPaths = ICM.entries
              .where((entry) => entry.value['label'] == mostSimilarLabel)
              .map((entry) => entry.value['path'] as String) // Cast to String
              .toList();
        }
      }

      setState(() {
        // Display the most similar label, its score, and the images
        data = "Most Similar Label: $mostSimilarLabel\nScore: $highestScore";
      });
    } on PlatformException catch (e) {
      setState(() {
        data = "Error: ${e.message}";
      });
    }
  }

  // Helper function to load image data into MemoryImage (for displaying images)
  Future<List<Image>> loadImages(List<String> paths) async {
    List<Image> images = [];
    for (String path in paths) {
      // Convert the path to a file
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        images.add(Image.memory(Uint8List.fromList(bytes)));
      }
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          "Semantic Searcher",
          style: TextStyle(color: Colors.black), // Text color for the app bar
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextField with white text and white label
              TextField(
                controller: userInputController,
                style: TextStyle(
                    color: Colors.white), // Text color inside TextField
                decoration: const InputDecoration(
                  labelText: 'Enter label to match',
                  labelStyle: TextStyle(color: Colors.white), // Label color
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Button with white text
              TextButton(
                onPressed: () {
                  findMostSimilarLabel(); // Remove the provider here, it's no longer needed
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0), // Adjust button size
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.lightGreenAccent
                      ], // Gradient colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(30.0), // Rounded corners
                  ),
                  child: const Text(
                    'Search Your Picture',
                    style: TextStyle(
                      color: Colors.white, // White text color
                      fontSize: 16, // Adjust font size if necessary
                      fontWeight:
                          FontWeight.bold, // Optional: bold text for emphasis
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),
              // Display data with white text
              // Text(
              //   data.isNotEmpty ? data.trim() : 'Press the button',
              //   style: TextStyle(color: Colors.white), // Text color
              // ),

              // Display the images for the most similar label
              if (mostSimilarPaths.isNotEmpty) ...[
                const SizedBox(height: 20),
                // Text(
                //   'Images:',
                //   style: TextStyle(color: Colors.white), // White text for "Images" label
                // ),
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 images per row
                    crossAxisSpacing: 8.0, // Space between images horizontally
                    mainAxisSpacing: 8.0, // Space between images vertically
                  ),
                  itemCount: mostSimilarPaths.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      File(mostSimilarPaths[
                          index]), // Assuming it's a local asset path
                      fit: BoxFit.cover, // Scale images to fill the space
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
