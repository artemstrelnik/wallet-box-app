import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog {
  static Future<void> dialogError({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        if (!Platform.isIOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text(
                  "Dismiss",
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          );
        } else {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Dismiss",
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
