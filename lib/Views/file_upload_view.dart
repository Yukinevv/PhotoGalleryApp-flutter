import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:photogalleryapp/Extensions/string_extension.dart';

class FileUploadView extends StatefulWidget {
  final String userLogin;
  final String category;
  final VoidCallback closeSheet;
  final VoidCallback loadImages;

  const FileUploadView({
    Key? key,
    required this.userLogin,
    required this.category,
    required this.closeSheet,
    required this.loadImages,
  }) : super(key: key);

  @override
  _FileUploadViewState createState() => _FileUploadViewState();
}

class _FileUploadViewState extends State<FileUploadView> {
  File? selectedFile;
  String errorMessage = "Brak wybranego pliku.";
  bool isButtonDisabled = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: isButtonDisabled ? null : uploadImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonDisabled ? Colors.grey : Colors.blue,
            ),
            child: const Text("Dodaj obraz"),
          ),
          const SizedBox(height: 20),
          Text(errorMessage),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectFile,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.file_upload),
                SizedBox(width: 8),
                Text("Wybierz plik"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      if (isFileTypeAllowed(file)) {
        setState(() {
          selectedFile = file;
          errorMessage = "Wybrany plik: ${basename(file.path)}";
          isButtonDisabled = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Nieprawidłowy format pliku. Proszę wybrać plik .jpg lub .png";
          isButtonDisabled = true;
        });
      }
    }
  }

  bool isFileTypeAllowed(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType == 'image/jpeg' || mimeType == 'image/png';
  }

  Future<void> uploadImage() async {
    if (widget.userLogin.isEmpty ||
        widget.category.isEmpty ||
        selectedFile == null) {
      return;
    }

    String category = widget.category.replacePolishCharacters();
    String apiUrl =
        "http://10.0.2.2:8080/api/images/upload/${widget.userLogin}/$category";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Content-Type'] = 'multipart/form-data'
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            selectedFile!.path,
            contentType: MediaType.parse(lookupMimeType(selectedFile!.path)!),
          ),
        );

      var response = await request.send();

      if (response.statusCode == 200) {
        widget.loadImages();
        widget.closeSheet();
      } else {
        setState(() {
          errorMessage = "Failed to upload image: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Image upload failed: $e";
      });
    }
  }
}
