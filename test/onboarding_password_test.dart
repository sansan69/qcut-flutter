import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/models/onboarding_models.dart';

void main() {
  test('password must be at least 6 characters', () {
    final form = OnboardingFormData()..password = '12345';
    expect(form.password.length >= 6, isFalse);
  });

  test('password and confirm password match', () {
    final form = OnboardingFormData()
      ..password = 'secret123'
      ..confirmPassword = 'secret123';
    expect(form.password, form.confirmPassword);
  });
}
