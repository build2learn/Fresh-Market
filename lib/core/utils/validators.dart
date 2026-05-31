abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final number = double.tryParse(value);
    if (number == null) return '$fieldName must be a number';
    if (number <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  static String? nonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final number = double.tryParse(value);
    if (number == null) return '$fieldName must be a number';
    if (number < 0) return '$fieldName must not be negative';
    return null;
  }
}
