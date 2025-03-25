import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    // very dark - app bar + drawer color
    surface: Color.fromARGB(255, 9, 9, 9),
    // slightly light
    primary: Color.fromARGB(255, 103, 103, 103),
    // dark
    secondary: Color.fromARGB(255, 20, 20, 20),
    // slightly dark
    tertiary: Color.fromARGB(255, 31, 31, 31),
    // very light
    inversePrimary: Color.fromARGB(255, 196, 196, 196),
  ),
  scaffoldBackgroundColor: Color.fromARGB(255, 9, 9, 9),
);
