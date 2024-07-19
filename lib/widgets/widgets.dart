import 'package:flutter/material.dart';

class Widgets {
  static Future<void> showCustomDialog(
      BuildContext context, {
        required String title,
        required String content,
        VoidCallback? onDialogClose,
      }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onDialogClose != null) {
                  onDialogClose();
                }
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
