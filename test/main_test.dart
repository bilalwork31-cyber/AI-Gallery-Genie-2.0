import 'package:cts/Model/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_gallery/photo_gallery.dart';

class MockAlbum extends Mock implements Album {}
class MockMediaPage extends Mock implements MediaPage {}
class MockMedium extends Mock implements Medium {}

void main() {
  group('AppState Tests', () {
    late AppState appState;
    late MockAlbum mockAlbum;
    late MockMediaPage mockMediaPage;
    late MockMedium mockMedium;

    setUp(() {
      appState = AppState();
      mockAlbum = MockAlbum();
      mockMediaPage = MockMediaPage();
      mockMedium = MockMedium();
    });

    test('loadAlbumsAndPictures should set isLoading and load albums', () async {
      // Arrange: Mock the PhotoGallery listAlbums call
      when(() => PhotoGallery.listAlbums(newest: true))
          .thenAnswer((_) async => [mockAlbum]);

      when(() => mockAlbum.listMedia()).thenAnswer((_) async => mockMediaPage);
      when(() => mockMediaPage.items).thenReturn([mockMedium]);

      // Act: Call loadAlbumsAndPictures
      await appState.loadAlbumsAndPictures();

      // Assert
      expect(appState.isLoading, isFalse);
      expect(appState.albums.isNotEmpty, isTrue);
      expect(appState.pictureList.isNotEmpty, isTrue);
    });

    test('loadPicturesFromFirstAlbum should load pictures and filter .heic files', () async {
      // Arrange: Set up a list with mixed media
      final jpegMedium = MockMedium();
      final heicMedium = MockMedium();

      when(() => jpegMedium.filename).thenReturn('image.jpg');
      when(() => heicMedium.filename).thenReturn('image.heic');

      when(() => mockAlbum.listMedia()).thenAnswer((_) async => mockMediaPage);
      when(() => mockMediaPage.items).thenReturn([jpegMedium, heicMedium]);

      appState.albums = [mockAlbum]; // Preload albums list

      // Act: Load pictures from the first album
      await appState.loadPicturesFromFirstAlbum();

      // Assert
      expect(appState.pictureList.length, 1); // Only non-.heic files should be present
      expect(appState.pictureList[0].filename, equals('image.jpg'));
    });

    test('setLoading should update isLoading and call notifyListeners', () {
      // Arrange: Set initial state
      appState.isLoading = false;

      // Act: Set loading to true
      appState.setLoading(true);

      // Assert
      expect(appState.isLoading, isTrue);
    });
  });
}
