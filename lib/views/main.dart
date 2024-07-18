import 'package:flutter/material.dart';
import 'package:waterwize/firebase_options.dart';
import 'package:waterwize/views/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';

/*
void main() {
  Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyA1glFiIXPEjVFwKuc4tc30GMVt_xfhA5E",
      authDomain: "waterwise-2cba6.firebaseapp.com",
      projectId: "waterwise-2cba6",
      storageBucket: "waterwise-2cba6.appspot.com",
      messagingSenderId: "401094204328",
      appId: "1:401094204328:web:ac3b0d67da4e0ca3661b9d",
      measurementId: "G-H1LM8F75TN")
  );
  runApp(const MyApp());
}
*/
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterWise',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF5B8ADB)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              )
            )
          )
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

