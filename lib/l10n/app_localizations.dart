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
      'join_queue': 'Join Queue',
      'my_bookings': 'My Bookings',
      'select_barber': 'Select Barber',
      'your_name': 'Your Name',
      'phone_optional': 'Phone Number (optional)',
      'scan_qr': 'Scan shop QR code',
      'walk_in': 'Walk-in Registration',
      'token_issued': 'Token Issued',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'no_bookings': 'No bookings yet',
      'cancel_booking': 'Cancel Booking',
      'barber': 'Barber',
      'done': 'Done',
      'wait_estimate': '~15 min wait',
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
      'join_queue': 'ക്യൂവിൽ ചേരുക',
      'my_bookings': 'എൻ്റെ ബുക്കിംഗുകൾ',
      'select_barber': 'ബാർബർ തിരഞ്ഞെടുക്കുക',
      'your_name': 'നിങ്ങളുടെ പേര്',
      'phone_optional': 'ഫോൺ നമ്പർ (ഓപ്ഷണൽ)',
      'scan_qr': 'ഷോപ്പ് QR കോഡ് സ്കാൻ ചെയ്യുക',
      'walk_in': 'വാക്ക്-ഇൻ രജിസ്ട്രേഷൻ',
      'token_issued': 'ടോക്കൺ നൽകി',
      'upcoming': 'വരാനിരിക്കുന്നവ',
      'past': 'കഴിഞ്ഞവ',
      'no_bookings': 'ബുക്കിംഗുകളൊന്നുമില്ല',
      'cancel_booking': 'ബുക്കിംഗ് റദ്ദാക്കുക',
      'barber': 'ബാർബർ',
      'done': 'പൂർത്തിയായി',
      'wait_estimate': '~15 മിനിറ്റ് കാത്തിരിപ്പ്',
    },
  };

  String get appTitle => _t('app_title');
  String get dashboard => _t('dashboard');
  String get queue => _t('queue');
  String get customers => _t('customers');
  String get reports => _t('reports');
  String get nowServing => _t('now_serving');
  String get waitingQueue => _t('waiting_queue');
  String get completedToday => _t('completed_today');
  String get callNext => _t('call_next');
  String get complete => _t('complete');
  String get noShow => _t('no_show');
  String get cancel => _t('cancel');
  String get queueEmpty => _t('queue_empty');
  String get noTokensServing => _t('no_tokens_serving');
  String get noCompleted => _t('no_completed');
  String get staff => _t('staff');
  String get bookings => _t('bookings');
  String get settings => _t('settings');
  String get tokenQueue => _t('token_queue');
  String get quickActions => _t('quick_actions');
  String get joinQueue => _t('join_queue');
  String get myBookings => _t('my_bookings');
  String get selectBarber => _t('select_barber');
  String get yourName => _t('your_name');
  String get phoneOptional => _t('phone_optional');
  String get scanQr => _t('scan_qr');
  String get walkIn => _t('walk_in');
  String get tokenIssued => _t('token_issued');
  String get upcoming => _t('upcoming');
  String get past => _t('past');
  String get noBookings => _t('no_bookings');
  String get cancelBooking => _t('cancel_booking');
  String get barber => _t('barber');
  String get done => _t('done');
  String get waitEstimate => _t('wait_estimate');
  String waitingCount(int n) => _t('waiting_count').replaceAll('{}', n.toString());
  String get serving => _t('serving');

  String _t(String key) => _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;

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
