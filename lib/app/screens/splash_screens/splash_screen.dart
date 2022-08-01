import 'package:flutter/material.dart';
import 'package:wallet_box/app/core/constants/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: Center(
            child: ConstContext.lightMode(context)
                ? Image.asset(logoLight)
                : Image.asset(logoDark)),
      ),
    );
  }
}

// class Init {
//   Init._();
//   static final instance = Init._();

//   Future initialize() async {
//     await Future.delayed(const Duration(seconds: 3));
//   }
// }
