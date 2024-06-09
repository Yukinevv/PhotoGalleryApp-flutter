import 'package:flutter/material.dart';
import 'file_upload_view.dart';
import '../Models/MyImage.dart';

class FiltersView extends StatefulWidget {
  final String userLogin;
  final String category;
  final int filteredImagesCount;
  final ValueNotifier<String> filterField;
  final Function(bool) sortByName;
  final Function(MyImage) addImage;

  const FiltersView({
    Key? key,
    required this.userLogin,
    required this.category,
    required this.filteredImagesCount,
    required this.filterField,
    required this.sortByName,
    required this.addImage,
  }) : super(key: key);

  @override
  _FiltersViewState createState() => _FiltersViewState();
}

class _FiltersViewState extends State<FiltersView> {
  bool isSheetPresented = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: widget.filterField,
                  builder: (context, value, child) {
                    return TextField(
                      decoration: const InputDecoration(
                        hintText: 'Szukaj obrazów',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        widget.filterField.value = value;
                      },
                      autocorrect: false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text("Ilość: ${widget.filteredImagesCount}"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text("Sortuj:"),
              IconButton(
                icon: const Icon(Icons.arrow_upward,
                    color: Colors.blue, size: 35),
                onPressed: () => widget.sortByName(true),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward,
                    color: Colors.blue, size: 35),
                onPressed: () => widget.sortByName(false),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() => isSheetPresented = true);
                  if (isSheetPresented) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => FileUploadView(
                        userLogin: widget.userLogin,
                        category: widget.category,
                        closeSheet: () {
                          setState(() => isSheetPresented = false);
                        },
                        addImage: widget.addImage, // Zmienione
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Dodaj obraz'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
