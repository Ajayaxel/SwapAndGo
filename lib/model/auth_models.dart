// auth_models.dart
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

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final bool status;
  final String createdAt;
  final String? profileImageUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    required this.status,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      companyName: json['company_name'],
      status: json['status'],
      createdAt: json['created_at'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company_name': companyName,
      'status': status,
      'created_at': createdAt,
      'profile_image_url': profileImageUrl,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final Customer? customer;
  final String? token;
  final String? tokenType;
  final Map<String, List<String>>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.customer,
    this.token,
    this.tokenType,
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
