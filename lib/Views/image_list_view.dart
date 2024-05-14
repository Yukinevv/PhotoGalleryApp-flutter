import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photogalleryapp/Extensions/string_extension.dart';
import 'dart:convert';
import '../Models/MyImage.dart';
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
  MyImage? selectedImage;
  String filterField = "";

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    if (widget.userLogin.isEmpty || widget.category.isEmpty) {
      return;
    }

    String apiUrl = "http://10.0.2.2:8080/api";
    String category = widget.category.replacePolishCharacters();

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

  List<MyImage> getFilteredImages() {
    if (filterField.isEmpty) {
      return images;
    } else {
      return images
          .where((image) =>
              image.filename.toLowerCase().contains(filterField.toLowerCase()))
          .toList();
    }
  }

  void sortByName(bool ascending) {
    setState(() {
      images.sort((a, b) {
        if (ascending) {
          return a.filename.toLowerCase().compareTo(b.filename.toLowerCase());
        } else {
          return b.filename.toLowerCase().compareTo(a.filename.toLowerCase());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          FiltersView(
            userLogin: widget.userLogin,
            category: widget.category,
            filteredImagesCount: getFilteredImages().length,
            filterField: ValueNotifier<String>(filterField),
            sortByName: sortByName,
            loadImages: loadImages,
          ),
          Expanded(
            child: images.isEmpty
                ? const Center(
                    child: Text("Nie wstawiono jeszcze żadnego obrazu..."))
                : ListView.builder(
                    itemCount: getFilteredImages().length,
                    itemBuilder: (context, index) {
                      var image = getFilteredImages()[index];
                      return ListTile(
                        title: Text(image.filename),
                        // ignore: unnecessary_null_comparison
                        subtitle: image.data != null
                            ? Image.memory(base64Decode(image.data))
                            : null,
                        onTap: () {
                          setState(() {
                            selectedImage = image;
                          });
                          showDialog(
                            context: context,
                            builder: (context) => SelectedImagePopupView(
                              selectedImage: image,
                              loadImages: loadImages,
                              onClose: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
