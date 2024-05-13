import 'package:flutter/material.dart';
import 'register_form_view.dart'; // Załóżmy, że już istnieje plik z widokiem rejestracji

class LoginFormView extends StatefulWidget {
  const LoginFormView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  final ValueNotifier<bool> isLoggedIn;
  final ValueNotifier<String> userLogin;

  @override
  _LoginFormViewState createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Photo Gallery'), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Photo Gallery",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Icon(Icons.camera_alt, size: 35),
              const SizedBox(height: 20),
              const Text("Zaloguj się na swoje konto",
                  style: TextStyle(fontSize: 20)),
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
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    const Text("Hasło"),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          hintText: "Hasło", border: OutlineInputBorder()),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    if (errorMessage.isNotEmpty)
                      Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        child: const Text("Zaloguj"),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterFormView(
                            isLoggedIn: widget.isLoggedIn,
                            userLogin: widget.userLogin))),
                child: const Text("Nie masz konta? Zarejestruj się"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _loginUser() {
    if (_loginController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Uzupełnij wszystkie pola!";
      });
      return;
    }
    // Implementacja logowania - zastąp to odpowiednią logiką API
    setState(() {
      widget.userLogin.value = _loginController.text;
      widget.isLoggedIn.value = true;
      errorMessage = "";
    });
  }
}
