// auth_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/services/storage_helper.dart';

// 🔹 Events
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? companyName;
  final String? notes;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.companyName,
    this.notes,
  });
}

class CheckAuthStatusEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// 🔹 States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Customer customer;
  final String token;

  AuthSuccess({required this.customer, required this.token});
}

class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  AuthError({required this.message, this.fieldErrors});
}

class AuthUnauthenticated extends AuthState {}

// 🔹 Model
class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final bool status;
  final String createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    required this.status,
    required this.createdAt,
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
    };
  }
}

// 🔹 BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String baseUrl = 'https://onecharge.io'; // Replace with your API URL

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  // 🔹 Login
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': event.email,
          'password': event.password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final customer = Customer.fromJson(data['data']['customer']);
        final token = data['data']['token'];

        await _storeAuthData(token, customer);

        emit(AuthSuccess(customer: customer, token: token));
      } else {
        if (data['errors'] != null) {
          final errors = Map<String, List<String>>.from(
            data['errors'].map((key, value) =>
                MapEntry(key, List<String>.from(value))),
          );
          emit(AuthError(
              message: data['message'] ?? 'Login failed',
              fieldErrors: errors));
        } else {
          emit(AuthError(message: data['message'] ?? 'Login failed'));
        }
      }
    } catch (e) {
      emit(AuthError(message: 'Network error. Please check your connection.'));
    }
  }

  // 🔹 Register
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': event.name,
          'email': event.email,
          'phone': event.phone,
          'password': event.password,
          'password_confirmation': event.passwordConfirmation,
          'company_name': event.companyName,
          'notes': event.notes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final customer = Customer.fromJson(data['data']['customer']);
        final token = data['data']['token'];

        await _storeAuthData(token, customer);

        emit(AuthSuccess(customer: customer, token: token));
      } else {
        if (data['errors'] != null) {
          final errors = Map<String, List<String>>.from(
            data['errors'].map((key, value) =>
                MapEntry(key, List<String>.from(value))),
          );
          emit(AuthError(
              message: data['message'] ?? 'Registration failed',
              fieldErrors: errors));
        } else {
          emit(AuthError(message: data['message'] ?? 'Registration failed'));
        }
      }
    } catch (e) {
      emit(AuthError(message: 'Network error. Please check your connection.'));
    }
  }

  // 🔹 Check Auth
  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final token = await StorageHelper.getString('auth_token');
      final userDataString = await StorageHelper.getString('user_data');

      if (token != null && userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          final customer = Customer.fromJson(userData);
          emit(AuthSuccess(customer: customer, token: token));
        } catch (e) {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('Auth status check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  // 🔹 Logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // show loader during logout
    try {
      await StorageHelper.remove('auth_token');
      await StorageHelper.remove('user_data');
      await StorageHelper.setBool('has_seen_onboarding', true);

      emit(AuthUnauthenticated());
    } catch (e) {
      print('Logout error: $e');
      emit(AuthError(message: "Logout failed. Please try again."));
    }
  }

  // 🔹 Store Auth
  Future<void> _storeAuthData(String token, Customer customer) async {
    try {
      await StorageHelper.setString('auth_token', token);
      await StorageHelper.setString('user_data', jsonEncode(customer.toJson()));
      await StorageHelper.setBool('has_seen_onboarding', true);
    } catch (e) {
      print('Store auth data error: $e');
    }
  }

  static Future<bool> hasSeenOnboarding() async {
    try {
      return await StorageHelper.getBool('has_seen_onboarding',
          defaultValue: false);
    } catch (e) {
      print('Check onboarding error: $e');
      return false;
    }
  }
}
