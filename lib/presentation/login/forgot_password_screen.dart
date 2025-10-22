import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/bloc/forgot_password_bloc.dart';
import 'package:swap_app/presentation/login/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
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

  void _handleForgotPassword(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    print('🔍 Forgot Password Screen:');
    print('Email: ${_emailController.text}');

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordSubmitEvent(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(),
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          print('🔍 Forgot Password Screen - State: ${state.runtimeType}');
          
          if (state is ForgotPasswordSuccess) {
            print('✅ Forgot Password Success: ${state.message}');
            _showMessage(
              'Password reset link sent to ${state.email}',
              isError: false,
            );
            // Navigate back to login screen after a short delay
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            });
          } else if (state is ForgotPasswordError) {
            print('❌ Forgot Password Error: ${state.message}');
            _showMessage(state.message, isError: true);
          } else if (state is ForgotPasswordLoading) {
            print('⏳ Forgot Password Loading...');
          }
        },
        child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: const Color(0xff0A2342),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
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
                                  onPressed: isLoading ? null : () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(height: 20),

       

                              // Title
                              const Text(
                                "Forgot Password",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Message
                              const Text(
                                'Enter your email address and we\'ll send you a link to reset your password.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 50),

                              // Email Input Field
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                style: TextStyle(
                                  color: isLoading ? Colors.white54 : Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  labelStyle: TextStyle(
                                    color: isLoading ? Colors.white54 : Colors.white70,
                                    fontSize: 14,
                                  ),
                                  hintText: 'Enter your email address',
                                  hintStyle: TextStyle(
                                    color: isLoading ? Colors.white38 : Colors.white54,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: isLoading ? Colors.white54 : Colors.white70,
                                  ),
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
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),

                              // Submit Button
                              GoButton(
                                onPressed: isLoading 
                                    ? null 
                                    : () => _handleForgotPassword(context),
                                text: isLoading
                                    ? "SENDING..."
                                    : "SEND RESET LINK",
                                backgroundColor: isLoading ? Colors.grey : Colors.white,
                                textColor: Colors.black,
                                foregroundColor: Colors.black,
                              ),
                              const SizedBox(height: 20),

                              // Back to Login
                              TextButton(
                                onPressed: isLoading ? null : () => Navigator.pop(context),
                                child: Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: isLoading ? Colors.white54 : Colors.white70,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Loading Overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}