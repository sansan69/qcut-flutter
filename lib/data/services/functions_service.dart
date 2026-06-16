import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  final FirebaseFunctions _functions;

  FunctionsService(this._functions);

  static const String helloWorld = 'helloWorld';
  static const String issueToken = 'issueToken';
  static const String callNextToken = 'callNextToken';
  static const String completeToken = 'completeToken';
  static const String noShowToken = 'noShowToken';
  static const String createBooking = 'createBooking';
  static const String cancelBooking = 'cancelBooking';
  static const String convertBookingToToken = 'convertBookingToToken';
  static const String enforcePlanLimits = 'enforcePlanLimits';
  static const String refreshCustomClaims = 'refreshCustomClaims';

  Future<Map<String, dynamic>> call(String name, Map<String, dynamic> params) async {
    final callable = _functions.httpsCallable(name);
    final result = await callable.call(params);
    return result.data as Map<String, dynamic>;
  }
}
