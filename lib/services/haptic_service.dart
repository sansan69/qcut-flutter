import 'package:flutter/services.dart';

enum HapticType { light, medium, heavy, vibrate }

class HapticService {
  static Future<void> trigger(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
      case HapticType.vibrate:
        await HapticFeedback.vibrate();
    }
  }
}
