import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mem_game/core/error/app_exceptions.dart';
import 'package:mem_game/core/error/dio_exception_mapper.dart';

Future<String?> showTextInputDialogWithLoading({
  required BuildContext context,
  required String titleKey,
  required String hintKey,
  required String confirmKey,
  required String cancelKey,
  required Future<void> Function(String username) onConfirm,
}) {
  final controller = TextEditingController();
  bool isLoading = false;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(titleKey.tr()),
            content: TextField(controller: controller, decoration: InputDecoration(hintText: hintKey.tr())),
            actions: [
              ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(cancelKey.tr()),
              ),
              ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          final input = controller.text.trim();
                          if (input.isEmpty) return;

                          setState(() => isLoading = true);

                          try {
                            await onConfirm(input);

                            if (context.mounted) {
                              Navigator.of(context).pop(input);
                            }
                          } on DioException catch (dioErr) {
                            if (context.mounted) {
                              final appEx = AppExceptionMapper.fromDioException(dioErr);
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(appEx.localizedMessage)));
                            }
                          } on AppException catch (appEx) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(appEx.localizedMessage)));
                            }
                          } catch (_) {
                            if (context.mounted) {
                              const fallback = UnknownException();
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(fallback.localizedMessage)));
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                child:
                    isLoading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(confirmKey.tr()),
              ),
            ],
          );
        },
      );
    },
  );
}
