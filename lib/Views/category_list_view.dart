import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_list_view.dart';

/// Klasa `CategoryListView` odpowiada za wyświetlanie listy kategorii.
/// Użytkownik może wybrać kategorię, co spowoduje przejście do widoku listy obrazów dla tej kategorii.
class CategoryListView extends StatelessWidget {
  /// Konstruktor przyjmuje `userLogin`, który jest loginem użytkownika.
  CategoryListView({Key? key, required this.userLogin}) : super(key: key);

  /// Login użytkownika przekazywany do widoku listy obrazów.
  final String userLogin;

  /// Lista kategorii dostępnych do wyboru.
  final List<String> categories = [
    "Krajobraz",
    "Zwierzęta",
    "Sport",
    "Gry",
    "Architektura",
    "Moda",
    "Jedzenie",
    "Technologia",
    "Podróże",
    "Inne",
  ];

  /// Metoda asynchroniczna czyszcząca pamięć podręczną aplikacji.
  /// Wywoływana po naciśnięciu przycisku usuwania w pasku akcji.
  Future<void> clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Cache cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wybierz kategorię"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: clearCache,
            tooltip: "Wyczyść Cache",
          ),
        ],
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

  /// Metoda `iconForCategory` zwraca ikonę i kolor odpowiednie do kategorii.
  ///
  /// Parametr:
  /// - `category`: Nazwa kategorii jako string.
  ///
  /// Zwraca:
  /// - `IconInfo`: Obiekt zawierający ikonę i kolor przypisane do kategorii.
  IconInfo iconForCategory(String category) {
    switch (category) {
      case "Krajobraz":
        return IconInfo(Icons.landscape, Colors.blue);
      case "Zwierzęta":
        return IconInfo(Icons.pets, Colors.green);
      case "Sport":
        return IconInfo(Icons.sports_soccer, Colors.red);
      case "Gry":
        return IconInfo(Icons.games, Colors.orange);
      case "Architektura":
        return IconInfo(Icons.account_balance, Colors.brown);
      case "Moda":
        return IconInfo(Icons.style, Colors.pink);
      case "Jedzenie":
        return IconInfo(Icons.fastfood, Colors.yellow);
      case "Technologia":
        return IconInfo(Icons.computer, Colors.teal);
      case "Podróże":
        return IconInfo(Icons.airplanemode_active, Colors.cyan);
      case "Inne":
        return IconInfo(Icons.more_horiz, Colors.purple);
      default:
        return IconInfo(Icons.help_outline, Colors.grey);
    }
  }
}

/// Klasa `IconInfo` przechowuje informacje o ikonie i jej kolorze.
class IconInfo {
  /// Ikona kategorii.
  final IconData icon;

  /// Kolor ikony kategorii.
  final Color color;

  /// Konstruktor przyjmujący ikonę i kolor.
  IconInfo(this.icon, this.color);
}
