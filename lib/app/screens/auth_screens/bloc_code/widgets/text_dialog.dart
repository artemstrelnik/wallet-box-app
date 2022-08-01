import 'package:flutter/cupertino.dart';

Future<void> showMyDialog(context,
    {String? title, required String message}) async {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      content: Text(message.split(":").last.trim()),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: const Text('ОК'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ),
  );
}
