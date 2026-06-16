/// Onboarding constants + form data — from QCUT Kotlin OnboardingModels.kt
class OnboardingConstants {
  static const keralaDistricts = [
    'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam',
    'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta',
    'Thiruvananthapuram', 'Thrissur', 'Wayanad',
  ];

  static const businessTypes = [
    'Salon', 'Barbershop', 'Spa', 'Beauty Parlor', 'Clinic', 'Dental Clinic',
    'Physiotherapy Center', 'Diagnostic Center', 'Service Center', 'Repair Shop',
    'Consultation Office', 'Other',
  ];

  static const industryCategories = [
    'Beauty & Wellness', 'Healthcare', 'Professional Services',
    'Automotive', 'Technology', 'Other',
  ];

  static bool isGmail(String email) => email.toLowerCase().endsWith('@gmail.com');
  static bool isValidGST(String gst) => RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(gst);
  static bool isValidPAN(String pan) => RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan);
  static bool isValidAadhaar(String aadhaar) => RegExp(r'^\d{12}$').hasMatch(aadhaar.replaceAll(RegExp(r'\s'), ''));
}

class OnboardingFormData {
  String businessName = '';
  String businessType = '';
  String industryCategory = '';
  String gstNumber = '';
  String street = '';
  String district = '';
  String city = '';
  String state = 'Kerala';
  String pinCode = '';
  String businessPhone = '';
  String businessEmail = '';

  String ownerName = '';
  String ownerEmail = '';
  String ownerPhone = '';
  String password = ''; // For Firebase Auth account creation
  String confirmPassword = ''; // Must match password
  String aadhaarNumber = '';
  String panNumber = '';
  String referralCode = '';

  String staffCount = '';
  String openingTime = '09:00';
  String closingTime = '18:00';
  String expectedMonthlyBookings = '';
  String bookingMode = 'appointment';

  bool termsAccepted = false;
  bool privacyAccepted = false;
  bool dataProcessingConsent = false;

  Map<String, dynamic> toMap() => {
    'businessName': businessName,
    'businessType': businessType,
    'industryCategory': industryCategory,
    'gstNumber': gstNumber,
    'street': street,
    'district': district,
    'city': city,
    'state': state,
    'pinCode': pinCode,
    'businessPhone': businessPhone,
    'businessEmail': businessEmail,
    'ownerName': ownerName,
    'ownerEmail': ownerEmail,
    'ownerPhone': ownerPhone,
    'aadhaarNumber': aadhaarNumber,
    'panNumber': panNumber,
    'referralCode': referralCode,
    'staffCount': staffCount,
    'openingTime': openingTime,
    'closingTime': closingTime,
    'expectedMonthlyBookings': expectedMonthlyBookings,
    'bookingMode': bookingMode,
    'termsAccepted': termsAccepted,
    'privacyAccepted': privacyAccepted,
    'dataProcessingConsent': dataProcessingConsent,
  };
}
