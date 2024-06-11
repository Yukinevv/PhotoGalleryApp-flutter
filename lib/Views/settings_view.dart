import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'change_password_view.dart';
import 'login_form_view.dart';

/// Widok ustawień aplikacji, umożliwiający zmianę hasła, wylogowanie oraz dostęp do linków.
class SettingsView extends StatelessWidget {
  /// Notifier wskazujący, czy użytkownik jest zalogowany.
  final ValueNotifier<bool> isLoggedIn;

  /// Login użytkownika.
  final String userLogin;

  /// Konstruktor przyjmujący wymagane parametry.
  const SettingsView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        children: [
          /// Wyświetla login użytkownika w pogrubionym stylu.
          ListTile(
            title: Text(userLogin,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          /// Opcja zmiany hasła, przekierowuje do widoku `ChangePasswordView`.
          ListTile(
            title: const Text('Zmień hasło'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChangePasswordView(userLogin: userLogin),
                ),
              );
            },
          ),

          /// Opcja wylogowania, wyświetla dialog potwierdzenia.
          ListTile(
            title: const Text('Wyloguj'),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const ListTile(
            title: Text('Inne', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          /// Opcja otwarcia linku do API.
          ListTile(
            title: const Text('Link do API'),
            onTap: () async {
              const url =
                  "https://photo-gallery-api-59f6baae823c.herokuapp.com/api/images";
              final Uri uri = Uri.parse(url);
              print('Attempting to launch URL: $url');
              if (await canLaunchUrl(uri)) {
                print('Launching URL');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                print('Could not launch URL');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nie można otworzyć URL')),
                );
              }
            },
          ),

          /// Opcja otwarcia innego linku.
          ListTile(
            title: const Text('Inny link'),
            onTap: () async {
              const url =
                  'https://pl.wikipedia.org/wiki/Interfejs_programowania_aplikacji';
              final Uri uri = Uri.parse(url);
              print('Attempting to launch URL: $url');
              if (await canLaunchUrl(uri)) {
                print('Launching URL');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                print('Could not launch URL');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nie można otworzyć URL')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Wyświetla dialog potwierdzenia wylogowania.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wyloguj'),
          content: const Text('Czy na pewno chcesz się wylogować?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: const Text('Nie'),
            ),
            TextButton(
              onPressed: () {
                isLoggedIn.value = false;
                Navigator.of(context).pop(); // Zamknij dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginFormView(
                      isLoggedIn: isLoggedIn,
                      userLogin: ValueNotifier<String>(''),
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Tak'),
            ),
          ],
        );
      },
    );
  }
}
