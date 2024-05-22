import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/MyImage.dart';
import '../Services/ApiService.dart';

class SelectedImagePopupView extends StatefulWidget {
  final MyImage selectedImage;
  final VoidCallback loadImages;
  final VoidCallback onClose;
  final Function(MyImage) onUpdate; // Dodane

  const SelectedImagePopupView({
    Key? key,
    required this.selectedImage,
    required this.loadImages,
    required this.onClose,
    required this.onUpdate, // Dodane
  }) : super(key: key);

  @override
  _SelectedImagePopupViewState createState() => _SelectedImagePopupViewState();
}

class _SelectedImagePopupViewState extends State<SelectedImagePopupView> {
  final TextEditingController _filenameController = TextEditingController();
  String errorMessage = "";
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  void _changeFilename(BuildContext context) async {
    try {
      await apiService.changeFilename(
          widget.selectedImage.id, _filenameController.text);
      setState(() {
        widget.selectedImage.filename = _filenameController.text;
      });
      widget.onUpdate(widget.selectedImage); // Dodane
      widget.loadImages();
      Navigator.of(context).pop();
    } catch (error) {
      // setState(() {
      //   errorMessage = "Błąd zmiany nazwy pliku: $error";
      // });
    }
  }

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

  void _deleteImage(BuildContext context) async {
    try {
      await apiService.deleteImage(widget.selectedImage.id);
      widget.loadImages();
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
      // setState(() {
      //   errorMessage = "Błąd usuwania obrazu: $error";
      // });
    }
  }
}
