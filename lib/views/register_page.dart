import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waterwize/widgets/widgets.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepController = TextEditingController();

  Future<void> _registerUser() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String passwordRep = _passwordRepController.text;

    if (password == passwordRep) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          // Set initial daily goal in Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'dailyGoal': 3.0,
            'progress': 0.0,
            'lastUpdated': Timestamp.fromDate(DateTime.now()),
          });

          _emailController.clear();
          _passwordController.clear();
          _passwordRepController.clear();

          await Widgets.showCustomDialog(context, title: "Sucesso", content: "Utilizador registado com sucesso!");
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        Widgets.showCustomDialog(
          context,
          title: "Erro de autenticação",
          content: e.message ?? "Ocorreu um erro durante o registo",
        );
      }
    } else {
      Widgets.showCustomDialog(
        context,
        title: "Erro",
        content: "Passwords não coincidem!",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          color: const Color(0xFF5B8ADB),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(15),
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Image.asset('assets/images/logoblue.png'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFF5B8ADB),
                      filled: true,
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFF5B8ADB),
                      filled: true,
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordRepController,
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFF5B8ADB),
                      filled: true,
                      hintText: "Repetir Password",
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 37),
                  SizedBox(
                    width: 230,
                    height: 68,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8ADB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _registerUser,
                      child: const Text(
                        'Registar',
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 230,
                    height: 68,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8ADB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Voltar',
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
