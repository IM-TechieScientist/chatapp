import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF36393F), // Discord dark background
    primary: Color(0xFF2C2F33), // Discord dark primary
    secondary:Color.fromARGB(255, 85, 93, 101) , // Discord blurple
    tertiary: Color(0xFFFFFFFF), // White text
    tertiaryFixed: Color(0xFF2C2F33), // Discord dark primary
    tertiaryContainer: Color(0xFF5865F2), // Discord dark container
    inversePrimary: Color.fromARGB(255, 255, 255, 255), // Discord dark text
  ),
);
