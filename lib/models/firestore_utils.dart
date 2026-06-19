/// Coerces Firestore numeric types (int/double/num) into a nullable double.
double? toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return null;
}

/// Coerces Firestore numeric types into an int (truncates doubles).
int toInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return fallback;
}
