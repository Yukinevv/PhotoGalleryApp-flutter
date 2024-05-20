import 'package:flutter/material.dart';
import 'Views/dock_navigation_view.dart';
import 'Views/login_form_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),
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
          return DockNavigationView(
              isLoggedIn: _isLoggedIn, userLogin: _userLogin.value);
        } else {
          return LoginFormView(isLoggedIn: _isLoggedIn, userLogin: _userLogin);
        }
      },
    );
  }
}
