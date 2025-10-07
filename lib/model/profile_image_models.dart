// profile_image_models.dart

/// Profile Image Upload Response Model
class ProfileImageUploadResponse {
  final bool success;
  final String message;
  final ProfileImageData? data;

  ProfileImageUploadResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ProfileImageUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileImageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// Profile Image Data Model
class ProfileImageData {
  final String profileImageUrl;

  ProfileImageData({
    required this.profileImageUrl,
  });

  factory ProfileImageData.fromJson(Map<String, dynamic> json) {
    return ProfileImageData(
      profileImageUrl: json['profile_image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_image_url': profileImageUrl,
    };
  }
}

/// Profile Fetch Response Model
class ProfileFetchResponse {
  final bool success;
  final String message;
  final ProfileFetchData? data;

  ProfileFetchResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileFetchResponse.fromJson(Map<String, dynamic> json) {
    return ProfileFetchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileFetchData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// Profile Fetch Data Model
class ProfileFetchData {
  final CustomerProfile customer;

  ProfileFetchData({
    required this.customer,
  });

  factory ProfileFetchData.fromJson(Map<String, dynamic> json) {
    return ProfileFetchData(
      customer: CustomerProfile.fromJson(json['customer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
    };
  }
}

/// Customer Profile Model
class CustomerProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String? notes;
  final bool status;
  final String? profileImageUrl;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    this.notes,
    required this.status,
    this.profileImageUrl,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['company_name'],
      notes: json['notes'],
      status: json['status'] ?? false,
      profileImageUrl: json['profile_image_url'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company_name': companyName,
      'notes': notes,
      'status': status,
      'profile_image_url': profileImageUrl,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Profile Image Delete Response Model
class ProfileImageDeleteResponse {
  final bool success;
  final String message;

  ProfileImageDeleteResponse({
    required this.success,
    required this.message,
  });

  factory ProfileImageDeleteResponse.fromJson(Map<String, dynamic> json) {
    return ProfileImageDeleteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
