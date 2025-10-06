// app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/presentation/login/login_screen.dart';
import 'package:swap_app/presentation/bootmnav/bottm_nav.dart';
import 'package:swap_app/presentation/onboarding/onboarding.dart';
import 'package:swap_app/widgets/auth_listener.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when app starts
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AuthListener(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }
          
          if (state is AuthSuccess) {
            // User is authenticated, go to main app
            return const BottomNav();
          }
          
          // User is not authenticated (AuthUnauthenticated or AuthError), check if they've seen onboarding
          return FutureBuilder<bool>(
            future: AuthBloc.hasSeenOnboarding(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
              
              final hasSeenOnboarding = snapshot.data ?? false;
              
              if (hasSeenOnboarding) {
                // Show login screen
                return const LoginScreen();
              } else {
                // Show onboarding screen
                return const OnboardingScreen();
              }
            },
          );
        },
      ),
    );
  }
}