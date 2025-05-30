import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WaveLoadingAnimation extends StatelessWidget {
  const WaveLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.waveDots(
        color: Theme.of(context).primaryColor,
        size: 50,
      ),
    );
  }
}
