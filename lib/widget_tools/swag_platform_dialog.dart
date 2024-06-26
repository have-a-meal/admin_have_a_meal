import 'dart:io' show Platform;
import 'package:admin_have_a_meal/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> swagPlatformDialog({
  required BuildContext context,
  required String title,
  required String message,
  required List<Widget> actions,
}) async {
  if (Platform.isIOS) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        actions: actions,
      ),
      barrierDismissible: true,
    );
  } else if (Platform.isAndroid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: Sizes.size16,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: actions,
      ),
      useSafeArea: false,
    );
  }
}
