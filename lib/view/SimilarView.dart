import 'package:cts/Model/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../Model/similarphotoProvider.dart';

class SimilarImageView extends StatefulWidget {
  final List<Medium> images;
  final Medium current;

  const SimilarImageView({
    required this.images,
    required this.current,
    Key? key,
  }) : super(key: key);

  @override
  State<SimilarImageView> createState() => _SimilarImageViewState();
}

class _SimilarImageViewState extends State<SimilarImageView> {
  List<Medium> selectedImages = [];
  bool isSelecting = false;

  void toggleSelection(Medium image) {
    setState(() {
      if (selectedImages.contains(image)) {
        selectedImages.remove(image);
      } else {
        selectedImages.add(image);
      }
      isSelecting = selectedImages.isNotEmpty;
    });
  }

  void saveToNewAlbum(BuildContext context) async {
    final TextEditingController albumNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Album Name', style: TextStyle(fontSize: 15),),
        content: TextField(
          controller: albumNameController,
          decoration: const InputDecoration(hintText: 'Album Name', ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String albumName = albumNameController.text.trim();
              if (albumName.isNotEmpty) {
                Navigator.of(context).pop();
                _saveSelectedImages(albumName);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSelectedImages(String albumName) async {
    // Iterate through the selected images
    for (Medium image in selectedImages) {
      try {
        final file = await image.getFile();

        if (file != null) {
          final result = await GallerySaver.saveImage(
            file.path,
            albumName: albumName,
          );

          if (result == true) {
            print('Image ID: ${image.id} saved to album: $albumName');



          } else {
            print('Failed to save Image ID: ${image.id}');
          }
        } else {
          print('Failed to retrieve file for Image ID: ${image.id}');
        }
      } catch (e) {
        print('Error saving Image ID: ${image.id}, Error: $e');
      }
    }

    // final albumProvider =
    // Provider.of<AppState>(context, listen: false);
    // await albumProvider.loadAlbumsAndPictures();
    // Clear the selection and reset UI state
    setState(() {
      selectedImages.clear();
      isSelecting = false;
    });



    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Images saved to album "$albumName"')),
    );
  }


  @override
  Widget build(BuildContext context) {
    double imageWidth = (MediaQuery.of(context).size.width - 15) / 3;

    return Column(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: imageWidth * 1.1,
                    height: imageWidth * 1.1,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.lightGreenAccent, Colors.indigoAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: imageWidth,
                        height: imageWidth,
                        child: FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: ThumbnailProvider(
                            mediumId: widget.current.id,
                            mediumType: widget.current.mediumType,
                            highQuality: true,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Similar images found for this photo',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.images.length} Results Found:',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 5,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: widget.images.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      Medium medium = widget.images[index];
                      bool isSelected = selectedImages.contains(medium);

                      return InkWell(
                        onTap: () => toggleSelection(medium),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: imageWidth,
                                height: imageWidth,
                                child: FadeInImage(
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: ThumbnailProvider(
                                    mediumId: medium.id,
                                    mediumType: medium.mediumType,
                                    highQuality: true,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black45,
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (isSelecting)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.lightGreenAccent, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
                        ),
                        onPressed: () => saveToNewAlbum(context),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )

              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VIEW extends StatefulWidget {
  final Medium current;
  VIEW({Key? key, required this.current}) : super(key: key);

  @override
  State<VIEW> createState() => _VIEWState();
}

class _VIEWState extends State<VIEW> {
  @override
  Widget build(BuildContext context) {
    double imageWidth = (MediaQuery.of(context).size.width - 15) / 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        //   child: Column(
        //     children: [
        //       IconButton(
        //         icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //         onPressed: () {},
        //       ),
        //     ],
        //   ),
        // ),
        Column(
          children: [
            Stack(children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: imageWidth * 1.1,
                    height: imageWidth * 1.1 ,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.lightGreenAccent, Colors.indigoAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 130,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: imageWidth,
                      height: imageWidth,
                      child: FadeInImage(
                        placeholder: MemoryImage(kTransparentImage),
                        image: ThumbnailProvider(
                          mediumId: widget.current.id,
                          mediumType: widget.current.mediumType,
                          highQuality: true,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 10),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Text(
                  'Processing photo',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                ))
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                Center(child: Consumer<FaceDetectionProvider>(
                  builder: (context, FaceDetectionProvider, child) {
                    return Text('Count: ${FaceDetectionProvider.processedCount}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white));
                  },
                )),


                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
