import 'package:flutter/animation.dart';
import 'tridimensional_carousel.dart';

class TridimensionalCarouselController {
  TridimensionalCarouselState tridimensionalCarouselState;
  AnimationController animation;

  void nextPage() {
    tridimensionalCarouselState.goToNextPage();
  }

  void previousPage() {
    tridimensionalCarouselState.goToPreviousPage();
  }

  void dispose() {
    animation.dispose();
  }
}
