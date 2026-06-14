import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      // ── App / Brand ──
      'app_title': 'Q - CUT',
      'app_subtitle': 'CUT THE QUEUE',
      'tagline': 'Queue smart, work fast',
      'hero_title': 'Queue-less bookings for ',
      'hero_accent': 'modern businesses',
      'hero_desc': 'A sleek platform for token queues and smart appointment scheduling — fast to set up, delightful to use.',
      'copyright': '© 2025 Q-CUT. All rights reserved.',

      // ── Navigation ──
      'dashboard': 'Dashboard',
      'queue': 'Queue',
      'customers': 'Customers',
      'join': 'Join',
      'reports': 'Reports',

      // ── Landing ──
      'get_started': 'Get Started',
      'get_started_sub': 'Setup your business in seconds',
      'my_appointments': 'My Appointments',
      'my_appointments_sub': 'Find your booking',
      'smart_scheduling': 'Smart Scheduling',
      'smart_scheduling_desc': 'Book appointments that fit your schedule perfectly.',

      // ── Onboarding ──
      'join_qcut': 'Join Q-CUT',
      'step_business': 'Business',
      'step_owner': 'Owner',
      'step_operations': 'Operations',
      'step_review': 'Review',
      'business_info': 'Business Information',
      'business_name': 'Business Name *',
      'business_type': 'Business Type *',
      'industry': 'Industry *',
      'gst_number': 'GST Number (Optional)',
      'street_address': 'Street Address *',
      'district': 'District *',
      'city': 'City *',
      'pin_code': 'PIN Code *',
      'business_phone': 'Business Phone *',
      'business_email': 'Business Email (Gmail) *',
      'owner_info': 'Owner Information',
      'owner_name': 'Owner Name *',
      'owner_email': 'Owner Email (Gmail) *',
      'owner_phone': 'Owner Phone *',
      'pan_number': 'PAN Number (Optional)',
      'aadhaar': 'Aadhaar (Optional)',
      'referral_code': 'Referral Code (Optional)',
      'operations_details': 'Operational Details',
      'staff_count': 'Staff Count *',
      'opening_time': 'Opening Time',
      'closing_time': 'Closing Time',
      'expected_bookings': 'Expected Monthly Bookings',
      'booking_mode': 'Booking Mode',
      'appointment': 'Appointment',
      'token_queue': 'Token Queue',
      'review_submit': 'Review & Submit',
      'next': 'Next',
      'submit_application': 'Submit Application',
      'back_to_home': 'Back to Home',
      'reg_success_title': 'Registration Submitted!',
      'reg_success_msg': 'Thank you for registering. We\'ve sent a confirmation email. Our team will review your application within 24-48 hours.',
      'required': 'Required',
      'enter_6_digits': 'Enter 6 digits',
      'enter_10_digits': 'Enter 10 digits',
      'gmail_required': 'Gmail required',
      'terms_label': 'I accept the Terms & Conditions',
      'privacy_label': 'I accept the Privacy Policy',
      'data_consent_label': 'I consent to data processing',

      // ── Auth / Login ──
      'owner': 'Owner',
      'customer': 'Customer',
      'email': 'Email',
      'password': 'Password',
      'sign_in': 'Sign In',
      'create_account': 'Create Account',
      'already_account': 'Already have an account? Sign in',
      'new_shop': 'New shop? Register here',
      'your_name': 'Your Name',
      'phone_optional': 'Phone (optional)',
      'phone_future': 'For future notifications',
      'no_account_needed': 'No account needed. Just walk in and get your token.',
      'login_phone_otp': 'Login with Phone OTP',
      'phone_otp_coming': 'Phone OTP coming soon — requires verification setup',
      'sign_out': 'Sign out',
      'min_4_chars': 'Min 4 characters',
      'enter_valid_email': 'Enter a valid email',
      'enter_name': 'Please enter your name',
      'something_wrong': 'Something went wrong. Try again.',

      // ── Dashboard ──
      'waiting': 'Waiting',
      'serving': 'SERVING',
      'completed': 'Completed',
      'quick_actions': 'Quick Actions',
      'open_queue': 'Token Queue',
      'open_queue_sub': 'Now Serving / Waiting / Completed',
      'open_bookings': 'Bookings',
      'open_bookings_sub': 'Appointments & calendar',
      'open_staff': 'Staff',
      'open_staff_sub': 'Manage barbers & schedule',
      'open_reports': 'Reports',
      'open_reports_sub': 'Daily stats & analytics',

      // ── Token Queue ──
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
      'waiting_count': '{} waiting',
      'wait_estimate': '~15 min wait',

      // ── Staff ──
      'staff': 'Staff',
      'add_barber': 'Add Barber',
      'barber_name': 'Barber Name',
      'add': 'Add',
      'remove_barber_title': 'Remove Barber?',
      'remove_barber_msg': 'Remove {} from the shop?',
      'remove': 'Remove',
      'active': 'Active',
      'inactive': 'Inactive',
      'no_barbers': 'No barbers added',
      'tap_add_first': 'Tap + to add your first barber',

      // ── Settings ──
      'settings': 'Settings',
      'shop_settings': 'Shop Settings',
      'general': 'General',
      'services': 'Services',
      'payments': 'Payments',
      'shop_details': 'Shop Details',
      'shop_name': 'Shop Name',
      'address': 'Address',
      'mode_token': 'TOKEN QUEUE',
      'mode_appointment': 'APPOINTMENT',
      'booking_link_label': 'Booking Link',
      'token_queue_hours': 'Token Queue Hours',
      'open': 'Open',
      'close': 'Close',
      'add_service': 'Add Service',
      'service_name': 'Service Name',
      'price_label': 'Price (₹)',
      'duration_label': 'Duration (min)',
      'no_services': 'No services. Tap + to add.',
      'upi_details': 'UPI Payment Details',
      'upi_id': 'UPI ID',
      'upi_phone': 'UPI Phone',
      'save_all': 'Save All Changes',
      'saved_ok': 'Settings saved successfully',
      'qr_code': 'QR Code',
      'view_qr': 'View Shop QR',

      // ── Booking ──
      'bookings': 'Bookings',
      'my_bookings': 'My Bookings',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'no_bookings': 'No bookings yet',
      'cancel_booking': 'Cancel Booking',
      'barber': 'Barber',
      'new_booking': 'New Booking',
      'book_shop_title': 'Book — {}',
      'select_service': 'Select a Service',
      'select_service_sub': 'Choose what you\'d like to book',
      'pick_date': 'Pick a Date',
      'pick_date_sub': 'Available dates (Mon–Sat)',
      'today': 'Today',
      'pick_time': 'Pick a Time',
      'pick_time_sub': '30-minute slots from 9:00 AM to 9:00 PM',
      'choose_barber': 'Choose Your Barber',
      'choose_barber_sub': 'Select who you\'d like',
      'your_details': 'Your Details',
      'your_details_sub': 'We\'ll save these for your booking',
      'full_name': 'Full Name *',
      'phone_number': 'Phone Number',
      'booking_summary': 'Booking Summary',
      'booking_summary_sub': 'Review and confirm your appointment',
      'service': 'Service',
      'date': 'Date',
      'time': 'Time',
      'duration': 'Duration',
      'confirm_booking': 'Confirm Booking',
      'booking_confirmed': 'Appointment Booked!',
      'code': 'Code',
      'complete_all': 'Please complete all selections',

      // ── QR ──
      'shop_qr': 'Shop QR Code',
      'scan_to_book': 'Scan to book',
      'share_link': 'Share Link',
      'copy_link': 'Copy Link',
      'link_copied': 'Booking link copied!',
      'print_tip': 'Print this QR code and display at your shop counter for customers to scan and book.',
      'book_with_shop': 'Book with {} — {}',

      // ── Join Queue ──
      'join_queue': 'Join Queue',
      'select_barber': 'Select Barber',
      'scan_qr': 'Scan shop QR code',
      'or': 'OR',
      'walk_in': 'Walk-in Registration',
      'token_issued': 'Token Issued',
      'token_num': 'Token #',
      'done': 'Done',
      'no_barbers_avail': 'No barbers available',
      'name_required': 'Name is required',

      // ── Reports ──
      'today_stats': 'Today',
      'served': 'Served',
      'no_shows': 'No-Shows',
      'rate': 'Rate',
      'status_breakdown': 'Status Breakdown',
      'no_show_status': 'No-Show',
      'cancelled_status': 'Cancelled',
      'bookings_done': 'Bookings Done',
      'last_7_days': 'Last 7 Days',
      'tokens_per_day': 'Tokens Per Day',
      'estimated_revenue': 'Estimated Revenue',
      'this_week': 'This Week',
      'avg_day': 'Avg/Day',
      'avg_ticket_note': '*Based on ₹150 avg ticket size',

      // ── Customers ──
      'search_customers': 'Search customers...',
      'total': 'Total',
      'visits': 'visits',
      'no_shows_short': 'no-shows',
      'no_customer_history': 'No customer history yet',
      'no_customers_match': 'No customers match',
      'preferred_barbers': 'Preferred Barbers',
      'customer_name_label': 'Customer',
      'ns_tag': 'NS',
    },
    'ml': {
      // ── App / Brand ──
      'app_title': 'ക്യൂ - കട്ട്',
      'app_subtitle': 'കട്ട് ദി ക്യൂ',
      'tagline': 'ക്യൂ സ്മാർട്ട്, വർക്ക് ഫാസ്റ്റ്',
      'hero_title': 'ആധുനിക ബിസിനസുകൾക്കായി ',
      'hero_accent': 'ക്യൂ ഇല്ലാത്ത ബുക്കിംഗുകൾ',
      'hero_desc': 'ടോക്കൺ ക്യൂകൾക്കും സ്മാർട്ട് അപ്പോയിന്റ്മെന്റ് ഷെഡ്യൂളിംഗിനുമുള്ള ഒരു മികച്ച പ്ലാറ്റ്ഫോം — സജ്ജീകരിക്കാൻ വേഗം, ഉപയോഗിക്കാൻ സുഖം.',
      'copyright': '© 2025 Q-CUT. എല്ലാ അവകാശങ്ങളും നിക്ഷിപ്തം.',

      // ── Navigation ──
      'dashboard': 'ഡാഷ്ബോർഡ്',
      'queue': 'ക്യൂ',
      'customers': 'ഉപഭോക്താക്കൾ',
      'join': 'ചേരുക',
      'reports': 'റിപ്പോർട്ടുകൾ',

      // ── Landing ──
      'get_started': 'ആരംഭിക്കുക',
      'get_started_sub': 'നിമിഷങ്ങൾക്കുള്ളിൽ നിങ്ങളുടെ ബിസിനസ് സജ്ജമാക്കുക',
      'my_appointments': 'എന്റെ ബുക്കിംഗുകൾ',
      'my_appointments_sub': 'നിങ്ങളുടെ ബുക്കിംഗ് കണ്ടെത്തുക',
      'smart_scheduling': 'സ്മാർട്ട് ഷെഡ്യൂളിംഗ്',
      'smart_scheduling_desc': 'നിങ്ങളുടെ ഷെഡ്യൂളിന് അനുയോജ്യമായ അപ്പോയിന്റ്മെന്റുകൾ ബുക്ക് ചെയ്യുക.',

      // ── Onboarding ──
      'join_qcut': 'ക്യൂ-കട്ടിൽ ചേരുക',
      'step_business': 'ബിസിനസ്',
      'step_owner': 'ഉടമ',
      'step_operations': 'പ്രവർത്തനം',
      'step_review': 'അവലോകനം',
      'business_info': 'ബിസിനസ് വിവരങ്ങൾ',
      'business_name': 'ബിസിനസ് പേര് *',
      'business_type': 'ബിസിനസ് തരം *',
      'industry': 'വ്യവസായം *',
      'gst_number': 'GST നമ്പർ (ഓപ്ഷണൽ)',
      'street_address': 'തെരുവ് വിലാസം *',
      'district': 'ജില്ല *',
      'city': 'നഗരം *',
      'pin_code': 'പിൻ കോഡ് *',
      'business_phone': 'ബിസിനസ് ഫോൺ *',
      'business_email': 'ബിസിനസ് ഇമെയിൽ (Gmail) *',
      'owner_info': 'ഉടമ വിവരങ്ങൾ',
      'owner_name': 'ഉടമയുടെ പേര് *',
      'owner_email': 'ഉടമ ഇമെയിൽ (Gmail) *',
      'owner_phone': 'ഉടമ ഫോൺ *',
      'pan_number': 'PAN നമ്പർ (ഓപ്ഷണൽ)',
      'aadhaar': 'ആധാർ (ഓപ്ഷണൽ)',
      'referral_code': 'റഫറൽ കോഡ് (ഓപ്ഷണൽ)',
      'operations_details': 'പ്രവർത്തന വിശദാംശങ്ങൾ',
      'staff_count': 'സ്റ്റാഫ് എണ്ണം *',
      'opening_time': 'തുറക്കുന്ന സമയം',
      'closing_time': 'അടയ്ക്കുന്ന സമയം',
      'expected_bookings': 'പ്രതീക്ഷിക്കുന്ന പ്രതിമാസ ബുക്കിംഗുകൾ',
      'booking_mode': 'ബുക്കിംഗ് മോഡ്',
      'appointment': 'അപ്പോയിന്റ്മെന്റ്',
      'token_queue': 'ടോക്കൺ ക്യൂ',
      'review_submit': 'അവലോകനം & സമർപ്പിക്കുക',
      'next': 'അടുത്തത്',
      'submit_application': 'അപേക്ഷ സമർപ്പിക്കുക',
      'back_to_home': 'ഹോമിലേക്ക്',
      'reg_success_title': 'രജിസ്ട്രേഷൻ സമർപ്പിച്ചു!',
      'reg_success_msg': 'രജിസ്റ്റർ ചെയ്തതിന് നന്ദി. ഞങ്ങൾ ഒരു സ്ഥിരീകരണ ഇമെയിൽ അയച്ചിട്ടുണ്ട്. 24-48 മണിക്കൂറിനുള്ളിൽ ഞങ്ങളുടെ ടീം നിങ്ങളുടെ അപേക്ഷ അവലോകനം ചെയ്യും.',
      'required': 'ആവശ്യമാണ്',
      'enter_6_digits': '6 അക്കങ്ങൾ നൽകുക',
      'enter_10_digits': '10 അക്കങ്ങൾ നൽകുക',
      'gmail_required': 'Gmail ആവശ്യമാണ്',
      'terms_label': 'ഞാൻ നിബന്ധനകളും വ്യവസ്ഥകളും അംഗീകരിക്കുന്നു',
      'privacy_label': 'ഞാൻ സ്വകാര്യതാ നയം അംഗീകരിക്കുന്നു',
      'data_consent_label': 'ഡാറ്റ പ്രോസസ്സിംഗിന് ഞാൻ സമ്മതിക്കുന്നു',

      // ── Auth / Login ──
      'owner': 'ഉടമ',
      'customer': 'ഉപഭോക്താവ്',
      'email': 'ഇമെയിൽ',
      'password': 'പാസ്‌വേഡ്',
      'sign_in': 'സൈൻ ഇൻ',
      'create_account': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
      'already_account': 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ? സൈൻ ഇൻ',
      'new_shop': 'പുതിയ കടയാണോ? രജിസ്റ്റർ ചെയ്യുക',
      'your_name': 'നിങ്ങളുടെ പേര്',
      'phone_optional': 'ഫോൺ (ഓപ്ഷണൽ)',
      'phone_future': 'ഭാവി അറിയിപ്പുകൾക്കായി',
      'no_account_needed': 'അക്കൗണ്ട് ആവശ്യമില്ല. വന്ന് ടോക്കൺ എടുക്കൂ.',
      'login_phone_otp': 'ഫോൺ OTP ഉപയോഗിച്ച് ലോഗിൻ',
      'phone_otp_coming': 'ഫോൺ OTP ഉടൻ വരുന്നു — വെരിഫിക്കേഷൻ സജ്ജീകരണം ആവശ്യമാണ്',
      'sign_out': 'സൈൻ ഔട്ട്',
      'min_4_chars': 'കുറഞ്ഞത് 4 പ്രതീകങ്ങൾ',
      'enter_valid_email': 'സാധുവായ ഇമെയിൽ നൽകുക',
      'enter_name': 'ദയവായി നിങ്ങളുടെ പേര് നൽകുക',
      'something_wrong': 'എന്തോ തെറ്റ് സംഭവിച്ചു. വീണ്ടും ശ്രമിക്കുക.',

      // ── Dashboard ──
      'waiting': 'കാത്തിരിപ്പ്',
      'serving': 'സേവനത്തിൽ',
      'completed': 'പൂർത്തിയായി',
      'quick_actions': 'ദ്രുത പ്രവർത്തനങ്ങൾ',
      'open_queue': 'ടോക്കൺ ക്യൂ',
      'open_queue_sub': 'ഇപ്പോൾ സേവനം / കാത്തിരിപ്പ് / പൂർത്തിയായവ',
      'open_bookings': 'ബുക്കിംഗുകൾ',
      'open_bookings_sub': 'അപ്പോയിന്റ്മെന്റുകളും കലണ്ടറും',
      'open_staff': 'സ്റ്റാഫ്',
      'open_staff_sub': 'ബാർബർമാരും ഷെഡ്യൂളും നിയന്ത്രിക്കുക',
      'open_reports': 'റിപ്പോർട്ടുകൾ',
      'open_reports_sub': 'ദൈനംദിന സ്ഥിതിവിവരക്കണക്കുകൾ',

      // ── Token Queue ──
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
      'waiting_count': '{} കാത്തിരിക്കുന്നു',
      'wait_estimate': '~15 മിനിറ്റ് കാത്തിരിപ്പ്',

      // ── Staff ──
      'staff': 'സ്റ്റാഫ്',
      'add_barber': 'ബാർബർ ചേർക്കുക',
      'barber_name': 'ബാർബറുടെ പേര്',
      'add': 'ചേർക്കുക',
      'remove_barber_title': 'ബാർബറെ നീക്കം ചെയ്യണോ?',
      'remove_barber_msg': '{} ഷോപ്പിൽ നിന്ന് നീക്കം ചെയ്യണോ?',
      'remove': 'നീക്കം ചെയ്യുക',
      'active': 'സജീവം',
      'inactive': 'നിഷ്ക്രിയം',
      'no_barbers': 'ബാർബർമാരെ ചേർത്തിട്ടില്ല',
      'tap_add_first': 'ആദ്യ ബാർബറെ ചേർക്കാൻ + ടാപ്പ് ചെയ്യുക',

      // ── Settings ──
      'settings': 'ക്രമീകരണങ്ങൾ',
      'shop_settings': 'ഷോപ്പ് ക്രമീകരണങ്ങൾ',
      'general': 'പൊതുവായ',
      'services': 'സേവനങ്ങൾ',
      'payments': 'പേയ്‌മെന്റുകൾ',
      'shop_details': 'ഷോപ്പ് വിശദാംശങ്ങൾ',
      'shop_name': 'ഷോപ്പിന്റെ പേര്',
      'address': 'വിലാസം',
      'mode_token': 'ടോക്കൺ ക്യൂ',
      'mode_appointment': 'അപ്പോയിന്റ്മെന്റ്',
      'booking_link_label': 'ബുക്കിംഗ് ലിങ്ക്',
      'token_queue_hours': 'ടോക്കൺ ക്യൂ സമയം',
      'open': 'തുറക്കുക',
      'close': 'അടയ്ക്കുക',
      'add_service': 'സേവനം ചേർക്കുക',
      'service_name': 'സേവനത്തിന്റെ പേര്',
      'price_label': 'വില (₹)',
      'duration_label': 'ദൈർഘ്യം (മിനിറ്റ്)',
      'no_services': 'സേവനങ്ങളൊന്നുമില്ല. ചേർക്കാൻ + ടാപ്പ് ചെയ്യുക.',
      'upi_details': 'UPI പേയ്‌മെന്റ് വിശദാംശങ്ങൾ',
      'upi_id': 'UPI ID',
      'upi_phone': 'UPI ഫോൺ',
      'save_all': 'എല്ലാ മാറ്റങ്ങളും സംരക്ഷിക്കുക',
      'saved_ok': 'ക്രമീകരണങ്ങൾ വിജയകരമായി സംരക്ഷിച്ചു',
      'qr_code': 'QR കോഡ്',
      'view_qr': 'ഷോപ്പ് QR കാണുക',

      // ── Booking ──
      'bookings': 'ബുക്കിംഗുകൾ',
      'my_bookings': 'എന്റെ ബുക്കിംഗുകൾ',
      'upcoming': 'വരാനിരിക്കുന്നവ',
      'past': 'കഴിഞ്ഞവ',
      'no_bookings': 'ബുക്കിംഗുകളൊന്നുമില്ല',
      'cancel_booking': 'ബുക്കിംഗ് റദ്ദാക്കുക',
      'barber': 'ബാർബർ',
      'new_booking': 'പുതിയ ബുക്കിംഗ്',
      'book_shop_title': 'ബുക്ക് — {}',
      'select_service': 'ഒരു സേവനം തിരഞ്ഞെടുക്കുക',
      'select_service_sub': 'എന്താണ് ബുക്ക് ചെയ്യാൻ ആഗ്രഹിക്കുന്നത്',
      'pick_date': 'തീയതി തിരഞ്ഞെടുക്കുക',
      'pick_date_sub': 'ലഭ്യമായ തീയതികൾ (തിങ്കൾ–ശനി)',
      'today': 'ഇന്ന്',
      'pick_time': 'സമയം തിരഞ്ഞെടുക്കുക',
      'pick_time_sub': 'രാവിലെ 9:00 മുതൽ രാത്രി 9:00 വരെ 30 മിനിറ്റ് സ്ലോട്ടുകൾ',
      'choose_barber': 'നിങ്ങളുടെ ബാർബർ തിരഞ്ഞെടുക്കുക',
      'choose_barber_sub': 'ആരെയാണ് ഇഷ്ടപ്പെടുന്നത്',
      'your_details': 'നിങ്ങളുടെ വിശദാംശങ്ങൾ',
      'your_details_sub': 'ബുക്കിംഗിനായി ഇവ സംരക്ഷിക്കും',
      'full_name': 'മുഴുവൻ പേര് *',
      'phone_number': 'ഫോൺ നമ്പർ',
      'booking_summary': 'ബുക്കിംഗ് സംഗ്രഹം',
      'booking_summary_sub': 'നിങ്ങളുടെ അപ്പോയിന്റ്മെന്റ് അവലോകനം ചെയ്ത് സ്ഥിരീകരിക്കുക',
      'service': 'സേവനം',
      'date': 'തീയതി',
      'time': 'സമയം',
      'duration': 'ദൈർഘ്യം',
      'confirm_booking': 'ബുക്കിംഗ് സ്ഥിരീകരിക്കുക',
      'booking_confirmed': 'അപ്പോയിന്റ്മെന്റ് ബുക്ക് ചെയ്തു!',
      'code': 'കോഡ്',
      'complete_all': 'ദയവായി എല്ലാ തിരഞ്ഞെടുപ്പുകളും പൂർത്തിയാക്കുക',

      // ── QR ──
      'shop_qr': 'ഷോപ്പ് QR കോഡ്',
      'scan_to_book': 'ബുക്ക് ചെയ്യാൻ സ്കാൻ ചെയ്യുക',
      'share_link': 'ലിങ്ക് ഷെയർ ചെയ്യുക',
      'copy_link': 'ലിങ്ക് കോപ്പി ചെയ്യുക',
      'link_copied': 'ബുക്കിംഗ് ലിങ്ക് കോപ്പി ചെയ്തു!',
      'print_tip': 'ഉപഭോക്താക്കൾക്ക് സ്കാൻ ചെയ്ത് ബുക്ക് ചെയ്യാൻ ഈ QR കോഡ് പ്രിന്റ് ചെയ്ത് ഷോപ്പ് കൗണ്ടറിൽ പ്രദർശിപ്പിക്കുക.',
      'book_with_shop': '{} ഉപയോഗിച്ച് ബുക്ക് ചെയ്യുക — {}',

      // ── Join Queue ──
      'join_queue': 'ക്യൂവിൽ ചേരുക',
      'select_barber': 'ബാർബർ തിരഞ്ഞെടുക്കുക',
      'scan_qr': 'ഷോപ്പ് QR കോഡ് സ്കാൻ ചെയ്യുക',
      'or': 'അല്ലെങ്കിൽ',
      'walk_in': 'വാക്ക്-ഇൻ രജിസ്ട്രേഷൻ',
      'token_issued': 'ടോക്കൺ നൽകി',
      'token_num': 'ടോക്കൺ #',
      'done': 'പൂർത്തിയായി',
      'no_barbers_avail': 'ബാർബർമാർ ലഭ്യമല്ല',
      'name_required': 'പേര് ആവശ്യമാണ്',

      // ── Reports ──
      'today_stats': 'ഇന്ന്',
      'served': 'സേവനം നൽകി',
      'no_shows': 'ഹാജരായില്ല',
      'rate': 'നിരക്ക്',
      'status_breakdown': 'സ്റ്റാറ്റസ് വിശകലനം',
      'no_show_status': 'ഹാജരായില്ല',
      'cancelled_status': 'റദ്ദാക്കി',
      'bookings_done': 'ബുക്കിംഗുകൾ പൂർത്തിയായി',
      'last_7_days': 'കഴിഞ്ഞ 7 ദിവസം',
      'tokens_per_day': 'പ്രതിദിന ടോക്കണുകൾ',
      'estimated_revenue': 'കണക്കാക്കിയ വരുമാനം',
      'this_week': 'ഈ ആഴ്ച',
      'avg_day': 'ശരാശരി/ദിവസം',
      'avg_ticket_note': '*₹150 ശരാശരി ടിക്കറ്റ് വലുപ്പം അടിസ്ഥാനമാക്കി',

      // ── Customers ──
      'search_customers': 'ഉപഭോക്താക്കളെ തിരയുക...',
      'total': 'ആകെ',
      'visits': 'സന്ദർശനങ്ങൾ',
      'no_shows_short': 'ഹാജരാകാത്തവ',
      'no_customer_history': 'ഇതുവരെ ഉപഭോക്തൃ ചരിത്രമില്ല',
      'no_customers_match': 'ഉപഭോക്താക്കളുമായി പൊരുത്തമില്ല',
      'preferred_barbers': 'ഇഷ്ടപ്പെട്ട ബാർബർമാർ',
      'customer_name_label': 'ഉപഭോക്താവ്',
      'ns_tag': 'NS',
    },
  };

  String get appTitle => _t('app_title');
  String get appSubtitle => _t('app_subtitle');
  String get tagline => _t('tagline');
  String get heroTitle => _t('hero_title');
  String get heroAccent => _t('hero_accent');
  String get heroDesc => _t('hero_desc');
  String get copyright => _t('copyright');
  String get dashboard => _t('dashboard');
  String get queue => _t('queue');
  String get customers => _t('customers');
  String get join => _t('join');
  String get reports => _t('reports');
  String get getStarted => _t('get_started');
  String get getStartedSub => _t('get_started_sub');
  String get myAppointments => _t('my_appointments');
  String get myAppointmentsSub => _t('my_appointments_sub');
  String get smartScheduling => _t('smart_scheduling');
  String get smartSchedulingDesc => _t('smart_scheduling_desc');
  String get joinQcut => _t('join_qcut');
  String get stepBusiness => _t('step_business');
  String get stepOwner => _t('step_owner');
  String get stepOperations => _t('step_operations');
  String get stepReview => _t('step_review');
  String get businessInfo => _t('business_info');
  String get businessName => _t('business_name');
  String get businessType => _t('business_type');
  String get industry => _t('industry');
  String get gstNumber => _t('gst_number');
  String get streetAddress => _t('street_address');
  String get district => _t('district');
  String get city => _t('city');
  String get pinCode => _t('pin_code');
  String get businessPhone => _t('business_phone');
  String get businessEmail => _t('business_email');
  String get ownerInfo => _t('owner_info');
  String get ownerName => _t('owner_name');
  String get ownerEmail => _t('owner_email');
  String get ownerPhone => _t('owner_phone');
  String get panNumber => _t('pan_number');
  String get aadhaar => _t('aadhaar');
  String get referralCode => _t('referral_code');
  String get operationsDetails => _t('operations_details');
  String get staffCount => _t('staff_count');
  String get openingTime => _t('opening_time');
  String get closingTime => _t('closing_time');
  String get expectedBookings => _t('expected_bookings');
  String get bookingMode => _t('booking_mode');
  String get appointment => _t('appointment');
  String get tokenQueue => _t('token_queue');
  String get reviewSubmit => _t('review_submit');
  String get next => _t('next');
  String get submitApplication => _t('submit_application');
  String get backToHome => _t('back_to_home');
  String get regSuccessTitle => _t('reg_success_title');
  String get regSuccessMsg => _t('reg_success_msg');
  String get requiredField => _t('required');
  String get enter6Digits => _t('enter_6_digits');
  String get enter10Digits => _t('enter_10_digits');
  String get gmailRequired => _t('gmail_required');
  String get termsLabel => _t('terms_label');
  String get privacyLabel => _t('privacy_label');
  String get dataConsentLabel => _t('data_consent_label');
  String get owner => _t('owner');
  String get customerRole => _t('customer');
  String get email => _t('email');
  String get password => _t('password');
  String get signIn => _t('sign_in');
  String get createAccount => _t('create_account');
  String get alreadyAccount => _t('already_account');
  String get newShop => _t('new_shop');
  String get yourName => _t('your_name');
  String get phoneOptional => _t('phone_optional');
  String get phoneFuture => _t('phone_future');
  String get noAccountNeeded => _t('no_account_needed');
  String get loginPhoneOtp => _t('login_phone_otp');
  String get phoneOtpComing => _t('phone_otp_coming');
  String get signOut => _t('sign_out');
  String get min4Chars => _t('min_4_chars');
  String get enterValidEmail => _t('enter_valid_email');
  String get enterName => _t('enter_name');
  String get somethingWrong => _t('something_wrong');
  String get waiting => _t('waiting');
  String get serving => _t('serving');
  String get completed => _t('completed');
  String get quickActions => _t('quick_actions');
  String get openQueue => _t('open_queue');
  String get openQueueSub => _t('open_queue_sub');
  String get openBookings => _t('open_bookings');
  String get openBookingsSub => _t('open_bookings_sub');
  String get openStaff => _t('open_staff');
  String get openStaffSub => _t('open_staff_sub');
  String get openReports => _t('open_reports');
  String get openReportsSub => _t('open_reports_sub');
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
  String get addBarber => _t('add_barber');
  String get barberName => _t('barber_name');
  String get add => _t('add');
  String get removeBarberTitle => _t('remove_barber_title');
  String get removeBarberMsg => _t('remove_barber_msg');
  String get remove => _t('remove');
  String get active => _t('active');
  String get inactive => _t('inactive');
  String get noBarbers => _t('no_barbers');
  String get tapAddFirst => _t('tap_add_first');
  String get settings => _t('settings');
  String get shopSettings => _t('shop_settings');
  String get general => _t('general');
  String get services => _t('services');
  String get payments => _t('payments');
  String get shopDetails => _t('shop_details');
  String get shopName => _t('shop_name');
  String get address => _t('address');
  String get modeToken => _t('mode_token');
  String get modeAppointment => _t('mode_appointment');
  String get bookingLinkLabel => _t('booking_link_label');
  String get tokenQueueHours => _t('token_queue_hours');
  String get open => _t('open');
  String get close => _t('close');
  String get addService => _t('add_service');
  String get serviceName => _t('service_name');
  String get priceLabel => _t('price_label');
  String get durationLabel => _t('duration_label');
  String get noServices => _t('no_services');
  String get upiDetails => _t('upi_details');
  String get upiId => _t('upi_id');
  String get upiPhone => _t('upi_phone');
  String get saveAll => _t('save_all');
  String get savedOk => _t('saved_ok');
  String get qrCode => _t('qr_code');
  String get viewQr => _t('view_qr');
  String get bookings => _t('bookings');
  String get myBookings => _t('my_bookings');
  String get upcoming => _t('upcoming');
  String get past => _t('past');
  String get noBookings => _t('no_bookings');
  String get cancelBooking => _t('cancel_booking');
  String get barber => _t('barber');
  String get newBooking => _t('new_booking');
  String get bookShopTitle => _t('book_shop_title');
  String get selectService => _t('select_service');
  String get selectServiceSub => _t('select_service_sub');
  String get pickDate => _t('pick_date');
  String get pickDateSub => _t('pick_date_sub');
  String get today => _t('today');
  String get pickTime => _t('pick_time');
  String get pickTimeSub => _t('pick_time_sub');
  String get chooseBarber => _t('choose_barber');
  String get chooseBarberSub => _t('choose_barber_sub');
  String get yourDetails => _t('your_details');
  String get yourDetailsSub => _t('your_details_sub');
  String get fullName => _t('full_name');
  String get phoneNumber => _t('phone_number');
  String get bookingSummary => _t('booking_summary');
  String get bookingSummarySub => _t('booking_summary_sub');
  String get service => _t('service');
  String get date => _t('date');
  String get time => _t('time');
  String get duration => _t('duration');
  String get confirmBooking => _t('confirm_booking');
  String get bookingConfirmed => _t('booking_confirmed');
  String get code => _t('code');
  String get completeAll => _t('complete_all');
  String get shopQr => _t('shop_qr');
  String get scanToBook => _t('scan_to_book');
  String get shareLink => _t('share_link');
  String get copyLink => _t('copy_link');
  String get linkCopied => _t('link_copied');
  String get printTip => _t('print_tip');
  String get bookWithShop => _t('book_with_shop');
  String get joinQueue => _t('join_queue');
  String get selectBarber => _t('select_barber');
  String get scanQr => _t('scan_qr');
  String get orLabel => _t('or');
  String get walkIn => _t('walk_in');
  String get tokenIssued => _t('token_issued');
  String get tokenNum => _t('token_num');
  String get done => _t('done');
  String get noBarbersAvail => _t('no_barbers_avail');
  String get nameRequired => _t('name_required');
  String get todayStats => _t('today_stats');
  String get served => _t('served');
  String get noShows => _t('no_shows');
  String get rateLabel => _t('rate');
  String get statusBreakdown => _t('status_breakdown');
  String get noShowStatus => _t('no_show_status');
  String get cancelledStatus => _t('cancelled_status');
  String get bookingsDone => _t('bookings_done');
  String get last7Days => _t('last_7_days');
  String get tokensPerDay => _t('tokens_per_day');
  String get estimatedRevenue => _t('estimated_revenue');
  String get thisWeek => _t('this_week');
  String get avgDay => _t('avg_day');
  String get avgTicketNote => _t('avg_ticket_note');
  String get searchCustomers => _t('search_customers');
  String get total => _t('total');
  String get visits => _t('visits');
  String get noShowsShort => _t('no_shows_short');
  String get noCustomerHistory => _t('no_customer_history');
  String get noCustomersMatch => _t('no_customers_match');
  String get preferredBarbers => _t('preferred_barbers');
  String get customerNameLabel => _t('customer_name_label');
  String get nsTag => _t('ns_tag');

  // Parameterized getters
  String waitingCount(int n) => _t('waiting_count').replaceAll('{}', n.toString());
  String removeBarberMsgName(String name) => _t('remove_barber_msg').replaceAll('{}', name);
  String bookShopTitleName(String name) => _t('book_shop_title').replaceAll('{}', name);
  String bookWithShopMsg(String shop, String url) => _t('book_with_shop').replaceAll('{}', shop).replaceAll('{}', url);

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
