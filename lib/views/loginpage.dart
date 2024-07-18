import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child:Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0), // Set the corner radius
            color: Color(0xFF5B8ADB),
          ),
          margin: const EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),
          child: Container(
            margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
            width: 480,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logowhite.png'),
                const SizedBox(height: 40),
                TextFormField(
                  style: const TextStyle(
                      fontSize: 25,
                      color: Color(0xFF5B8ADB)
                  ),
                  decoration:InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Username",
                    hintStyle: TextStyle(color: Color(0xFF5B8ADB)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: const TextStyle(
                      fontSize: 25,
                      color: Color(0xFF5B8ADB)),
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
                const SizedBox(height: 20),
                Container(
                  width: 230,
                  height: 68,
                  child: ElevatedButton(onPressed: () {},
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF5B8ADB)
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: 230,
                  height: 68,
                  child: ElevatedButton(onPressed: () {},
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF5B8ADB)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}