import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordView extends StatefulWidget {
  final String userLogin;

  const ChangePasswordView({Key? key, required this.userLogin})
      : super(key: key);

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  String errorMessage = "";
  String successMessage = "";
  bool isShowingConfirmationDialog = false;
  bool isInputInvalid1 = false;
  bool isInputInvalid2 = false;

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

    const String apiUrl = "http://10.0.2.2:8080/api";
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
