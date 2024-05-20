// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:photogalleryapp/constants.dart';
import '../Models/MyImage.dart';

class SelectedImagePopupView extends StatefulWidget {
  final MyImage selectedImage;
  final VoidCallback loadImages;
  final VoidCallback onClose;

  const SelectedImagePopupView({
    Key? key,
    required this.selectedImage,
    required this.loadImages,
    required this.onClose,
  }) : super(key: key);

  @override
  _SelectedImagePopupViewState createState() => _SelectedImagePopupViewState();
}

class _SelectedImagePopupViewState extends State<SelectedImagePopupView> {
  final TextEditingController _filenameController = TextEditingController();
  String errorMessage = "";

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
                      hintText: "New Filename",
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
                Navigator.of(context).pop(); // Close the confirmation dialog
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
    String url =
        "$apiUrl/images/editFilename/${widget.selectedImage.id}/${_filenameController.text}";

    try {
      final response = await http.put(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          widget.selectedImage.filename = _filenameController.text;
          widget.loadImages();
        });
        Navigator.of(context).pop();
      } else {
        setState(() {
          errorMessage =
              "Error changing image filename: ${response.reasonPhrase}";
        });
      }
    } catch (error) {
      if (!mounted) return;
      // setState(() {
      //   errorMessage = "Network error: $error";
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
                Navigator.of(context).pop(); // Close the confirmation dialog
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
    String url = "$apiUrl/images/delete/${widget.selectedImage.id}";

    try {
      final response = await http.delete(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        widget.loadImages();
        widget.onClose();
        Navigator.of(context).pop(); // Close the popup
      } else {
        setState(() {
          errorMessage = "Error deleting image: ${response.reasonPhrase}";
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Network error: $error";
      });
    }
  }
}
