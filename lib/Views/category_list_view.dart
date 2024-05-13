import 'package:flutter/material.dart';
import 'image_list_view.dart'; // Zakładamy, że ImageListView jest już zaimplementowane

class CategoryListView extends StatelessWidget {
  CategoryListView({Key? key, required this.userLogin}) : super(key: key);

  final String userLogin;
  final List<String> categories = [
    "Krajobraz",
    "Zwierzęta",
    "Sport",
    "Gry",
    "Inne"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wybierz kategorię"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final iconData = iconForCategory(category);
          return ListTile(
            title: Text(
              category,
              style: const TextStyle(fontSize: 20),
            ),
            trailing: Icon(iconData.icon, color: iconData.color),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageListView(userLogin: userLogin, category: category),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconInfo iconForCategory(String category) {
    switch (category) {
      case "Krajobraz":
        return IconInfo(Icons.grid_on, Colors.blue);
      case "Zwierzęta":
        return IconInfo(Icons.pets, Colors.green);
      case "Sport":
        return IconInfo(Icons.sports_soccer, Colors.red);
      case "Gry":
        return IconInfo(Icons.games, Colors.orange);
      case "Inne":
        return IconInfo(Icons.more_horiz, Colors.purple);
      default:
        return IconInfo(Icons.help_outline, Colors.grey);
    }
  }
}

class IconInfo {
  final IconData icon;
  final Color color;

  IconInfo(this.icon, this.color);
}