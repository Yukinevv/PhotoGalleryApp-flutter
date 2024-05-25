import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photogalleryapp/Extensions/string_extension.dart';

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
  bool isLoading = false;
  late final String category; // Dodane

  @override
  void initState() {
    super.initState();
    category = widget.category.replacePolishCharacters(); // Dodane
    _initializeImages();
  }

  Future<void> _initializeImages() async {
    setState(() {
      isLoading = true;
    });
    List<MyImage> cachedImages =
        await apiService.getCachedImages(category); // Zmienione
    if (cachedImages.isEmpty) {
      await loadImages();
    } else {
      setState(() {
        images = cachedImages;
        isLoading = false;
      });
      await loadImageIds();
    }
  }

  Future<void> loadImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<MyImage> fetchedImages =
          await apiService.getImages(widget.userLogin, category); // Zmienione
      setState(() {
        images = fetchedImages;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadImageIds() async {
    try {
      List<String> imageIds = await apiService.getImagesIds(
          widget.userLogin, category); // Zmienione
      List<String> cachedImageIds = images.map((image) => image.id).toList();
      List<String> missingImageIds =
          imageIds.where((id) => !cachedImageIds.contains(id)).toList();

      if (missingImageIds.isNotEmpty) {
        await loadMissingImages(missingImageIds);
      }
    } catch (e) {
      print('Failed to load image IDs: $e');
    }
  }

  Future<void> loadMissingImages(List<String> missingImageIds) async {
    try {
      List<MyImage> missingImages = await apiService.getImagesByIds(
          widget.userLogin, category, missingImageIds); // Zmienione
      setState(() {
        images.addAll(missingImages);
      });
    } catch (e) {
      print('Failed to load missing images: $e');
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : images.isEmpty
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
                                subtitle:
                                    Image.memory(base64Decode(image.data)),
                                onTap: () {
                                  setState(() {
                                    selectedImage = image;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        SelectedImagePopupView(
                                      selectedImage: image,
                                      loadImages: loadImages,
                                      onClose: () {
                                        setState(() {
                                          selectedImage = null;
                                        });
                                      },
                                      onUpdate: updateImage,
                                      category: category, // Dodane
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
                _initializeImages();
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
