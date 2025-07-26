import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';




Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String titleKey,
  required String contentKey,
  required String confirmKey,
  required String cancelKey,
   bool barrierDismissible = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titleKey.tr()),
      content: Text(contentKey.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelKey.tr()),
        ),
        ElevatedButton(
       
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmKey.tr()),
        ),
      ],
    ),
  );

  return result == true;
}

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String titleKey,
  required String hintKey,
  required String confirmKey,
  required String cancelKey,
}) async {
  String input = '';

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titleKey.tr()),
      content: TextField(
        decoration: InputDecoration(labelText: hintKey.tr()),
        onChanged: (value) => input = value,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelKey.tr()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmKey.tr()),
        ),
      ],
    ),
  );

  return result == true && input.trim().isNotEmpty ? input.trim() : null;
}
