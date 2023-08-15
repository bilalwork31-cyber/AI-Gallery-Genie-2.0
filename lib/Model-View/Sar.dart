import 'dart:io';
import 'dart:math';
import 'package:cts/view/sar_output.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imag;
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';

import '../Model/CoinUpdaterFirebaseProvider.dart';

class SearchAndReplacePage extends StatefulWidget {
  final Medium imageFile;
  final bool checker;

  const SearchAndReplacePage({Key? key, required this.imageFile, required this.checker})
      : super(key: key);

  @override
  _SearchAndReplacePageState createState() => _SearchAndReplacePageState();
}

class _SearchAndReplacePageState extends State<SearchAndReplacePage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _searchPromptController = TextEditingController();
  File? _imageFile;
  bool _isprocessing = false;

  String? _responseMessage;
  String apiKey = dotenv.env['API_Key0'] ?? 'default_key';

  @override
  void initState() {
    super.initState();
    _initializeImageFile();
  }

  Future<void> _initializeImageFile() async {
    // Get the file from the Medium object
    _imageFile = await widget.imageFile.getFile();
    setState(() {}); // Update the UI
  }

  Future<void> _processImage() async {
    final File? file = await widget.imageFile.getFile();
    if (file != null) {
      if (!await _validateImage(file)) {
        setState(() {
          _responseMessage = "Ensure dimensions are invalid"
              "Try other image";
        });
        return;
      }

      File resizedImage = await resizeImageToPixelLimit(file);

      String prompt = _promptController.text.trim();
      String searchPrompt = _searchPromptController.text.trim();

      if (prompt.isEmpty || searchPrompt.isEmpty) {
        setState(() {
          _responseMessage =
              "Please provide both the prompt and search prompt.";
        });
        return;
      }

      try {
        setState(() {
          _isprocessing = true;
        });
        final response = await _callSearchAndReplaceAPI(
          imageFile: resizedImage,
          prompt: prompt,
          searchPrompt: searchPrompt,
        );

        if (response.statusCode == 200) {
          FirebaseCoinProvider provider = FirebaseCoinProvider();
          await provider.deductCredits(4);
          final imageBytes = response.bodyBytes; // Get the image bytes

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OutputPage(imageFile: imageBytes),
            ),
          );
        } else {
          setState(() {
            _responseMessage =
                "API error: ${response.statusCode} - ${response.reasonPhrase}";
          });
        }
      } catch (e) {
        setState(() {
          _responseMessage = "An error occurred: $e";
        });
      }
    }
  }

  Future<bool> _validateImage(File imageFile) async {
    final imag.Image? image = imag.decodeImage(await imageFile.readAsBytes());
    if (image == null) return false;

    int width = image.width;
    int height = image.height;
    int totalPixels = width * height;
    double aspectRatio = width / height;

    return width >= 64 &&
        height >= 64 &&
        totalPixels >= 4096 &&
        totalPixels <= 9437184 &&
        aspectRatio >= 1 / 2.5 &&
        aspectRatio <= 2.5;
  }

  Future<File> resizeImageToPixelLimit(File imageFile) async {
    final imag.Image originalImage =
        imag.decodeImage(await imageFile.readAsBytes())!;
    int width = originalImage.width;
    int height = originalImage.height;

    const int maxPixels = 9437184;
    const int minPixels = 4096;
    int totalPixels = width * height;

    if (totalPixels > maxPixels) {
      double scaleFactor = sqrt(maxPixels / totalPixels);
      width = (width * scaleFactor).floor();
      height = (height * scaleFactor).floor();
    } else if (totalPixels < minPixels) {
      double scaleFactor = sqrt(minPixels / totalPixels);
      width = (width * scaleFactor).floor();
      height = (height * scaleFactor).floor();
    }

    final imag.Image resizedImage =
        imag.copyResize(originalImage, width: width, height: height);

    final tempDir = await getTemporaryDirectory();
    final resizedImageFile = File('${tempDir.path}/resized_image.png');
    await resizedImageFile.writeAsBytes(imag.encodePng(resizedImage));

    return resizedImageFile;
  }

  Future<http.Response> _callSearchAndReplaceAPI({
    required File imageFile,
    required String prompt,
    required String searchPrompt,
  }) async {
    if(widget.checker==true){
      final request = http.MultipartRequest('POST', Uri.parse('https://api.stability.ai/v2beta/stable-image/edit/search-and-replace'));
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Accept'] = 'image/*';

      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      request.fields['prompt'] = prompt;
      request.fields['search_prompt'] = searchPrompt;

      return await http.Response.fromStream(await request.send());
    }
    else if(widget.checker==false)
      {
        final request = http.MultipartRequest('POST', Uri.parse('https://api.stability.ai/v2beta/stable-image/edit/search-and-recolor'));
        request.headers['Authorization'] = 'Bearer $apiKey';
        request.headers['Accept'] = 'image/*';

        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
        request.fields['prompt'] = prompt;
        request.fields['select_prompt'] = searchPrompt;

        return await http.Response.fromStream(await request.send());

  }

    final request = http.MultipartRequest('POST', Uri.parse('https://api.stability.ai/v2beta/stable-image/edit/search-and-replace'));
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.headers['Accept'] = 'image/*';

    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['prompt'] = prompt;
    request.fields['search_prompt'] = searchPrompt;

    return await http.Response.fromStream(await request.send());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: const Text("Search and Replace"),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageFile == null
                ? const Center(child: Text("No image available."))
                : Image.file(_imageFile!),
            const SizedBox(height: 20),
            TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter your prompt",
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      const BorderSide(color: Colors.orange, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.black12,
                prefixIcon: const Icon(Icons.text_fields, color: Colors.white),
              ),
              maxLength: 1000,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchPromptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Search prompt",
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      const BorderSide(color: Colors.orange, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.black12,
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white), // Icon
              ),
              maxLength: 1000,
            ),
            const SizedBox(height: 20),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Container(
                    width: double.infinity, // or any specific width
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    decoration: BoxDecoration(
                      gradient: _isprocessing
                          ? LinearGradient(
                              colors: [
                                Colors.grey,
                                Colors.grey
                              ], // Green and orange gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.greenAccent,
                                Colors.orange
                              ], // Green and orange gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isprocessing
                        ? Center(
                            child: Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: _processImage, // Action for button press
                            child: Text(
                              'Generate Image',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                            )))),
            const SizedBox(height: 20),
            if (_responseMessage != null)
              Center(
                child: Text(
                  _responseMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
