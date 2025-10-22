// auth_models.dart

// Registration Request Model
class SignupRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? companyName;
  final String? notes;

  SignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.companyName,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (companyName != null) 'company_name': companyName,
      if (notes != null) 'notes': notes,
    };
  }
}

// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Verify Email Request Model
class VerifyEmailRequest {
  final String email;
  final String otp;

  VerifyEmailRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

// Resend OTP Request Model
class ResendOtpRequest {
  final String email;

  ResendOtpRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Forgot Password Request Model
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Customer Model
class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final bool status;
  final bool? emailVerified;
  final String? emailVerifiedAt;
  final String createdAt;
  final String? profileImageUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    required this.status,
    this.emailVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    try {
      return Customer(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        companyName: json['company_name'],
        status: json['status'] ?? true,
        emailVerified: json['email_verified'],
        emailVerifiedAt: json['email_verified_at'],
        createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
        profileImageUrl: json['profile_image_url'],
      );
    } catch (e) {
      print('❌ Customer parsing error: $e');
      print('❌ Customer JSON data: $json');
      // Return a basic customer object
      return Customer(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        companyName: null,
        status: true,
        emailVerified: null,
        emailVerifiedAt: null,
        createdAt: DateTime.now().toIso8601String(),
        profileImageUrl: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company_name': companyName,
      'status': status,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'profile_image_url': profileImageUrl,
    };
  }
}

// Registration Response Model
class RegisterResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final bool? requiresVerification;
  final int? otpExpiresInMinutes;
  final Map<String, List<String>>? errors;

  RegisterResponse({
    required this.success,
    required this.message,
    this.customer,
    this.requiresVerification,
    this.otpExpiresInMinutes,
    this.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customer: json['data'] != null && json['data']['customer'] != null
          ? Customer.fromJson(json['data']['customer'])
          : null,
      requiresVerification: json['data']?['requires_verification'],
      otpExpiresInMinutes: json['data']?['otp_expires_in_minutes'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

// Verify Email Response Model
class VerifyEmailResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final String? token;
  final String? tokenType;
  final Map<String, List<String>>? errors;

  VerifyEmailResponse({
    required this.success,
    required this.message,
    this.customer,
    this.token,
    this.tokenType,
    this.errors,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    try {
      return VerifyEmailResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        customer: json['data'] != null && json['data']['customer'] != null
            ? Customer.fromJson(json['data']['customer'])
            : null,
        token: json['data']?['token'],
        tokenType: json['data']?['token_type'],
        errors: json['errors'] != null
            ? Map<String, List<String>>.from(
                json['errors'].map((key, value) =>
                    MapEntry(key, List<String>.from(value))))
            : null,
      );
    } catch (e) {
      print('❌ VerifyEmailResponse parsing error: $e');
      print('❌ JSON data: $json');
      // Return a basic response with the message
      return VerifyEmailResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Unknown error',
        customer: null,
        token: null,
        tokenType: null,
        errors: null,
      );
    }
  }
}

// Resend OTP Response Model
class ResendOtpResponse {
  final bool success;
  final String message;
  final int? otpExpiresInMinutes;
  final Map<String, List<String>>? errors;

  ResendOtpResponse({
    required this.success,
    required this.message,
    this.otpExpiresInMinutes,
    this.errors,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ResendOtpResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        otpExpiresInMinutes: json['data']?['otp_expires_in_minutes'],
        errors: json['errors'] != null
            ? Map<String, List<String>>.from(
                json['errors'].map((key, value) =>
                    MapEntry(key, List<String>.from(value))))
            : null,
      );
    } catch (e) {
      print('❌ ResendOtpResponse parsing error: $e');
      print('❌ JSON data: $json');
      // Return a basic response with the message
      return ResendOtpResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Unknown error',
        otpExpiresInMinutes: null,
        errors: null,
      );
    }
  }
}

// Forgot Password Response Model
class ForgotPasswordResponse {
  final bool success;
  final String message;
  final String? email;
  final Map<String, List<String>>? errors;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.email,
    this.errors,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ForgotPasswordResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        email: json['data']?['email'],
        errors: json['errors'] != null
            ? Map<String, List<String>>.from(
                json['errors'].map((key, value) =>
                    MapEntry(key, List<String>.from(value))))
            : null,
      );
    } catch (e) {
      print('❌ ForgotPasswordResponse parsing error: $e');
      print('❌ JSON data: $json');
      // Return a basic response with the message
      return ForgotPasswordResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Unknown error',
        email: null,
        errors: null,
      );
    }
  }
}

// Login Response Model (AuthResponse)
class AuthResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final String? token;
  final String? tokenType;
  final String? email;
  final bool? requiresVerification;
  final Map<String, List<String>>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.customer,
    this.token,
    this.tokenType,
    this.email,
    this.requiresVerification,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customer: json['data'] != null && json['data']['customer'] != null
          ? Customer.fromJson(json['data']['customer'])
          : null,
      token: json['data']?['token'],
      tokenType: json['data']?['token_type'],
      email: json['data']?['email'],
      requiresVerification: json['data']?['requires_verification'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

class ProfileImageResponse {
  final bool success;
  final String message;
  final String? profileImageUrl;
  final Map<String, List<String>>? errors;

  ProfileImageResponse({
    required this.success,
    required this.message,
    this.profileImageUrl,
    this.errors,
  });

  factory ProfileImageResponse.fromJson(Map<String, dynamic> json) {
    return ProfileImageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profileImageUrl: json['data']?['profile_image_url'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

// Update Phone Request Model
class UpdatePhoneRequest {
  final String phone;

  UpdatePhoneRequest({required this.phone});

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}

// Update Phone Response Model
class UpdatePhoneResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final Map<String, List<String>>? errors;

  UpdatePhoneResponse({
    required this.success,
    required this.message,
    this.customer,
    this.errors,
  });

  factory UpdatePhoneResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePhoneResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customer: json['data'] != null && json['data']['customer'] != null
          ? Customer.fromJson(json['data']['customer'])
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}
