import 'package:flutter/material.dart';
import 'package:screen_loader/screen_loader.dart';

class CustomLoader extends StatelessWidget with ScreenLoader {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  @override
  loader() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // color: ConstContext.lightMode(context)
          //     ? CustomColors.lightPrimaryBackground
          //     : CustomColors.darkPrimaryBackground,
        ),
        child: const CircularProgressIndicator(),
        width: 100,
        height: 100,
        alignment: Alignment.center,
      ),
    );
  }

  @override
  loadingBgBlur() => 10.0;
}
