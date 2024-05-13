import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'dart:convert';

import '../Models/MyImage.dart';

class SelectedImagePopupView extends StatefulWidget {
  final MyImage selectedImage;
  final VoidCallback loadImages;
  final VoidCallback onClose;

  const SelectedImagePopupView({
    Key? key,
    required this.selectedImage,
    required this.loadImages,
    required this.onClose, required Future<void> Function() reloadImages,
  }) : super(key: key);

  @override
  _SelectedImagePopupViewState createState() => _SelectedImagePopupViewState();
}

class _SelectedImagePopupViewState extends State<SelectedImagePopupView> {
  TextEditingController _filenameController = TextEditingController();
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _filenameController.text = widget.selectedImage.filename;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Podaj nazwę zdjęcia:"),
      content: Column(
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
          if (widget.selectedImage.image !=
              null) // Assuming image is already an Image widget
            Image(image: widget.selectedImage.image),
          Text(widget.selectedImage.filename),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Zmień nazwę"),
          onPressed: () => _changeFilename(context),
        ),
        TextButton(
          child: const Text("Usuń zdjęcie"),
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  void _changeFilename(BuildContext context) {
    if (_filenameController.text.isEmpty) {
      setState(() {
        errorMessage = "Nie podano nowej nazwy!";
      });
      return;
    }

    String apiUrl = "https://photo-gallery-api-59f6baae823c.herokuapp.com/api";
    String url =
        "$apiUrl/images/editFilename/${widget.selectedImage.id}/${_filenameController.text}";

    http.put(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          widget.selectedImage.filename = _filenameController.text;
          widget.loadImages();
        });
        Navigator.of(context).pop();
      } else {
        setState(() {
          errorMessage = "Error changing image filename";
        });
      }
    }).catchError((error) {
      setState(() {
        errorMessage = "Network error";
      });
    });
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
              onPressed: () => _deleteImage(context),
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

  void _deleteImage(BuildContext context) {
    String apiUrl = "https://photo-gallery-api-59f6baae823c.herokuapp.com/api";
    String url = "$apiUrl/images/delete/${widget.selectedImage.id}";

    http.delete(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        widget.loadImages();
        widget.onClose();
        Navigator.of(context).pop(); // Close the confirmation dialog
        Navigator.of(context).pop(); // Close the popup
      } else {
        setState(() {
          errorMessage = "Error deleting image";
        });
      }
    }).catchError((error) {
      setState(() {
        errorMessage = "Network error";
      });
    });
  }
}

// class MyImage {
//   final String id;
//   final String filename;
//   Image image;

//   MyImage({required this.id, required this.filename, required this.image});
// }
