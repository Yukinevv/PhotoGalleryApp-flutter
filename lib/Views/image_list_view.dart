import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photogalleryapp/Extensions/string_extension.dart';

import '../Models/MyImage.dart';
import '../Services/ApiService.dart';
import 'file_upload_view.dart';
import 'filters_view.dart';
import 'selected_image_popup_view.dart';

/// Widok listy obrazów dla wybranej kategorii.
class ImageListView extends StatefulWidget {
  /// Login użytkownika.
  final String userLogin;

  /// Kategoria, dla której wyświetlane są obrazy.
  final String category;

  /// Konstruktor przyjmujący wymagane parametry.
  const ImageListView(
      {Key? key, required this.userLogin, required this.category})
      : super(key: key);

  @override
  _ImageListViewState createState() => _ImageListViewState();
}

/// Stan widoku listy obrazów.
class _ImageListViewState extends State<ImageListView> {
  /// Lista obrazów.
  List<MyImage> images = [];

  /// Aktualnie wybrany obraz.
  MyImage? selectedImage;

  /// Notifier dla pola filtrowania.
  ValueNotifier<String> filterField = ValueNotifier<String>("");

  /// Instancja serwisu API do komunikacji z serwerem.
  final ApiService apiService = ApiService();

  /// Flaga wskazująca, czy obrazy są ładowane.
  bool isLoading = false;

  /// Kategoria po przetworzeniu znaków polskich.
  late final String category;

  @override
  void initState() {
    super.initState();
    category = widget.category.replacePolishCharacters();
    _initializeImages();
  }

  /// Metoda inicjalizująca obrazy.
  Future<void> _initializeImages() async {
    setState(() {
      isLoading = true;
    });
    List<MyImage> cachedImages =
        await apiService.getCachedImages(widget.userLogin, category);
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

  /// Metoda ładująca obrazy z serwera.
  Future<void> loadImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<MyImage> fetchedImages =
          await apiService.getImages(widget.userLogin, category);
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

  /// Metoda ładująca identyfikatory obrazów.
  Future<void> loadImageIds() async {
    try {
      List<String> imageIds =
          await apiService.getImagesIds(widget.userLogin, category);
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

  /// Metoda ładująca brakujące obrazy.
  Future<void> loadMissingImages(List<String> missingImageIds) async {
    try {
      List<MyImage> missingImages = await apiService.getImagesByIds(
          widget.userLogin, category, missingImageIds);
      setState(() {
        images.addAll(missingImages);
      });
    } catch (e) {
      print('Failed to load missing images: $e');
    }
  }

  /// Aktualizuje obraz w liście.
  void updateImage(MyImage updatedImage, String oldImageId) {
    setState(() {
      final index = images.indexWhere((image) => image.id == oldImageId);
      if (index != -1) {
        images[index] = updatedImage;
      }
    });
  }

  /// Usuwa obraz z listy.
  void removeImage(String imageId) {
    setState(() {
      images.removeWhere((image) => image.id == imageId);
    });
  }

  /// Filtruje obrazy na podstawie wartości w polu filtrowania.
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

  /// Sortuje obrazy według nazwy.
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

  /// Dodaje nowy obraz do listy.
  void addImage(MyImage newImage) {
    setState(() {
      images.add(newImage);
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
            addImage: addImage,
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
                                      onClose: () {
                                        setState(() {
                                          selectedImage = null;
                                        });
                                      },
                                      onUpdate: (updatedImage, oldImageId) =>
                                          updateImage(updatedImage, oldImageId),
                                      onDelete: removeImage,
                                      category: category,
                                      userLogin: widget.userLogin,
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
              category: category,
              closeSheet: () {
                Navigator.pop(context);
              },
              addImage: addImage,
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
