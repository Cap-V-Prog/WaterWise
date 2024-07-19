import 'package:flutter/material.dart';

class Widgets {
  static void showCustomDialog(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
