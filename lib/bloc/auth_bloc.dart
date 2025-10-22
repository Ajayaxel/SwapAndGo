// auth_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/services/storage_helper.dart';
import 'package:swap_app/model/auth_models.dart';

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

class VerifyEmailEvent extends AuthEvent {
  final String email;
  final String otp;

  VerifyEmailEvent({required this.email, required this.otp});
}

class ResendOtpEvent extends AuthEvent {
  final String email;

  ResendOtpEvent({required this.email});
}

class CheckAuthStatusEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class UpdatePhoneEvent extends AuthEvent {
  final String phone;

  UpdatePhoneEvent({required this.phone});
}

// 🔹 States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Customer customer;
  final String token;

  AuthSuccess({required this.customer, required this.token});
}

class RegistrationSuccess extends AuthState {
  final String message;
  final String email;
  final bool requiresVerification;

  RegistrationSuccess({
    required this.message,
    required this.email,
    this.requiresVerification = true,
  });
}

class EmailVerificationSuccess extends AuthState {
  final String message;

  EmailVerificationSuccess({required this.message});
}

class ResendOtpSuccess extends AuthState {
  final String message;

  ResendOtpSuccess({required this.message});
}

class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  AuthError({required this.message, this.fieldErrors});
}

class EmailNotVerified extends AuthState {
  final String message;
  final String email;

  EmailNotVerified({required this.message, required this.email});
}

class AuthUnauthenticated extends AuthState {}

class PhoneUpdateSuccess extends AuthState {
  final String message;
  final Customer customer;

  PhoneUpdateSuccess({required this.message, required this.customer});
}

// 🔹 Model (moved to auth_models.dart)

