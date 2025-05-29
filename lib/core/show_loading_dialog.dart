import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// MUST be dismissed manually using Navigator.pop(context)
void showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder:
        (context) => PopScope(
          canPop: true, // TODO: change to false...
          child: Center(
            child: SizedBox(
              height: 80,
              width: 80,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
  );
}
