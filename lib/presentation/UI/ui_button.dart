

import 'package:flutter/material.dart';

class UIButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final bool isEnabled;

  const UIButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
  });

  void press() {
    if (isEnabled) {
      onPressed();
    } else {
      print('Button is disabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? () => press() : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? const Color(0xFF017d1c) : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}