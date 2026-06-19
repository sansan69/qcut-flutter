/// Generates a URL-safe slug from a business name.
/// E.g. "My Barber Shop!" → "my-barber-shop"
String generateSlug(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

/// Base URL for the public booking page.
const qcutBookingBaseUrl = 'https://qcut.co.in';
