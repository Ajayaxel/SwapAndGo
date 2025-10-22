import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/presentation/login/login_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? message;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.message,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleVerifyOtp() {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _showMessage('Please enter all 6 digits', isError: true);
      return;
    }

    print('🔍 OTP Verification Screen:');
    print('Email: ${widget.email}');
    print('OTP: $otp');
    print('OTP Length: ${otp.length}');

    context.read<AuthBloc>().add(
          VerifyEmailEvent(
            email: widget.email,
            otp: otp,
          ),
        );
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _handleResendOtp() {
    print('🔍 Resend OTP triggered for: ${widget.email}');
    context.read<AuthBloc>().add(
      ResendOtpEvent(email: widget.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔍 OTP Screen - Auth State: ${state.runtimeType}');
        
        if (state is EmailVerificationSuccess) {
          print('✅ Email Verification Success: ${state.message}');
          _showMessage(
            'Email verified successfully! Please login to continue',
            isError: false,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is ResendOtpSuccess) {
          print('✅ Resend OTP Success: ${state.message}');
          _showMessage(
            'OTP resent successfully! Please check your email.',
            isError: false,
          );
        } else if (state is AuthError) {
          print('❌ Auth Error: ${state.message}');
          _showMessage(state.message, isError: true);
          // Only clear OTP fields on verification error, not on resend error
          if (state.message.contains('verification') || state.message.contains('OTP')) {
            _clearOtpFields();
          }
        } else if (state is AuthLoading) {
          print('⏳ Auth Loading...');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0A2342),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 30),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logo
                    Center(
                      child: Image.asset(
                        "asset/login/web@4x 1.png",
                        height: 40,
                        width: 200,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Title
                    const Text(
                      "Verify Email",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Message
                    Text(
                      widget.message ??
                          'We have sent a verification code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          height: 55,
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xffD9D9D9),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    // Verify Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return GoButton(
                          onPressed: state is AuthLoading ? null : _handleVerifyOtp,
                          text: state is AuthLoading
                              ? "VERIFYING..."
                              : "VERIFY EMAIL",
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          foregroundColor: Colors.black,
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Resend OTP
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Didn't receive the code? ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: isLoading ? null : _handleResendOtp,
                              child: Text(
                                isLoading ? 'Sending...' : 'Resend',
                                style: TextStyle(
                                  color: isLoading ? Colors.white54 : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Timer info
                    const Text(
                      'OTP expires in 10 minutes',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

