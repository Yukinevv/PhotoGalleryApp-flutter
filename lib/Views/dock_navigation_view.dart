import 'package:flutter/material.dart';
import 'category_list_view.dart';
import 'settings_view.dart';

/// Główny widok nawigacji z dolnym paskiem nawigacyjnym.
/// Umożliwia przełączanie między widokiem kategorii a widokiem ustawień.
class DockNavigationView extends StatefulWidget {
  /// Notifier informujący o stanie zalogowania użytkownika.
  final ValueNotifier<bool> isLoggedIn;

  /// Login użytkownika przekazywany do widoków.
  final String userLogin;

  /// Konstruktor przyjmujący wymagane parametry.
  const DockNavigationView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  @override
  _DockNavigationViewState createState() => _DockNavigationViewState();
}

/// Stan widoku nawigacji z dolnym paskiem nawigacyjnym.
class _DockNavigationViewState extends State<DockNavigationView> {
  /// Indeks aktualnie wybranego widoku.
  int _selectedIndex = 0;

  /// Metoda wywoływana po kliknięciu w element dolnego paska nawigacyjnego.
  ///
  /// Parametr:
  /// - `index`: Indeks wybranego elementu.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          /// Widok listy kategorii.
          CategoryListView(userLogin: widget.userLogin),

          /// Widok ustawień.
          SettingsView(
              isLoggedIn: widget.isLoggedIn, userLogin: widget.userLogin),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Galeria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ustawienia',
          ),
        ],
      ),
    );
  }
}
