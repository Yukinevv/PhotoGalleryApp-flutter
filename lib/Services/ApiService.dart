import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/MyImage.dart';
import '../constants.dart';

class ApiService {
  final int cacheLimit = 50;

  Future<void> _saveImageToCache(MyImage image) async {
    await image.saveToFile();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('image_filename_${image.id}', image.filename);
    await prefs.setString('image_data_${image.id}', image.data);
  }

  Future<void> _deleteImageFromCache(String imageId) async {
    final image = await MyImage.loadFromFile(imageId);
    if (image != null) {
      await image.deleteFile();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('image_filename_$imageId');
      await prefs.remove('image_data_$imageId');
    }
  }

  Future<void> _addImageToCacheList(MyImage image) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages = prefs.getStringList('cachedImages') ?? [];

    if (cachedImages.length >= cacheLimit) {
      final imageIdToRemove = cachedImages.removeAt(0);
      await _deleteImageFromCache(imageIdToRemove);
    }

    cachedImages.add(image.id);
    await prefs.setStringList('cachedImages', cachedImages);
    await _saveImageToCache(image);
  }

  Future<List<MyImage>> _getCachedImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages = prefs.getStringList('cachedImages') ?? [];
    List<MyImage> images = [];

    for (String imageId in cachedImages) {
      final filename = prefs.getString('image_filename_$imageId');
      final data = prefs.getString('image_data_$imageId');
      if (filename != null && data != null) {
        images.add(MyImage(id: imageId, filename: filename, data: data));
      }
    }

    return images;
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cachedImages = prefs.getStringList('cachedImages') ?? [];

    for (String imageId in cachedImages) {
      await _deleteImageFromCache(imageId);
    }

    await prefs.remove('cachedImages');
  }

  Future<List<MyImage>> getImages(String userLogin, String category) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/images/$userLogin/$category'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MyImage> images =
            data.map((item) => MyImage.fromJson(item)).toList();

        // Save images to cache
        for (MyImage image in images) {
          await _addImageToCacheList(image);
        }

        return images;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      // On failure, return cached images
      return await _getCachedImages();
    }
  }

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

  Future<void> deleteImage(String imageId) async {
    final url = Uri.parse('$apiUrl/images/delete/$imageId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        await _deleteImageFromCache(imageId);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<void> changeFilename(String imageId, String newFilename) async {
    final url = Uri.parse('$apiUrl/images/editFilename/$imageId/$newFilename');

    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final imageData = prefs.getString('image_data_$imageId');
        if (imageData != null) {
          MyImage image =
              MyImage(id: imageId, filename: newFilename, data: imageData);
          await _saveImageToCache(image);
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
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
