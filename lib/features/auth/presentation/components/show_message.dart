import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(title: Text(message)),
  );
}
