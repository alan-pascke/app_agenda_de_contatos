import 'package:flutter/material.dart';

Widget buttonSelectImage({
  required String text,
  required IconData icon,
  required VoidCallback onClicked,
}) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.orange[800],
      primary: Colors.white,
      padding: const EdgeInsets.all(10),
    ),
    onPressed: onClicked,
    child: Row(
      children: [
        Icon(
          icon,
          size: 30,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    ),
  );
}
