import 'package:flutter/material.dart';
import 'package:photogalleryapp/Models/User.dart';
import '../Services/ApiService.dart';
import 'login_form_view.dart';
import 'dock_navigation_view.dart';

/// Widok formularza rejestracji nowego użytkownika.
class RegisterFormView extends StatefulWidget {
  /// Notifier wskazujący, czy użytkownik jest zalogowany.
  final ValueNotifier<bool> isLoggedIn;

  /// Notifier przechowujący login użytkownika.
  final ValueNotifier<String> userLogin;

  /// Konstruktor przyjmujący wymagane parametry.
  const RegisterFormView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  @override
  _RegisterFormViewState createState() => _RegisterFormViewState();
}

/// Stan widoku formularza rejestracji.
class _RegisterFormViewState extends State<RegisterFormView> {
  /// Kontroler tekstu dla pola loginu.
  final TextEditingController _loginController = TextEditingController();

  /// Kontroler tekstu dla pola email.
  final TextEditingController _emailController = TextEditingController();

  /// Kontroler tekstu dla pola pierwszego hasła.
  final TextEditingController _password1Controller = TextEditingController();

  /// Kontroler tekstu dla pola powtórzenia hasła.
  final TextEditingController _password2Controller = TextEditingController();

  /// Wiadomość o błędzie, wyświetlana gdy wystąpi problem z rejestracją.
  String errorMessage = '';

  /// Wiadomość o sukcesie, wyświetlana po udanej rejestracji.
  String successMessage = '';

  /// Instancja serwisu API do komunikacji z serwerem.
  final ApiService apiService = ApiService();

  /// Flaga wskazująca, czy pierwsze hasło jest nieprawidłowe.
  bool isInputInvalid1 = false;

  /// Flaga wskazująca, czy drugie hasło jest nieprawidłowe.
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

  /// Rejestruje nowego użytkownika po kliknięciu przycisku "Zarejestruj się".
  void _registerUser() async {
    if (_password1Controller.text != _password2Controller.text) {
      setState(() => errorMessage = "Podane hasła nie są takie same!");
    } else if (_loginController.text.isEmpty ||
        _password1Controller.text.isEmpty ||
        _emailController.text.isEmpty) {
      setState(() => errorMessage = "Uzupełnij wszystkie pola!");
    } else if (_password1Controller.text.length < 5) {
      setState(() => errorMessage = "Hasło nie może mieć mniej niż 5 znaków!");
    } else {
      try {
        User user = User(
          login: _loginController.text,
          password: _password1Controller.text,
          email: _emailController.text,
        );

        await apiService.createUser(user);

        setState(() {
          errorMessage = '';
          successMessage = 'Konto zostało utworzone!';
          widget.userLogin.value = _loginController.text;
          widget.isLoggedIn.value = true;
        });

        _showSuccessDialog();
      } catch (e) {
        setState(() {
          errorMessage = 'Wystąpił błąd podczas rejestracji!';
        });
      }
    }
  }

  /// Wyświetla dialog informujący o pomyślnej rejestracji.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
            _navigateToHome();
          }
        });
        return AlertDialog(
          title: const Text("Sukces"),
          content: const Text("Konto zostało utworzone!"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
                _navigateToHome();
              },
            ),
          ],
        );
      },
    );
  }

  /// Przekierowuje użytkownika do widoku głównego po pomyślnej rejestracji.
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DockNavigationView(
          isLoggedIn: widget.isLoggedIn,
          userLogin: widget.userLogin.value,
        ),
      ),
    );
  }
}
