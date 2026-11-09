class Validators {
  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Please enter $label.' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }

    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : 'Please enter a valid email address.';
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }
}
