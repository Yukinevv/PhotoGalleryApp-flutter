import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyImage {
  final String id;
  String filename;
  final String data; // base64 encoded image data

  MyImage({required this.id, required this.filename, required this.data});

  factory MyImage.fromJson(Map<String, dynamic> json) {
    return MyImage(
      id: json['id'],
      filename: json['filename'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'data': data,
    };
  }

  get image => this;

  String get imageUrl => data;

  Future<void> saveToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$id.jpg');
    await file.writeAsBytes(base64Decode(data));
  }

  static Future<MyImage?> loadFromFile(String id) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$id.jpg');

      if (file.existsSync()) {
        final bytes = await file.readAsBytes();
        final data = base64Encode(bytes);
        // Assuming you have stored other metadata (filename) elsewhere
        final prefs = await SharedPreferences.getInstance();
        final filename = prefs.getString('image_filename_$id') ?? 'unknown';
        return MyImage(id: id, filename: filename, data: data);
      }
    } catch (e) {
      print("Failed to load image from file: $e");
    }
    return null;
  }

  Future<void> deleteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$id.jpg');
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
