import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:photogalleryapp/Models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/MyImage.dart';
import '../constants.dart';

/// Klasa `ApiService` zawiera metody do komunikacji z API i zarządzania obrazami oraz użytkownikami.
class ApiService {
  /// Limit obrazów przechowywanych w pamięci podręcznej.
  final int cacheLimit = 50;

  /// Zapisuje obraz w pamięci podręcznej.
  Future<void> _saveImageToCache(
      MyImage image, String userLogin, String category) async {
    await image.saveToFile(userLogin, category);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'image_filename_${userLogin}_${category}_${image.id}', image.filename);
    await prefs.setString(
        'image_data_${userLogin}_${category}_${image.id}', image.data);
  }

  /// Usuwa obraz z pamięci podręcznej.
  Future<void> _deleteImageFromCache(
      String imageId, String userLogin, String category) async {
    final image = await MyImage.loadFromFile(imageId, userLogin, category);
    if (image != null) {
      await image.deleteFile(userLogin, category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('image_filename_${userLogin}_${category}_${imageId}');
      await prefs.remove('image_data_${userLogin}_${category}_${imageId}');
    }
  }

  /// Dodaje obraz do listy obrazów w pamięci podręcznej.
  Future<void> _addImageToCacheList(
      MyImage image, String userLogin, String category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages =
        prefs.getStringList('cachedImages_${userLogin}_${category}') ?? [];

    if (cachedImages.length >= cacheLimit) {
      final imageIdToRemove = cachedImages.removeAt(0);
      await _deleteImageFromCache(imageIdToRemove, userLogin, category);
    }

    cachedImages.add(image.id);
    await prefs.setStringList(
        'cachedImages_${userLogin}_${category}', cachedImages);
    await _saveImageToCache(image, userLogin, category);
  }

  /// Pobiera obrazy z pamięci podręcznej.
  Future<List<MyImage>> getCachedImages(
      String userLogin, String category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages =
        prefs.getStringList('cachedImages_${userLogin}_${category}') ?? [];
    List<MyImage> images = [];

    for (String imageId in cachedImages) {
      final filename =
          prefs.getString('image_filename_${userLogin}_${category}_${imageId}');
      final data =
          prefs.getString('image_data_${userLogin}_${category}_${imageId}');
      if (filename != null && data != null) {
        images.add(MyImage(id: imageId, filename: filename, data: data));
      }
    }

    return images;
  }

  /// Pobiera identyfikatory obrazów z serwera.
  Future<List<String>> getImagesIds(String userLogin, String category) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/images/ids/$userLogin/$category'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Failed to load image IDs');
      }
    } catch (e) {
      throw Exception('Failed to load image IDs: $e');
    }
  }

  /// Pobiera obrazy z serwera na podstawie ich identyfikatorów.
  Future<List<MyImage>> getImagesByIds(
      String userLogin, String category, List<String> ids) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/images/byIds/$userLogin/$category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ids),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MyImage> images =
            data.map((item) => MyImage.fromJson(item)).toList();

        for (MyImage image in images) {
          await _addImageToCacheList(image, userLogin, category);
        }

        return images;
      } else {
        throw Exception('Failed to load images by IDs');
      }
    } catch (e) {
      throw Exception('Failed to load images by IDs: $e');
    }
  }

  /// Pobiera obraz z pamięci podręcznej na podstawie identyfikatora.
  Future<MyImage?> getCachedImage(
      String imageId, String userLogin, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final filename =
        prefs.getString('image_filename_${userLogin}_${category}_${imageId}');
    final data =
        prefs.getString('image_data_${userLogin}_${category}_${imageId}');
    if (filename != null && data != null) {
      return MyImage(id: imageId, filename: filename, data: data);
    }
    return null;
  }

  /// Usuwa obraz z serwera i pamięci podręcznej.
  Future<void> deleteImage(
      String imageId, String userLogin, String category) async {
    final url = Uri.parse('$apiUrl/images/delete/$imageId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final responseData = jsonDecode(responseBody);
        final serverHash = responseData['hash'];
        final image = await getCachedImage(imageId, userLogin, category);
        if (image != null) {
          final localHash = await calculateSha512(image.data);
          if (serverHash == localHash) {
            await _deleteImageFromCache(imageId, userLogin, category);
            final prefs = await SharedPreferences.getInstance();
            List<String> cachedImages =
                prefs.getStringList('cachedImages_${userLogin}_${category}') ??
                    [];
            cachedImages.remove(imageId);
            await prefs.setStringList(
                'cachedImages_${userLogin}_${category}', cachedImages);
          } else {
            throw Exception('Hash mismatch');
          }
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  /// Pobiera obrazy z serwera.
  Future<List<MyImage>> getImages(String userLogin, String category) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/images/$userLogin/$category'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MyImage> images =
            data.map((item) => MyImage.fromJson(item)).toList();

        for (MyImage image in images) {
          await _addImageToCacheList(image, userLogin, category);
        }

        return images;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      return await getCachedImages(userLogin, category);
    }
  }

  /// Zmienia nazwę pliku na serwerze i aktualizuje cache.
  Future<String> changeFilename(String imageId, String newFilename,
      String userLogin, String category) async {
    final url = Uri.parse('$apiUrl/images/editFilename/$imageId/$newFilename');

    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final responseData = jsonDecode(responseBody);
        final serverHash = responseData['hash'];
        final newImageId = responseData['id']; // Nowe ID zdjęcia
        final imageData = await getCachedImage(imageId, userLogin, category);
        if (imageData != null) {
          final localHash = await calculateSha512(imageData.data);
          if (serverHash == localHash) {
            MyImage updatedImage = MyImage(
              id: newImageId, // Zaktualizowane ID
              filename: newFilename,
              data: imageData.data,
            );
            await _deleteImageFromCache(
                imageId, userLogin, category); // Usuń stare ID z cache
            await _addImageToCacheList(
                updatedImage, userLogin, category); // Dodaj nowe ID do cache
            return newImageId; // Zwróć nowe ID
          } else {
            throw Exception('Hash mismatch');
          }
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
    return imageId; // W razie niepowodzenia zwróć stare ID
  }

  /// Oblicza wartość hash (SHA-512) dla danego ciągu znaków.
  Future<String> calculateSha512(String data) async {
    return sha512.convert(base64Decode(data)).toString();
  }

  /// Przesyła obraz na serwer.
  Future<void> uploadImage(File file, String userLogin, String category,
      Function(MyImage) addImage) async {
    final url = Uri.parse('$apiUrl/images/upload/$userLogin/$category');

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    try {
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        final serverHash = responseData['hash'];
        final imageId = responseData['id'];
        final localHash =
            await calculateSha512(base64Encode(await file.readAsBytes()));

        if (serverHash == localHash) {
          final image = MyImage(
            id: imageId,
            filename: file.path.split('/').last,
            data: base64Encode(await file.readAsBytes()),
          );

          await _addImageToCacheList(image, userLogin, category);
          addImage(image);
        } else {
          throw Exception('Hash mismatch');
        }
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  /// Rejestracja nowego użytkownika.
  Future<void> createUser(User user) async {
    final url = Uri.parse('$apiUrl/users/add');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(user.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 201) {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  /// Logowanie użytkownika.
  Future<void> login(User user) async {
    final url = Uri.parse('$apiUrl/users/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(user.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Logowanie się powiodło
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  /// Pobiera obraz z serwera lub z pamięci podręcznej na podstawie identyfikatora.
  Future<MyImage?> getImage(
      String userLogin, String category, String imageId) async {
    MyImage? cachedImage = await getCachedImage(imageId, userLogin, category);
    if (cachedImage != null) {
      return cachedImage;
    }

    try {
      final response = await http
          .get(Uri.parse('$apiUrl/images/$userLogin/$category/$imageId'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        MyImage image = MyImage.fromJson(data);

        // Zapis obrazka do cache
        await _addImageToCacheList(image, userLogin, category);

        return image;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      return null;
    }
  }
}
