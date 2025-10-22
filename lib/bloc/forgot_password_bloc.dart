// forgot_password_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/auth_models.dart';

// 🔹 Events
abstract class ForgotPasswordEvent {}

class ForgotPasswordSubmitEvent extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordSubmitEvent({required this.email});
}

// 🔹 States
abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  final String email;

  ForgotPasswordSuccess({required this.message, required this.email});
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ForgotPasswordError({required this.message, this.fieldErrors});
}

// 🔹 BLoC
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  static const String baseUrl = 'https://onecharge.io';

  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitEvent>(_onForgotPasswordSubmit);
  }

  // 🔹 Forgot Password Submit
  Future<void> _onForgotPasswordSubmit(
      ForgotPasswordSubmitEvent event, Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordLoading());

    try {
      final forgotPasswordRequest = ForgotPasswordRequest(
        email: event.email,
      );

      print('🔍 Forgot Password Request:');
      print('Email: ${event.email}');
      print('Request Body: ${jsonEncode(forgotPasswordRequest.toJson())}');
      print('API URL: $baseUrl/api/customer/forgot-password');
      
      // Add a small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));

      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(forgotPasswordRequest.toJson()),
      );

      print('🔍 Forgot Password Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      print('🔍 Raw Response Data: $responseData');
      
      final forgotPasswordResponse = ForgotPasswordResponse.fromJson(responseData);

      print('🔍 Parsed Forgot Password Response:');
      print('Success: ${forgotPasswordResponse.success}');
      print('Message: ${forgotPasswordResponse.message}');
      print('Email: ${forgotPasswordResponse.email}');

      if (response.statusCode == 200 && forgotPasswordResponse.success) {
        // Forgot password request successful
        print('✅ Forgot Password Request Successful');
        emit(ForgotPasswordSuccess(
          message: forgotPasswordResponse.message,
          email: forgotPasswordResponse.email ?? event.email,
        ));
      } else {
        // Handle backend errors
        print('❌ Forgot Password Failed: ${forgotPasswordResponse.message}');
        
        // Handle rate limiting specifically
        String errorMessage = forgotPasswordResponse.message;
        if (response.statusCode == 400 && errorMessage.contains('wait')) {
          errorMessage = 'Please wait a moment before trying again. Rate limit exceeded.';
        }
        
        emit(ForgotPasswordError(
          message: errorMessage,
          fieldErrors: forgotPasswordResponse.errors,
        ));
      }
    } catch (e) {
      print('❌ Forgot Password Error: $e');
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
      emit(ForgotPasswordError(message: errorMessage));
    }
  }
}
