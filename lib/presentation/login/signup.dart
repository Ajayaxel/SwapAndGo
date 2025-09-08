// signup.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/const/go_button.dart';

import 'package:swap_app/bloc/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = true;

  // Error messages for form fields
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  void _handleSignUp() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _clearFieldErrors();
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _mobileController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final companyName = _companyNameController.text.trim();
    
    // Basic validation
    bool hasErrors = false;
    
    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      hasErrors = true;
    }
    
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      hasErrors = true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      hasErrors = true;
    }
    
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Phone number is required');
      hasErrors = true;
    }
    
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      hasErrors = true;
    } else if (password.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      hasErrors = true;
    }
    
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Confirm password is required');
      hasErrors = true;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      hasErrors = true;
    }
    
    if (hasErrors) return;

    context.read<AuthBloc>().add(
      RegisterEvent(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: confirmPassword,
        companyName: companyName.isNotEmpty ? companyName : null,
        notes: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A2342),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful! Please login with your credentials.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              
              // Navigate back to login page immediately
              Navigator.of(context).pop();
            } else if (state is AuthError) {
              // Handle field-specific errors
              if (state.fieldErrors != null) {
                setState(() {
                  _nameError = state.fieldErrors!['name']?.first;
                  _emailError = state.fieldErrors!['email']?.first;
                  _phoneError = state.fieldErrors!['phone']?.first;
                  _passwordError = state.fieldErrors!['password']?.first;
                });
              }
              
              // Show general error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 30,
                      bottom: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 100),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Welcome",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            Center(
                              child: Image.asset(
                                "asset/login/web@4x 1.png",
                                height: 40,
                                width: 200,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Name Field
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                if (_nameError != null) {
                                  setState(() => _nameError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Name',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.transparent,
                                errorText: _nameError,
                                errorStyle: const TextStyle(color: Colors.red),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _nameError != null 
                                        ? Colors.red 
                                        : const Color(0xffD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _nameError != null 
                                        ? Colors.red 
                                        : Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.transparent,
                                errorText: _emailError,
                                errorStyle: const TextStyle(color: Colors.red),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _emailError != null 
                                        ? Colors.red 
                                        : const Color(0xffD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _emailError != null 
                                        ? Colors.red 
                                        : Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Mobile Field
                            TextField(
                              controller: _mobileController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                if (_phoneError != null) {
                                  setState(() => _phoneError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your mobile number',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.transparent,
                                errorText: _phoneError,
                                errorStyle: const TextStyle(color: Colors.red),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _phoneError != null 
                                        ? Colors.red 
                                        : const Color(0xffD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _phoneError != null 
                                        ? Colors.red 
                                        : Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // // Company Name Field (Optional)
                            // TextField(
                            //   controller: _companyNameController,
                            //   style: const TextStyle(color: Colors.white),
                            //   decoration: InputDecoration(
                            //     hintText: 'Company Name (Optional)',
                            //     hintStyle: const TextStyle(color: Colors.white54),
                            //     filled: true,
                            //     fillColor: Colors.transparent,
                            //     enabledBorder: OutlineInputBorder(
                            //       borderSide: const BorderSide(
                            //         color: Color(0xffD9D9D9),
                            //       ),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     focusedBorder: OutlineInputBorder(
                            //       borderSide: const BorderSide(color: Colors.white),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //   ),
                            //   keyboardType: TextInputType.text,
                            // ),
                            // const SizedBox(height: 16),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.white54),
                                errorText: _passwordError,
                                errorStyle: const TextStyle(color: Colors.red),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _passwordError != null 
                                        ? Colors.red 
                                        : const Color(0xffD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _passwordError != null 
                                        ? Colors.red 
                                        : Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                if (_confirmPasswordError != null) {
                                  setState(() => _confirmPasswordError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: const TextStyle(color: Colors.white54),
                                errorText: _confirmPasswordError,
                                errorStyle: const TextStyle(color: Colors.red),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _confirmPasswordError != null 
                                        ? Colors.red 
                                        : const Color(0xffD9D9D9),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _confirmPasswordError != null 
                                        ? Colors.red 
                                        : Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Sign Up Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return GoButton(
                                  onPressed: isLoading ? () {} : _handleSignUp,
                                  text: isLoading ? "SIGNING UP..." : "SIGN UP",
                                  backgroundColor: isLoading ? Colors.grey : Colors.white,
                                  textColor: isLoading ? Colors.white54 : Colors.black,
                                  foregroundColor: isLoading ? Colors.white54 : Colors.black,
                                );
                              },
                            ),
                            const SizedBox(height: 30),

                            // Terms and Conditions Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                                const Expanded(
                                  child: Text(
                                    'I agree to the Privacy Policy and Terms of Service',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Login Link
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Existing User? Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}