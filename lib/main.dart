import 'package:flutter/material.dart';
import 'Views/login_form_view.dart'; // Upewnij się, że ścieżka do tego pliku jest poprawna
import 'Views/category_list_view.dart'; // Import CategoryListView

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<bool> _isLoggedIn = ValueNotifier<bool>(false);
  final ValueNotifier<String> _userLogin = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoggedIn,
      builder: (context, isLoggedIn, child) {
        if (isLoggedIn) {
          // Gdy użytkownik jest zalogowany, pokazujemy CategoryListView
          return CategoryListView(userLogin: _userLogin.value);
        } else {
          // Gdy użytkownik nie jest zalogowany, pokazujemy formularz logowania
          return LoginFormView(isLoggedIn: _isLoggedIn, userLogin: _userLogin);
        }
      },
    );
  }
}
