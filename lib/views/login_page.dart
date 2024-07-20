import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waterwize/views/register_page.dart';
import 'home_page.dart';
import 'package:waterwize/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedIn = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Widgets.showCustomDialog(
        context,
        title: "Erro",
        content: "Por favor, preencha todos os campos.",
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await Widgets.showCustomDialog(
        context,
        title: "Sucesso",
        content: "Login efetuado com sucesso",
      );

      _emailController.clear();
      _passwordController.clear();

      setState(() {
        _isLoggedIn = true;
      });
    } on FirebaseAuthException catch (e) {
      Widgets.showCustomDialog(
        context,
        title: "Erro",
        content: e.message ?? "Ocorreu um erro durante o login.",
      );
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: _isLoggedIn ? MediaQuery.of(context).size.width : 480,
              height: _isLoggedIn ? 71 : MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFF5B8ADB),
              ),
              margin: const EdgeInsets.all(15),
              child: Center(
                child: _isLoggedIn ? buildTopBar() : buildLoginForm(),
              ),
            ),
          ),
          if (_isLoggedIn)
            Positioned.fill(
              top: 71 + 30, // To position the home screen content below the top bar
              child: HomeScreen(onLogout: _logout),
            ),
        ],
      ),
    );
  }

  Widget buildLoginForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logowhite.png'),
          const SizedBox(height: 75),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(fontSize: 25, color: Color(0xFF5B8ADB)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: "Username",
              hintStyle: const TextStyle(color: Color(0xFF5B8ADB)),
            ),
          ),
          const SizedBox(height: 25),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(fontSize: 25, color: Color(0xFF5B8ADB)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: "Password",
              hintStyle: const TextStyle(color: Color(0xFF5B8ADB)),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 70),
          SizedBox(
            width: 230,
            height: 68,
            child: ElevatedButton(
              onPressed: _login,
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 25, color: Color(0xFF5B8ADB)),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 230,
            height: 68,
            child: ElevatedButton(
              onPressed: _goToRegister,
              child: const Text(
                'Registar',
                style: TextStyle(fontSize: 25, color: Color(0xFF5B8ADB)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToRegister(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>const RegistrationPage()));
  }

  Widget buildTopBar() {
    return Center(
      child: ElevatedButton(
        onPressed: _logout,
        child: const Text('Voltar'),
      ),
    );
  }
}
