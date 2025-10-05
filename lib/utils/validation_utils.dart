// validation_utils.dart
import 'dart:core';

/// Utility class for form validation
class ValidationUtils {
  static const String _emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String _phonePattern = r'^\+?[1-9]\d{1,14}$';

  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(_emailPattern).hasMatch(email);
  }

  /// Validates phone number format (international format)
  static bool isValidPhone(String phone) {
    // Remove spaces, dashes, and parentheses for validation
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(_phonePattern).hasMatch(cleanedPhone);
  }

  /// Validates password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates name format
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates phone number format
  static String? validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String password, String confirmation) {
    if (confirmation.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    return null;
  }
}
