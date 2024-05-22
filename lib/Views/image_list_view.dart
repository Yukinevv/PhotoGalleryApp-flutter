import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/MyImage.dart';
import '../Services/ApiService.dart';
import 'file_upload_view.dart';
import 'filters_view.dart';
import 'selected_image_popup_view.dart';

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
  ValueNotifier<String> filterField = ValueNotifier<String>("");

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    try {
      List<MyImage> fetchedImages =
          await apiService.getImages(widget.userLogin, widget.category);
      setState(() {
        images = fetchedImages;
      });
    } catch (e) {
      print('Failed to load images: $e');
    }
  }

  void updateImage(MyImage updatedImage) {
    setState(() {
      final index = images.indexWhere((image) => image.id == updatedImage.id);
      if (index != -1) {
        images[index] = updatedImage;
      }
    });
  }

  List<MyImage> getFilteredImages() {
    if (filterField.value.isEmpty) {
      return images;
    } else {
      return images
          .where((image) => image.filename
              .toLowerCase()
              .contains(filterField.value.toLowerCase()))
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
        title: Text(widget.category),
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
            filterField: filterField,
            sortByName: sortByName,
            loadImages: loadImages,
          ),
          Expanded(
            child: images.isEmpty
                ? const Center(
                    child: Text("Nie wstawiono jeszcze żadnego obrazu..."))
                : ValueListenableBuilder<String>(
                    valueListenable: filterField,
                    builder: (context, value, child) {
                      var filteredImages = getFilteredImages();
                      return ListView.builder(
                        itemCount: filteredImages.length,
                        itemBuilder: (context, index) {
                          var image = filteredImages[index];
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
                                  onUpdate: updateImage, // Dodane
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => FileUploadView(
              userLogin: widget.userLogin,
              category: widget.category,
              closeSheet: () {
                Navigator.pop(context);
                loadImages();
              },
              loadImages: loadImages,
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
