import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Shows a loading animation in the center of the screen and prevents the user from interacting with the
/// rest of the app while a `Future` is `await`ed
///
/// *Must* be dismissed manually using `Navigator.pop(context)`
void showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder:
        (context) => PopScope(
          canPop: false,
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
