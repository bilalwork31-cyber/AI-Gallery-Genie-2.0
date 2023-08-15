import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cts/temp/text_embeding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import '../Model/ImagelabelingProvider.dart';

class Imagelabelscreen extends StatelessWidget {
  final List<Medium> pictureList;

  const Imagelabelscreen({Key? key, required this.pictureList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ImageLabelingProvider();

        provider.classifyImagesInBatch(pictureList);

        return provider;
      },
      child: Scaffold(
        backgroundColor: Colors.black12,
        body: Consumer<ImageLabelingProvider>(
          builder: (context, provider, _) {
            Map<String, List<String>> groupedPaths = {};

            provider.imageCategoryMap.forEach((key, value) {
              String label = value['label'];
              String path = value['path'];

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

            final Random random = Random();

            Color getRandomColor() {
              List<Color> colors = [
                Colors.lightGreenAccent,
                Colors.orangeAccent
              ];
              return colors[random.nextInt(colors.length)];
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(

                    onTap: (){

                      Navigator.push(context, MaterialPageRoute(builder: (_) => TextEmbedding()));
                    },
                      child: SearchBar()),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        "Explore Unique Categories",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: GridView.custom(
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 4,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: [
                          QuiltedGridTile(2, 2),
                          QuiltedGridTile(1, 2),
                          QuiltedGridTile(2, 2),
                          QuiltedGridTile(1, 2),
                        ],
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) {

                          String label = groupedPaths.keys.elementAt(index);
                          String firstImagePath = groupedPaths[label]!.first;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageDetailScreen(
                                    label: label,
                                    images: groupedPaths[label]!,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                    height: 200,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      child: Image.file(
                                        File(firstImagePath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 1, sigmaY: 1),
                                      child: Container(
                                        color: Colors.black.withOpacity(0),
                                        height: 200,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.498),
                                      height: 200,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    child: FittedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          label.toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: getRandomColor(), width: 3),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                    height: 200,
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: groupedPaths.keys.length,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final String label;
  final List<String> images;

  ImageDetailScreen({required this.label, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(label),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              clipBehavior: Clip.hardEdge,
              color: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 60,
                height: 60,
                child: FutureBuilder<Uint8List>(
                  future: _loadImageBytes(images[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading image'));
                    } else if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Center(child: Text('No image data'));
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to load image as bytes
  Future<Uint8List> _loadImageBytes(String imagePath) async {
    File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      return imageFile.readAsBytes();
    } else {
      throw Exception('Image file not found');
    }
  }
}
class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Icon(
          Icons.search,
          color: Colors.white,
    );
  }
}