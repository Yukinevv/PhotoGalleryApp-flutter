import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/MyImage.dart';
import '../constants.dart';

class ApiService {
  final int cacheLimit = 50;

  Future<void> _saveImageToCache(MyImage image, String category) async {
    await image.saveToFile(category);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'image_filename_${category}_${image.id}', image.filename);
    await prefs.setString('image_data_${category}_${image.id}', image.data);
  }

  Future<void> _deleteImageFromCache(String imageId, String category) async {
    final image = await MyImage.loadFromFile(imageId, category);
    if (image != null) {
      await image.deleteFile(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('image_filename_${category}_${imageId}');
      await prefs.remove('image_data_${category}_${imageId}');
    }
  }

  Future<void> _addImageToCacheList(MyImage image, String category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages =
        prefs.getStringList('cachedImages_$category') ?? [];

    if (cachedImages.length >= cacheLimit) {
      final imageIdToRemove = cachedImages.removeAt(0);
      await _deleteImageFromCache(imageIdToRemove, category);
    }

    cachedImages.add(image.id);
    await prefs.setStringList('cachedImages_$category', cachedImages);
    await _saveImageToCache(image, category);
  }

  Future<List<MyImage>> getCachedImages(String category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages =
        prefs.getStringList('cachedImages_$category') ?? [];
    List<MyImage> images = [];

    for (String imageId in cachedImages) {
      final filename = prefs.getString('image_filename_${category}_${imageId}');
      final data = prefs.getString('image_data_${category}_${imageId}');
      if (filename != null && data != null) {
        images.add(MyImage(id: imageId, filename: filename, data: data));
      }
    }

    return images;
  }

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
          await _addImageToCacheList(image, category);
        }

        return images;
      } else {
        throw Exception('Failed to load images by IDs');
      }
    } catch (e) {
      throw Exception('Failed to load images by IDs: $e');
    }
  }

  Future<MyImage?> getCachedImage(String imageId, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final filename = prefs.getString('image_filename_${category}_${imageId}');
    final data = prefs.getString('image_data_${category}_${imageId}');
    if (filename != null && data != null) {
      return MyImage(id: imageId, filename: filename, data: data);
    }
    return null;
  }

  Future<void> deleteImage(String imageId, String category) async {
    final url = Uri.parse('$apiUrl/images/delete/$imageId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        await _deleteImageFromCache(imageId, category);
        final prefs = await SharedPreferences.getInstance();
        List<String> cachedImages =
            prefs.getStringList('cachedImages_$category') ?? [];
        cachedImages.remove(imageId);
        await prefs.setStringList('cachedImages_$category', cachedImages);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<List<MyImage>> getImages(String userLogin, String category) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/images/$userLogin/$category'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MyImage> images =
            data.map((item) => MyImage.fromJson(item)).toList();

        for (MyImage image in images) {
          await _addImageToCacheList(image, category);
        }

        return images;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      return await getCachedImages(category);
    }
  }

  Future<void> changeFilename(
      String imageId, String newFilename, String category) async {
    final url = Uri.parse('$apiUrl/images/editFilename/$imageId/$newFilename');

    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final imageData = prefs.getString('image_data_${category}_${imageId}');
        if (imageData != null) {
          MyImage image =
              MyImage(id: imageId, filename: newFilename, data: imageData);
          await _saveImageToCache(image, category);
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<String> calculateSha512(File file) async {
    final bytes = await file.readAsBytes();
    return sha512.convert(bytes).toString();
  }

  Future<void> uploadImage(File file, String userLogin, String category,
      Function(MyImage) addImage) async {
    final url = Uri.parse('$apiUrl/images/upload/$userLogin/$category');

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        final serverHash = responseData['hash'];
        final imageId = responseData['id'];
        final localHash = await calculateSha512(file);

        if (serverHash == localHash) {
          final image = MyImage(
            id: imageId,
            filename: file.path.split('/').last,
            data: base64Encode(await file.readAsBytes()),
          );

          await _addImageToCacheList(image, category);
          addImage(image); // Dodane
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

  // rejestracja
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

  Future<void> login(User user) async {
    final url = Uri.parse('$apiUrl/users/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(user.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Handle login success
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<MyImage?> getImage(
      String userLogin, String category, String imageId) async {
    MyImage? cachedImage = await getCachedImage(imageId, category);
    if (cachedImage != null) {
      return cachedImage;
    }

    try {
      final response = await http
          .get(Uri.parse('$apiUrl/images/$userLogin/$category/$imageId'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        MyImage image = MyImage.fromJson(data);

        // Save image to cache
        await _addImageToCacheList(image, category);

        return image;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      // On failure, return null
      return null;
    }
  }
}

class User {
  final String login;
  final String password;
  final String email;

  User({required this.login, required this.password, required this.email});

  Map<String, dynamic> toJson() => {
        'login': login,
        'password': password,
        'email': email,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        login: json['login'],
        password: json['password'],
        email: json['email'],
      );
}

class ImageResponse {
  final String id;
  final String filename;
  final String data;

  ImageResponse({required this.id, required this.filename, required this.data});

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'data': data,
      };

  factory ImageResponse.fromJson(Map<String, dynamic> json) => ImageResponse(
        id: json['id'],
        filename: json['filename'],
        data: json['data'],
      );
}
