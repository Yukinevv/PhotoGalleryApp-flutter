import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'dart:io';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodaj obraz"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.closeSheet,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isButtonDisabled ? null : uploadImage,
              child: Text("Dodaj obraz"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    isButtonDisabled ? Colors.grey : Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            Text(errorMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectFile,
              child: const Text("Wybierz plik"),
            ),
          ],
        ),
      ),
    );
  }

  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      selectedFile = File(result.files.single.path!);
      final mimeTypeData =
          lookupMimeType(selectedFile!.path, headerBytes: [0xFF, 0xD8])
              ?.split('/');
      if (mimeTypeData != null && ['jpeg', 'png'].contains(mimeTypeData[1])) {
        setState(() {
          errorMessage = "Wybrany plik: ${selectedFile!.path.split('/').last}";
          isButtonDisabled = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Nieprawidłowy format pliku. Proszę wybrać plik .jpg lub .png";
          isButtonDisabled = true;
        });
      }
    } else {
      setState(() {
        errorMessage = "Nie wybrano pliku.";
        isButtonDisabled = true;
      });
    }
  }

  void uploadImage() async {
    if (selectedFile == null) {
      setState(() {
        errorMessage = "Brak wybranego pliku.";
      });
      return;
    }

    String apiUrl = "https://photo-gallery-api-59f6baae823c.herokuapp.com/api";
    String category = widget.category
        .replacePolishCharacters(); // Assuming replacePolishCharacters() is implemented

    var request = http.MultipartRequest('POST',
        Uri.parse('$apiUrl/images/upload/${widget.userLogin}/$category'));
    request.files
        .add(await http.MultipartFile.fromPath('image', selectedFile!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      widget.loadImages();
      widget.closeSheet();
    } else {
      setState(() {
        errorMessage = "Wystąpił błąd podczas wysyłania obrazu.";
      });
    }
  }
}
