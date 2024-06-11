import 'package:flutter/material.dart';
import 'package:photogalleryapp/Models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/ApiService.dart';
import 'register_form_view.dart';
import 'dock_navigation_view.dart';

/// Widok formularza logowania do aplikacji.
class LoginFormView extends StatefulWidget {
  /// Notifier wskazujący, czy użytkownik jest zalogowany.
  final ValueNotifier<bool> isLoggedIn;

  /// Notifier przechowujący login użytkownika.
  final ValueNotifier<String> userLogin;

  /// Konstruktor przyjmujący wymagane parametry.
  const LoginFormView(
      {Key? key, required this.isLoggedIn, required this.userLogin})
      : super(key: key);

  @override
  _LoginFormViewState createState() => _LoginFormViewState();
}

/// Stan widoku formularza logowania.
class _LoginFormViewState extends State<LoginFormView> {
  /// Kontroler tekstu dla pola loginu.
  final TextEditingController _loginController = TextEditingController();

  /// Kontroler tekstu dla pola hasła.
  final TextEditingController _passwordController = TextEditingController();

  /// Flaga wskazująca, czy użytkownik chce zapamiętać swoje dane logowania.
  bool _rememberMe = false;

  /// Wiadomość o błędzie, wyświetlana gdy wystąpi problem z logowaniem.
  String errorMessage = "";

  /// Instancja serwisu API do komunikacji z serwerem.
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// Ładuje zapisane dane logowania z pamięci urządzenia.
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLogin = prefs.getString('savedLogin');
    String? savedPassword = prefs.getString('savedPassword');
    bool? rememberMe = prefs.getBool('rememberMe');

    if (savedLogin != null &&
        savedPassword != null &&
        rememberMe != null &&
        rememberMe) {
      _loginController.text = savedLogin;
      _passwordController.text = savedPassword;
      setState(() {
        _rememberMe = rememberMe;
      });
    }
  }

  /// Zapisuje dane logowania w pamięci urządzenia.
  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedLogin', _loginController.text);
      await prefs.setString('savedPassword', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedLogin');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        automaticallyImplyLeading: false,
      ),
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
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Zapamiętaj mnie"),
                      ],
                    ),
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

  /// Loguje użytkownika po kliknięciu przycisku "Zaloguj".
  void _loginUser() async {
    if (_loginController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          errorMessage = "Uzupełnij wszystkie pola!";
        });
      }
      return;
    }

    try {
      User user = User(
        login: _loginController.text,
        password: _passwordController.text,
        email: '', // Email nie jest wymagany przy logowaniu
      );

      await apiService.login(user);

      if (mounted) {
        setState(() {
          widget.userLogin.value = _loginController.text;
          widget.isLoggedIn.value = true;
          errorMessage = "";
        });
      }

      await _saveCredentials();

      // Przekierowanie do DockNavigationView po udanym logowaniu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DockNavigationView(
            isLoggedIn: widget.isLoggedIn,
            userLogin: widget.userLogin.value,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Podano błędne dane!";
        });
      }
    }
  }
}
