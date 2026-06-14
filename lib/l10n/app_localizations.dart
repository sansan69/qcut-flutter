import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'Q - CUT',
      'dashboard': 'Dashboard',
      'queue': 'Queue',
      'customers': 'Customers',
      'reports': 'Reports',
      'now_serving': 'Now Serving',
      'waiting_queue': 'Waiting Queue',
      'completed_today': 'Completed Today',
      'call_next': 'Call Next Token',
      'complete': 'Complete',
      'no_show': 'No Show',
      'cancel': 'Cancel',
      'queue_empty': 'Queue is empty.',
      'no_tokens_serving': 'No tokens currently being served.',
      'no_completed': 'No completed tokens yet.',
      'staff': 'Staff',
      'bookings': 'Bookings',
      'settings': 'Settings',
      'token_queue': 'Token Queue',
      'quick_actions': 'Quick Actions',
      'waiting_count': '{} waiting',
      'serving': 'SERVING',
    },
    'ml': {
      'app_title': 'ക്യൂ - കട്ട്',
      'dashboard': 'ഡാഷ്ബോർഡ്',
      'queue': 'ക്യൂ',
      'customers': 'ഉപഭോക്താക്കൾ',
      'reports': 'റിപ്പോർട്ടുകൾ',
      'now_serving': 'ഇപ്പോൾ സേവനം',
      'waiting_queue': 'കാത്തിരിപ്പ് ക്യൂ',
      'completed_today': 'ഇന്ന് പൂർത്തിയായവ',
      'call_next': 'അടുത്ത ടോക്കൺ വിളിക്കുക',
      'complete': 'പൂർത്തിയാക്കുക',
      'no_show': 'ഹാജരായില്ല',
      'cancel': 'റദ്ദാക്കുക',
      'queue_empty': 'ക്യൂ ശൂന്യമാണ്.',
      'no_tokens_serving': 'നിലവിൽ ടോക്കണുകളൊന്നും സേവനത്തിലില്ല.',
      'no_completed': 'ഇതുവരെ പൂർത്തിയായ ടോക്കണുകളില്ല.',
      'staff': 'സ്റ്റാഫ്',
      'bookings': 'ബുക്കിംഗുകൾ',
      'settings': 'ക്രമീകരണങ്ങൾ',
      'token_queue': 'ടോക്കൺ ക്യൂ',
      'quick_actions': 'ദ്രുത പ്രവർത്തനങ്ങൾ',
      'waiting_count': '{} കാത്തിരിക്കുന്നു',
      'serving': 'സേവനത്തിൽ',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]?['app_title'] ?? 'Q - CUT';
  String get dashboard => _localizedValues[locale.languageCode]?['dashboard'] ?? 'Dashboard';
  String get queue => _localizedValues[locale.languageCode]?['queue'] ?? 'Queue';
  String get customers => _localizedValues[locale.languageCode]?['customers'] ?? 'Customers';
  String get reports => _localizedValues[locale.languageCode]?['reports'] ?? 'Reports';
  String get nowServing => _localizedValues[locale.languageCode]?['now_serving'] ?? 'Now Serving';
  String get waitingQueue => _localizedValues[locale.languageCode]?['waiting_queue'] ?? 'Waiting Queue';
  String get completedToday => _localizedValues[locale.languageCode]?['completed_today'] ?? 'Completed Today';
  String get callNext => _localizedValues[locale.languageCode]?['call_next'] ?? 'Call Next Token';
  String get complete => _localizedValues[locale.languageCode]?['complete'] ?? 'Complete';
  String get noShow => _localizedValues[locale.languageCode]?['no_show'] ?? 'No Show';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get queueEmpty => _localizedValues[locale.languageCode]?['queue_empty'] ?? 'Queue is empty.';
  String get noTokensServing => _localizedValues[locale.languageCode]?['no_tokens_serving'] ?? 'No tokens currently being served.';
  String get noCompleted => _localizedValues[locale.languageCode]?['no_completed'] ?? 'No completed tokens yet.';
  String get staff => _localizedValues[locale.languageCode]?['staff'] ?? 'Staff';
  String get bookings => _localizedValues[locale.languageCode]?['bookings'] ?? 'Bookings';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get tokenQueue => _localizedValues[locale.languageCode]?['token_queue'] ?? 'Token Queue';
  String get quickActions => _localizedValues[locale.languageCode]?['quick_actions'] ?? 'Quick Actions';
  String waitingCount(int n) => (_localizedValues[locale.languageCode]?['waiting_count'] ?? '{} waiting').replaceAll('{}', n.toString());
  String get serving => _localizedValues[locale.languageCode]?['serving'] ?? 'SERVING';

  static const delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ml'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
