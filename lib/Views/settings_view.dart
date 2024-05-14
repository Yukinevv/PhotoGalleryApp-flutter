import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'change_password_view.dart';
import 'login_form_view.dart';

class SettingsView extends StatelessWidget {
  final ValueNotifier<bool> isLoggedIn;
  final String userLogin;

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
          const ListTile(
            title: Text('Użytkownik',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
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
          ListTile(
            title: const Text('Wyloguj'),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const ListTile(
            title: Text('Inne', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Link do API'),
            onTap: () async {
              const url = 'http://10.0.2.2:8080/api/users';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ],
      ),
    );
  }

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