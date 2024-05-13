import 'package:flutter/material.dart';
import 'login_form_view.dart'; // Zakładając, że LoginFormView jest już zaimplementowane

class RegisterFormView extends StatefulWidget {
  const RegisterFormView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  final ValueNotifier<bool> isLoggedIn;
  final ValueNotifier<String> userLogin;

  @override
  _RegisterFormViewState createState() => _RegisterFormViewState();
}

class _RegisterFormViewState extends State<RegisterFormView> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  String errorMessage = '';
  String successMessage = '';

  bool isInputInvalid1 = false;
  bool isInputInvalid2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Utwórz konto"), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text("Utwórz konto",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Login"),
                  TextField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                        hintText: "Login", border: OutlineInputBorder()),
                    autocorrect: false,
                  ),
                  const SizedBox(height: 10),
                  const Text("Email"),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        hintText: "Email", border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  const Text("Hasło"),
                  TextField(
                    controller: _password1Controller,
                    decoration: const InputDecoration(
                        hintText: "Hasło", border: OutlineInputBorder()),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  const Text("Powtórz hasło"),
                  TextField(
                    controller: _password2Controller,
                    decoration: const InputDecoration(
                        hintText: "Powtórz hasło",
                        border: OutlineInputBorder()),
                    obscureText: true,
                  ),
                  if (errorMessage.isNotEmpty)
                    Text(errorMessage,
                        style: const TextStyle(color: Colors.red)),
                  if (successMessage.isNotEmpty)
                    Text(successMessage,
                        style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      child: const Text("Zarejestruj się"),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginFormView(
                          isLoggedIn: widget.isLoggedIn,
                          userLogin: widget.userLogin)),
                );
              },
              child: const Text("Masz już konto? Zaloguj się"),
            )
          ],
        ),
      ),
    );
  }

  void _registerUser() {
    if (_password1Controller.text != _password2Controller.text) {
      setState(() => errorMessage = "Podane hasła nie są takie same!");
    } else if (_loginController.text.isEmpty ||
        _password1Controller.text.isEmpty ||
        _emailController.text.isEmpty) {
      setState(() => errorMessage = "Uzupełnij wszystkie pola!");
    } else if (_password1Controller.text.length < 5) {
      setState(() => errorMessage = "Hasło nie może mieć mniej niż 5 znaków!");
    } else {
      // Tutaj zaimplementuj logikę API do rejestracji użytkownika
      setState(() {
        errorMessage = '';
        successMessage = 'Konto zostało utworzone!';
        // Przypuszczamy, że rejestracja zakończyła się sukcesem
      });
    }
  }
}
