import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/l10n/app_localizations.dart';

void main() {
  test('bookWithShopMsg replaces both placeholders', () {
    final l10n = AppLocalizations(const Locale('en'));
    final result = l10n.bookWithShopMsg('My Shop', 'https://qcut.in/my-shop');
    expect(result, contains('My Shop'));
    expect(result, contains('https://qcut.in/my-shop'));
  });

  test('bookWithShopMsg replaces both placeholders in Malayalam', () {
    final l10n = AppLocalizations(const Locale('ml'));
    final result = l10n.bookWithShopMsg('My Shop', 'https://qcut.in/my-shop');
    expect(result, contains('My Shop'));
    expect(result, contains('https://qcut.in/my-shop'));
  });
}
