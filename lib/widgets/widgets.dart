import 'package:chatapp_firebase/shared/constants.dart';
import 'package:flutter/material.dart';

final textInputDecoration = InputDecoration(
  isDense: true,
  labelStyle: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w300,
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.blue,
      width: 2,
    ),
  ),
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.purple,
      width: 2,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Constants().primaryColor,
      width: 2,
    ),
  ),
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void snowSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      backgroundColor: color,
      duration: const Duration(
        seconds: 2,
      ),
      action: SnackBarAction(
        label: 'ok',
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
