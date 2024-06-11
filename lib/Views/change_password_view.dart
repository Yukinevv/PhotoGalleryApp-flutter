import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:photogalleryapp/constants.dart';

/// Widok zmiany hasła, który pozwala użytkownikowi zmienić swoje hasło.
class ChangePasswordView extends StatefulWidget {
  /// Login użytkownika, który jest przekazywany do widoku.
  final String userLogin;

  /// Konstruktor, który przyjmuje login użytkownika.
  const ChangePasswordView({Key? key, required this.userLogin})
      : super(key: key);

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

/// Stan widoku zmiany hasła.
class _ChangePasswordViewState extends State<ChangePasswordView> {
  /// Kontroler tekstu dla pola z obecnym hasłem.
  final TextEditingController _currentPasswordController =
      TextEditingController();

  /// Kontroler tekstu dla pola z nowym hasłem.
  final TextEditingController _newPasswordController = TextEditingController();

  /// Kontroler tekstu dla pola z potwierdzeniem nowego hasła.
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  /// Wiadomość o błędzie, która jest wyświetlana w przypadku problemów.
  String errorMessage = "";

  /// Wiadomość o sukcesie, która jest wyświetlana po pomyślnej zmianie hasła.
  String successMessage = "";

  /// Flaga wskazująca, czy dialog potwierdzenia jest wyświetlany.
  bool isShowingConfirmationDialog = false;

  /// Flaga wskazująca, czy wejście dla nowego hasła jest nieprawidłowe.
  bool isInputInvalid1 = false;

  /// Flaga wskazująca, czy wejście dla potwierdzenia nowego hasła jest nieprawidłowe.
  bool isInputInvalid2 = false;

  /// Metoda sprawdzająca, czy wejście jest prawidłowe.
  ///
  /// Parametr:
  /// - `input`: String reprezentujący wejście użytkownika.
  ///
  /// Zwraca:
  /// - `bool`: True, jeśli wejście jest prawidłowe (długość >= 5), w przeciwnym razie False.
  bool isValid(String input) {
    return input.length >= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zmień hasło'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Zmień swoje hasło",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                const Text("Obecne hasło:"),
                TextField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  autocorrect: false,
                ),
                const SizedBox(height: 20),
                const Text("Nowe hasło:"),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    errorText: isInputInvalid1
                        ? 'Hasło musi mieć co najmniej 5 znaków'
                        : null,
                  ),
                  obscureText: true,
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      isInputInvalid1 = !isValid(value);
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text("Potwierdź nowe hasło:"),
                TextField(
                  controller: _confirmNewPasswordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    errorText: isInputInvalid2
                        ? 'Hasło musi mieć co najmniej 5 znaków'
                        : null,
                  ),
                  obscureText: true,
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      isInputInvalid2 = !isValid(value);
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (successMessage.isNotEmpty)
                  Text(
                    successMessage,
                    style: const TextStyle(color: Colors.green),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    child: const Text("Zmień hasło"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Wyświetla dialog potwierdzenia zmiany hasła.
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zmiana hasła'),
          content: const Text('Czy na pewno chcesz zmienić swoje hasło?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Nie'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _changePassword();
              },
              child: const Text('Tak'),
            ),
          ],
        );
      },
    );
  }

  /// Metoda asynchroniczna zmieniająca hasło użytkownika.
  ///
  /// Sprawdza, czy wszystkie pola są wypełnione, hasła się zgadzają,
  /// oraz czy hasło spełnia wymagania. Następnie wysyła żądanie HTTP
  /// do zmiany hasła.
  void _changePassword() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmNewPassword.isEmpty) {
      setState(() {
        errorMessage = "Pola nie mogą być puste!";
      });
      return;
    } else if (newPassword != confirmNewPassword) {
      setState(() {
        errorMessage = "Nowo podane hasła nie są takie same!";
      });
      return;
    } else if (currentPassword == newPassword) {
      setState(() {
        errorMessage = "Obecne oraz nowe hasło nie może być takie same!";
      });
      return;
    } else if (newPassword.length < 5) {
      setState(() {
        errorMessage = "Hasło nie może mieć mniej niż 5 znaków!";
      });
      return;
    }

    String url =
        "$apiUrl/users/editPassword/${widget.userLogin}/$currentPassword/$newPassword";

    var response = await http.put(Uri.parse(url));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData["message"] == "Wrong password") {
        setState(() {
          errorMessage = "Podano niepoprawne hasło!";
          _currentPasswordController.clear();
        });
      } else {
        setState(() {
          successMessage = "Hasło zostało zmienione!";
          errorMessage = "";
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
      }
    } else {
      setState(() {
        errorMessage = "Wystąpił błąd podczas zmiany hasła.";
      });
    }
  }
}
