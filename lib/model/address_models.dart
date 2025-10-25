// address_models.dart

// Country Model
class Country {
  final int id;
  final String name;
  final String code;

  Country({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

// Address Model
class Address {
  final int id;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final Country country;
  final String type;
  final bool isDefault;
  final String fullAddress;
  final String createdAt;
  final String updatedAt;

  Address({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.type,
    required this.isDefault,
    required this.fullAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: Country.fromJson(json['country'] ?? {}),
      type: json['type'] ?? '',
      isDefault: json['is_default'] ?? false,
      fullAddress: json['full_address'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country.toJson(),
      'type': type,
      'is_default': isDefault,
      'full_address': fullAddress,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Create Address Request Model
class CreateAddressRequest {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final int countryId;
  final String type;
  final bool isDefault;

  CreateAddressRequest({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryId,
    required this.type,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country_id': countryId,
      'type': type,
      'is_default': isDefault,
    };
  }
}

// Create Address Response Model
class CreateAddressResponse {
  final bool success;
  final String message;
  final Address? address;
  final Map<String, List<String>>? errors;

  CreateAddressResponse({
    required this.success,
    required this.message,
    this.address,
    this.errors,
  });

  factory CreateAddressResponse.fromJson(Map<String, dynamic> json) {
    return CreateAddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      address: json['data'] != null && json['data']['address'] != null
          ? Address.fromJson(json['data']['address'])
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

// Update Address Request Model
class UpdateAddressRequest {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final int countryId;
  final String type;
  final bool isDefault;

  UpdateAddressRequest({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryId,
    required this.type,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country_id': countryId,
      'type': type,
      'is_default': isDefault,
    };
  }
}


// Update Address Response Model
class UpdateAddressResponse {
  final bool success;
  final String message;
  final Address? address;
  final Map<String, List<String>>? errors;

  UpdateAddressResponse({
    required this.success,
    required this.message,
    this.address,
    this.errors,
  });

  factory UpdateAddressResponse.fromJson(Map<String, dynamic> json) {
    return UpdateAddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      address: json['data'] != null && json['data']['address'] != null
          ? Address.fromJson(json['data']['address'])
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

// Countries Response Model
class CountriesResponse {
  final bool success;
  final String message;
  final List<Country> countries;
  final Map<String, List<String>>? errors;

  CountriesResponse({
    required this.success,
    required this.message,
    required this.countries,
    this.errors,
  });

  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    List<Country> countries = [];
    
    if (json['data'] != null) {
      final countriesList = json['data'] as List<dynamic>;
      countries = countriesList
          .map((countryJson) => Country.fromJson(countryJson as Map<String, dynamic>))
          .toList();
    }

    return CountriesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      countries: countries,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

// Delete Address Response Model
class DeleteAddressResponse {
  final bool success;
  final String message;
  final Map<String, List<String>>? errors;

  DeleteAddressResponse({
    required this.success,
    required this.message,
    this.errors,
  });

  factory DeleteAddressResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}

// Address Response Model
class AddressResponse {
  final bool success;
  final String message;
  final List<Address> addresses;
  final Map<String, List<String>>? errors;

  AddressResponse({
    required this.success,
    required this.message,
    required this.addresses,
    this.errors,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    List<Address> addresses = [];
    
    if (json['data'] != null && json['data']['addresses'] != null) {
      final addressesList = json['data']['addresses'] as List<dynamic>;
      addresses = addressesList
          .map((addressJson) => Address.fromJson(addressJson as Map<String, dynamic>))
          .toList();
    }

    return AddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      addresses: addresses,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
    );
  }
}
