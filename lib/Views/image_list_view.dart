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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<MyImage> fetchedImages =
          await apiService.getImages(widget.userLogin, widget.category);
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

  Future<MyImage?> loadSingleImage(String imageId) async {
    try {
      MyImage? image =
          await apiService.getImage(widget.userLogin, widget.category, imageId);
      return image;
    } catch (e) {
      print('Failed to load image: $e');
      return null;
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
                          return FutureBuilder<MyImage?>(
                            future: apiService.getCachedImage(image.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListTile(
                                  title: Text(image.filename),
                                  subtitle: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else if (snapshot.hasError) {
                                return ListTile(
                                  title: Text(image.filename),
                                  subtitle: Text('Error loading image'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                return ListTile(
                                  title: Text(snapshot.data!.filename),
                                  subtitle: Image.memory(
                                      base64Decode(snapshot.data!.data)),
                                  onTap: () {
                                    setState(() {
                                      selectedImage = snapshot.data;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          SelectedImagePopupView(
                                        selectedImage: snapshot.data!,
                                        loadImages: loadImages,
                                        onClose: () {
                                          setState(() {
                                            selectedImage = null;
                                          });
                                        },
                                        onUpdate: updateImage,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return FutureBuilder<MyImage?>(
                                  future: loadSingleImage(image.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text(image.filename),
                                        subtitle: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    } else if (snapshot.hasError) {
                                      return ListTile(
                                        title: Text(image.filename),
                                        subtitle: Text('Error loading image'),
                                      );
                                    } else if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return ListTile(
                                        title: Text(snapshot.data!.filename),
                                        subtitle: Image.memory(
                                            base64Decode(snapshot.data!.data)),
                                        onTap: () {
                                          setState(() {
                                            selectedImage = snapshot.data;
                                          });
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                SelectedImagePopupView(
                                              selectedImage: snapshot.data!,
                                              loadImages: loadImages,
                                              onClose: () {
                                                setState(() {
                                                  selectedImage = null;
                                                });
                                              },
                                              onUpdate: updateImage,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return ListTile(
                                        title: Text(image.filename),
                                        subtitle: Text('Image not found'),
                                      );
                                    }
                                  },
                                );
                              }
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
