import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // final String apiUrl =
  // "https://photo-gallery-api-59f6baae823c.herokuapp.com/api";
  final String apiUrl = "http://10.0.2.2:8080/api";

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
      if (response.statusCode != 200) {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<List<ImageResponse>> getImages(
      String userLogin, String category) async {
    final url = Uri.parse('$apiUrl/images/$userLogin/$category');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('HTTP Error: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ImageResponse.fromJson(item)).toList();
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
