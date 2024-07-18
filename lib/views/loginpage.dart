import 'package:flutter/material.dart';
import 'homescreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedIn = false;

  void _login() {
    setState(() {
      _isLoggedIn = true;
    });
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
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: _isLoggedIn ? MediaQuery.of(context).size.width : 480,
              height: _isLoggedIn ? 71 : MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color(0xFF5B8ADB),
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
          const SizedBox(height: 50),
          TextFormField(
            style: const TextStyle(fontSize: 25, color: Color(0xFF5B8ADB)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: "Username",
              hintStyle: TextStyle(color: Color(0xFF5B8ADB)),
            ),
          ),
          const SizedBox(height: 25),
          TextFormField(
            style: const TextStyle(fontSize: 25, color: Color(0xFF5B8ADB)),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: "Password",
              hintStyle: TextStyle(color: Color(0xFF5B8ADB)),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 70),
          Container(
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
          Container(
            width: 230,
            height: 68,
            child: ElevatedButton(
              onPressed: () {},
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

  Widget buildTopBar() {
    return Center(
      child: ElevatedButton(
        onPressed: _logout,
        child: const Text('Voltar'),
      ),
    );
  }
}
