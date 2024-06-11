import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:photogalleryapp/Models/MyImage.dart';

import '../Services/ApiService.dart';

/// Widok umożliwiający użytkownikowi przesyłanie plików (obrazów).
class FileUploadView extends StatefulWidget {
  /// Login użytkownika.
  final String userLogin;

  /// Kategoria, do której obraz zostanie przypisany.
  final String category;

  /// Funkcja zamykająca dolny arkusz.
  final VoidCallback closeSheet;

  /// Funkcja dodająca obraz do galerii.
  final Function(MyImage) addImage;

  /// Konstruktor przyjmujący wymagane parametry.
  const FileUploadView({
    Key? key,
    required this.userLogin,
    required this.category,
    required this.closeSheet,
    required this.addImage,
  }) : super(key: key);

  @override
  _FileUploadViewState createState() => _FileUploadViewState();
}

/// Stan widoku przesyłania plików.
class _FileUploadViewState extends State<FileUploadView> {
  /// Wybrany plik.
  File? selectedFile;

  /// Wiadomość o błędzie wyświetlana, gdy nie wybrano pliku.
  String errorMessage = "Brak wybranego pliku.";

  /// Flaga wskazująca, czy przycisk przesyłania pliku jest wyłączony.
  bool isButtonDisabled = true;

  /// Picker używany do wyboru obrazów.
  final ImagePicker _picker = ImagePicker();

  /// Instancja serwisu API do przesyłania obrazów.
  final ApiService apiService = ApiService();

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
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: captureImage,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text("Zrób zdjęcie"),
              ],
            ),
          ),
          if (selectedFile != null)
            Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: cropImage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.crop),
                      SizedBox(width: 8),
                      Text("Przytnij obraz"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Metoda umożliwiająca wybór pliku z urządzenia.
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

  /// Metoda umożliwiająca zrobienie zdjęcia za pomocą kamery.
  Future<void> captureImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      File file = File(photo.path);

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

  /// Metoda umożliwiająca przycięcie wybranego obrazu.
  Future<void> cropImage() async {
    if (selectedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: selectedFile!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Przytnij obraz',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        selectedFile = File(croppedFile.path);
        errorMessage = "Wybrany plik: ${basename(selectedFile!.path)}";
      });
    }
  }

  /// Metoda sprawdzająca, czy wybrany plik ma prawidłowy typ MIME.
  ///
  /// Parametr:
  /// - `file`: Plik do sprawdzenia.
  ///
  /// Zwraca:
  /// - `bool`: True, jeśli plik jest typu .jpg lub .png, w przeciwnym razie False.
  bool isFileTypeAllowed(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType == 'image/jpeg' || mimeType == 'image/png';
  }

  /// Metoda przesyłająca wybrany obraz na serwer.
  ///
  /// Jeśli użytkownik nie wprowadził loginu lub kategorii, lub nie wybrano pliku, metoda zwraca.
  ///
  /// W przeciwnym razie przesyła obraz na serwer za pomocą `apiService`.
  /// Po pomyślnym przesłaniu obraz zostaje dodany do galerii, a arkusz zamknięty.
  /// W przypadku błędu wyświetlana jest odpowiednia wiadomość o błędzie.
  Future<void> uploadImage() async {
    if (widget.userLogin.isEmpty ||
        widget.category.isEmpty ||
        selectedFile == null) {
      return;
    }

    try {
      await apiService.uploadImage(
          selectedFile!, widget.userLogin, widget.category, widget.addImage);
      widget.closeSheet();
    } catch (e) {
      setState(() {
        errorMessage = "Nie udało się przesłać obrazu: $e";
      });
    }
  }
}
