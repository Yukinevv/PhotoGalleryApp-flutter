import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photogalleryapp/Extensions/string_extension.dart';
import 'dart:convert';
import '../Models/MyImage.dart';
// ignore: unused_import
import 'filters_view.dart'; // Zakładając, że FiltersView jest już zaimplementowany
import 'selected_image_popup_view.dart'; // Zakładając, że SelectedImagePopupView jest już zaimplementowany

class ImageListView extends StatefulWidget {
  final String userLogin;
  final String category;

  const ImageListView(
      {Key? key, required this.userLogin, required this.category})
      : super(key: key);

  @override
  _ImageListViewState createState() => _ImageListViewState();
}

class _ImageListViewState extends State<ImageListView> {
  List<MyImage> images = [];
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    if (widget.userLogin.isEmpty || widget.category.isEmpty) {
      return;
    }

    String apiUrl = "https://photo-gallery-api-59f6baae823c.herokuapp.com/api";
    String category = widget.category
        .replacePolishCharacters(); // Zakładając implementację tej metody

    try {
      var response = await http
          .get(Uri.parse("$apiUrl/images/${widget.userLogin}/$category"));
      if (response.statusCode == 200) {
        List<dynamic> imageList = jsonDecode(response.body);
        setState(() {
          images = imageList.map((item) => MyImage.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Failed to load images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: images.isEmpty
          ? const Center(child: Text("Nie wstawiono jeszcze żadnego obrazu..."))
          : ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                var image = images[index];
                return ListTile(
                  title: Text(image.filename),
                  onTap: () {
                    setState(() {
                      selectedImage = image.id;
                    });
                    showDialog(
                      context: context,
                      builder: (context) => SelectedImagePopupView(
                        reloadImages: loadImages,
                        selectedImage: image,
                        loadImages: () {},
                        onClose: () {},
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
