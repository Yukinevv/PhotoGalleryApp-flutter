import 'package:flutter/material.dart';
import 'category_list_view.dart';
import 'settings_view.dart';

class DockNavigationView extends StatefulWidget {
  final ValueNotifier<bool> isLoggedIn;
  final String userLogin;

  const DockNavigationView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  @override
  _DockNavigationViewState createState() => _DockNavigationViewState();
}

class _DockNavigationViewState extends State<DockNavigationView> {
  int _selectedIndex = 0;

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
          CategoryListView(userLogin: widget.userLogin),
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
