import 'package:flutter/material.dart';

void showToast(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.clearSnackBars();

  scaffold.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          scaffold.hideCurrentSnackBar();
        },
      ),
    ),
  );
}
