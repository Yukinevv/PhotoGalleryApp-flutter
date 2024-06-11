import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/MyImage.dart';
import '../Services/ApiService.dart';

/// Widok popup do zarządzania wybranym obrazem.
/// Umożliwia zmianę nazwy i usunięcie obrazu.
class SelectedImagePopupView extends StatefulWidget {
  /// Wybrany obraz.
  final MyImage selectedImage;

  /// Funkcja wywoływana po zamknięciu popupu.
  final VoidCallback onClose;

  /// Funkcja wywoływana po aktualizacji obrazu.
  final Function(MyImage, String) onUpdate;

  /// Funkcja wywoływana po usunięciu obrazu.
  final Function(String) onDelete;

  /// Kategoria obrazu.
  final String category;

  /// Login użytkownika.
  final String userLogin;

  /// Konstruktor przyjmujący wymagane parametry.
  const SelectedImagePopupView({
    Key? key,
    required this.selectedImage,
    required this.onClose,
    required this.onUpdate,
    required this.onDelete,
    required this.category,
    required this.userLogin,
  }) : super(key: key);

  @override
  _SelectedImagePopupViewState createState() => _SelectedImagePopupViewState();
}

/// Stan widoku popup do zarządzania wybranym obrazem.
class _SelectedImagePopupViewState extends State<SelectedImagePopupView> {
  /// Kontroler tekstu dla pola nowej nazwy pliku.
  final TextEditingController _filenameController = TextEditingController();

  /// Wiadomość o błędzie, wyświetlana gdy wystąpi problem z nazwą pliku.
  String errorMessage = "";

  /// Instancja serwisu API do komunikacji z serwerem.
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _filenameController.text = widget.selectedImage.filename;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Podaj nazwę zdjęcia:"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _filenameController,
                    decoration: InputDecoration(
                      hintText: "Nowa nazwa pliku",
                      errorText: errorMessage.isEmpty ? null : errorMessage,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.memory(base64Decode(widget.selectedImage.data)),
                  Text(widget.selectedImage.filename),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Zmień nazwę"),
                onPressed: () => _confirmChangeFilename(context),
              ),
              TextButton(
                child: const Text("Usuń zdjęcie"),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Wyświetla dialog potwierdzający zmianę nazwy pliku.
  void _confirmChangeFilename(BuildContext context) {
    if (_filenameController.text.isEmpty) {
      setState(() {
        errorMessage = "Nie podano nowej nazwy!";
      });
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Zmiana nazwy"),
          content: const Text("Czy na pewno chcesz zmienić nazwę tego obrazu?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Tak"),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij okno potwierdzenia
                _changeFilename(context);
              },
            ),
            TextButton(
              child: const Text("Nie"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Zmienia nazwę pliku na serwerze i aktualizuje stan aplikacji.
  void _changeFilename(BuildContext context) async {
    try {
      final newImageId = await apiService.changeFilename(
        widget.selectedImage.id,
        _filenameController.text,
        widget.userLogin,
        widget.category,
      );
      final newImage = MyImage(
        id: newImageId, // Nowe ID zdjęcia
        filename: _filenameController.text,
        data: widget.selectedImage.data,
      );
      widget.onUpdate(
          newImage, widget.selectedImage.id); // Przekazanie nowego i starego ID
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        errorMessage = "Wystąpił błąd podczas zmiany nazwy!";
      });
    }
  }

  /// Wyświetla dialog potwierdzający usunięcie pliku.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Usunięcie obrazu"),
          content: const Text("Czy na pewno chcesz usunąć ten obraz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Tak"),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij okno potwierdzenia
                _deleteImage(context);
              },
            ),
            TextButton(
              child: const Text("Nie"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Usuwa plik z serwera i aktualizuje stan aplikacji.
  void _deleteImage(BuildContext context) async {
    try {
      await apiService.deleteImage(
          widget.selectedImage.id, widget.userLogin, widget.category);
      widget.onDelete(widget.selectedImage.id);
      widget.onClose();
      Navigator.of(context).pop(); // Zamknij SelectedImagePopupView

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Sukces"),
            content: const Text("Zdjęcie zostało usunięte pomyślnie!"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknij okno sukcesu
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      setState(() {
        errorMessage = "Wystąpił błąd podczas usuwania!";
      });
    }
  }
}
