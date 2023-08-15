import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:io';

import 'package:photo_gallery/photo_gallery.dart';

import '../Model/similarphotoProvider.dart';
import '../view/SimilarView.dart';

class SimilarImageScreen extends StatefulWidget {
  final List<Medium> pictureList;
  final Medium currentImage;

  const SimilarImageScreen({
    Key? key,
    required this.pictureList,
    required this.currentImage,
  }) : super(key: key);

  @override
  _SimilarImageScreenState createState() => _SimilarImageScreenState();
}

class _SimilarImageScreenState extends State<SimilarImageScreen> {
  List<Medium> similarImages = [];

  @override
  void initState() {
    super.initState();
    _findSimilarPhotos();
  }

  @override
  void dispose() {
    final provider = Provider.of<FaceDetectionProvider>(context, listen: false);
    if (provider.isProcessing) {
      provider
          .cancelSearchTask();
    }
    super.dispose();
  }

  Future<void> _findSimilarPhotos() async {
    final provider = Provider.of<FaceDetectionProvider>(context, listen: false);

    await provider.processImages(widget.pictureList.take(2200).toList());

    File? currentImageFile = await widget.currentImage.getFile();
    if (currentImageFile == null) {
      if (kDebugMode) {
        print("Failed to load current image.");
      }
      return;
    }
    List<Medium> foundSimilarImages = [];
    List<List<double>>? currentEmbedding = await provider
        .generateEmbeddingForImage(currentImageFile, saveToMap: false);

    if (currentEmbedding == null) {
      if (kDebugMode) {
        print("No face detected in the current image.");
      }
      foundSimilarImages = [];
      return;
    }

    for (var medium in widget.pictureList.take(2200).toList()) {
      if (medium.id == widget.currentImage.id) {
        continue;
      }

      var embeddingValue = provider.faceEmbeddingsMap[int.parse(medium.id)];
      List<List<double>>? targetEmbedding;

      if (embeddingValue != null &&
          embeddingValue != "null" &&
          embeddingValue is List &&
          embeddingValue.every((e) => e is List && e.every((v) => v is double))) {

        targetEmbedding = embeddingValue.map((e) => List<double>.from(e)).toList();

        if (kDebugMode) {
          print("Embedding length: ${targetEmbedding.length}");
        }

        double similarityScore = _calculateCosineSimilarity(currentEmbedding, targetEmbedding);

        if (kDebugMode) {
          print("Similarity Score: $similarityScore");
        }

        if (similarityScore > 0.65) {
          foundSimilarImages.add(medium);
        }
      }
      else {
        if (kDebugMode) {
          print("No valid embedding found for similarity check.");
        }
      }

    }

    setState(() {
      similarImages = foundSimilarImages;
    });
  }

  double _calculateCosineSimilarity(
      List<List<double>>? embedding1, List<List<double>>? embedding2) {
    if (embedding1 == null) {
      throw Exception('Embeddings 1 cannot be null');
    } else if (embedding2 == null) {
      throw Exception('Embeddings 2 cannot be null');
    }

    if (embedding1.length == 1) {
      if (kDebugMode) {
        print("running this ");
      }
      return _compareSingleEmbeddingToMultiple(embedding1[0], embedding2);
    } else {
      double highestSimilarity = -1.0;
      for (var emb1 in embedding1) {
        double similarity = _compareSingleEmbeddingToMultiple(emb1, embedding2);
        if (kDebugMode) {
          print("running this multiple ");
        }

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
        }
      }
      return highestSimilarity;
    }
  }

  double _compareSingleEmbeddingToMultiple(
      List<double> embedding1, List<List<double>> embedding2) {
    double highestSimilarity = -1.0;

    for (var emb2 in embedding2) {
      double similarity = _cosineSimilarity(embedding1, emb2);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
      }
    }
    return highestSimilarity;
  }

  double _cosineSimilarity(List<double> embedding1, List<double> embedding2) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    // Calculate dot product and norms
    for (int i = 0; i < embedding1.length; i++) {
      double value1 = embedding1[i];
      double value2 = embedding2[i];
      dotProduct += value1 * value2;
      normA += value1 * value1;
      normB += value2 * value2;
    }

    // To avoid division by zero, check if norms are non-zero
    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FaceDetectionProvider>(context);

    return Scaffold(
        backgroundColor: Colors.black45,
        body: provider.isProcessing
            ? VIEW(current: widget.currentImage)
            : similarImages.isEmpty
                ? Center(child: CircularProgressIndicator(color: Colors.lightGreenAccent,))
                : SimilarImageView(
                    images: similarImages, current: widget.currentImage));
  }
}
