import 'package:flutter/foundation.dart';

/// Content for a single onboarding slide.
class OnboardingSlide {
  const OnboardingSlide({
    required this.head,
    required this.sub,
    required this.cta,
    required this.imageId,
  });

  final String head;
  final String sub;
  final String cta;
  final String imageId;
}

class OnboardingViewModel extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  static const slides = <OnboardingSlide>[
    OnboardingSlide(
      head: 'Find your next pitch.',
      sub: 'Discover football pitches near you and compare prices instantly.',
      cta: 'Next',
      imageId: '1522778119026-d647f0596c20',
    ),
    OnboardingSlide(
      head: "Know when it's free.",
      sub: 'No calls. No waiting for WhatsApp replies.',
      cta: 'Next',
      imageId: '1518604666860-9ed391f76460',
    ),
    OnboardingSlide(
      head: 'Book and play.',
      sub: 'Pay with M-Pesa or Airtel Money and get instant confirmation.',
      cta: 'Get Started',
      imageId: '1526232761682-d26e03ac148e',
    ),
  ];

  OnboardingSlide get current => slides[_index];
  bool get isLast => _index == slides.length - 1;
  bool get isSecond => _index == 1;
  bool get isThird => _index == 2;

  /// Advances a slide. Returns true when onboarding is finished (go to login).
  bool next() {
    if (_index < slides.length - 1) {
      _index++;
      notifyListeners();
      return false;
    }
    return true;
  }
}
