import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

void main() {
  group('FunctionsService', () {
    test('exposes correct helloWorld callable name', () {
      expect(FunctionsService.helloWorld, 'helloWorld');
    });

    test('exposes correct issueToken callable name', () {
      expect(FunctionsService.issueToken, 'issueToken');
    });

    test('exposes correct callNextToken callable name', () {
      expect(FunctionsService.callNextToken, 'callNextToken');
    });

    test('exposes correct completeToken callable name', () {
      expect(FunctionsService.completeToken, 'completeToken');
    });

    test('exposes correct noShowToken callable name', () {
      expect(FunctionsService.noShowToken, 'noShowToken');
    });

    test('exposes correct createBooking callable name', () {
      expect(FunctionsService.createBooking, 'createBooking');
    });

    test('exposes correct cancelBooking callable name', () {
      expect(FunctionsService.cancelBooking, 'cancelBooking');
    });

    test('exposes correct convertBookingToToken callable name', () {
      expect(FunctionsService.convertBookingToToken, 'convertBookingToToken');
    });

    test('exposes correct enforcePlanLimits callable name', () {
      expect(FunctionsService.enforcePlanLimits, 'enforcePlanLimits');
    });

    test('exposes correct refreshCustomClaims callable name', () {
      expect(FunctionsService.refreshCustomClaims, 'refreshCustomClaims');
    });
  });
}
