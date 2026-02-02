import 'package:flutter/material.dart';

class AlertService {
  static Future<void> show(
    BuildContext context,
    String message, {
    String title = "Attenzione",
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