// 🔹 BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String baseUrl = 'https://onecharge.io'; // Replace with your API URL

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendOtpEvent>(_onResendOtp);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
    on<UpdatePhoneEvent>(_onUpdatePhone);
  }

  // 🔹 Login
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final loginRequest = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(loginRequest.toJson()),
      );

      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

      if (response.statusCode == 200 && authResponse.success) {
        await _storeAuthData(authResponse.token!, authResponse.customer!);
        emit(AuthSuccess(customer: authResponse.customer!, token: authResponse.token!));
      } else {
        // Check if email verification is required
        if (authResponse.requiresVerification == true && authResponse.email != null) {
          emit(EmailNotVerified(
            message: authResponse.message,
            email: authResponse.email!,
          ));
        } else {
          emit(AuthError(
            message: authResponse.message,
            fieldErrors: authResponse.errors,
          ));
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
      final signupRequest = SignupRequest(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        companyName: event.companyName,
        notes: event.notes,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(signupRequest.toJson()),
      );

      final registerResponse = RegisterResponse.fromJson(jsonDecode(response.body));

      if ((response.statusCode == 200 || response.statusCode == 201) && registerResponse.success) {
        // Registration successful - navigate to OTP verification
        emit(RegistrationSuccess(
          message: registerResponse.message,
          email: event.email,
          requiresVerification: registerResponse.requiresVerification ?? true,
        ));
      } else {
        emit(AuthError(
          message: registerResponse.message,
          fieldErrors: registerResponse.errors,
        ));
      }
    } catch (e) {
      emit(AuthError(message: 'Network error. Please check your connection.'));
    }
  }

  // 🔹 Verify Email
  Future<void> _onVerifyEmail(VerifyEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final verifyRequest = VerifyEmailRequest(
        email: event.email,
        otp: event.otp,
      );

      print('🔍 OTP Verification Request:');
      print('Email: ${event.email}');
      print('OTP: ${event.otp}');
      print('Request Body: ${jsonEncode(verifyRequest.toJson())}');
      print('API URL: $baseUrl/api/customer/verify-email');

      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/verify-email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(verifyRequest.toJson()),
      );

      print('🔍 OTP Verification Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      print('🔍 Raw Response Data: $responseData');
      
      final verifyResponse = VerifyEmailResponse.fromJson(responseData);

      print('🔍 Parsed Response:');
      print('Success: ${verifyResponse.success}');
      print('Message: ${verifyResponse.message}');
      print('Customer: ${verifyResponse.customer?.name}');
      print('Token: ${verifyResponse.token}');

      if (response.statusCode == 200 && verifyResponse.success) {
        // Email verification successful - navigate to login
        print('✅ OTP Verification Successful');
        emit(EmailVerificationSuccess(message: verifyResponse.message));
      } else {
        // Handle backend errors like "Customer not found"
        print('❌ OTP Verification Failed: ${verifyResponse.message}');
        emit(AuthError(
          message: verifyResponse.message,
          fieldErrors: verifyResponse.errors,
        ));
      }
    } catch (e) {
      print('❌ OTP Verification Error: $e');
      print('Error Type: ${e.runtimeType}');
      
      String errorMessage = 'Network error. Please check your connection.';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response format from server.';
      } else if (e.toString().contains('HttpException')) {
        errorMessage = 'Server error. Please try again later.';
      }
      
      print('Error Message: $errorMessage');
      emit(AuthError(message: errorMessage));
    }
  }

  // 🔹 Resend OTP
  Future<void> _onResendOtp(ResendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final resendRequest = ResendOtpRequest(
        email: event.email,
      );

      print('🔍 Resend OTP Request:');
      print('Email: ${event.email}');
      print('Request Body: ${jsonEncode(resendRequest.toJson())}');
      print('API URL: $baseUrl/api/customer/resend-otp');

      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(resendRequest.toJson()),
      );

      print('🔍 Resend OTP Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      print('🔍 Raw Response Data: $responseData');
      
      final resendResponse = ResendOtpResponse.fromJson(responseData);

      print('🔍 Parsed Resend Response:');
      print('Success: ${resendResponse.success}');
      print('Message: ${resendResponse.message}');
      print('OTP Expires In: ${resendResponse.otpExpiresInMinutes} minutes');

      if (response.statusCode == 200 && resendResponse.success) {
        // OTP resent successfully
        print('✅ OTP Resent Successfully');
        emit(ResendOtpSuccess(message: resendResponse.message));
      } else {
        // Handle backend errors
        print('❌ Resend OTP Failed: ${resendResponse.message}');
        emit(AuthError(
          message: resendResponse.message,
          fieldErrors: resendResponse.errors,
        ));
      }
    } catch (e) {
      print('❌ Resend OTP Error: $e');
      print('Error Type: ${e.runtimeType}');
      
      String errorMessage = 'Network error. Please check your connection.';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response format from server.';
      } else if (e.toString().contains('HttpException')) {
        errorMessage = 'Server error. Please try again later.';
      }
      
      print('Error Message: $errorMessage');
      emit(AuthError(message: errorMessage));
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

  // 🔹 Update Phone
  Future<void> _onUpdatePhone(UpdatePhoneEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final token = await StorageHelper.getString('auth_token');
      if (token == null) {
        emit(AuthError(message: 'Authentication required'));
        return;
      }

      final updateRequest = UpdatePhoneRequest(phone: event.phone);

      final response = await http.put(
        Uri.parse('$baseUrl/api/customer/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateRequest.toJson()),
      );

      final updateResponse = UpdatePhoneResponse.fromJson(jsonDecode(response.body));

      if (response.statusCode == 200 && updateResponse.success) {
        // Update stored user data
        if (updateResponse.customer != null) {
          await StorageHelper.setString('user_data', jsonEncode(updateResponse.customer!.toJson()));
          emit(PhoneUpdateSuccess(
            message: updateResponse.message,
            customer: updateResponse.customer!,
          ));
        } else {
          emit(AuthError(message: 'Failed to update phone number'));
        }
      } else {
        emit(AuthError(
          message: updateResponse.message,
          fieldErrors: updateResponse.errors,
        ));
      }
    } catch (e) {
      emit(AuthError(message: 'Network error. Please check your connection.'));
    }
  }
}
