import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/const/go_button.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting + Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthSuccess) {
                        return Text(
                          'Hi ${state.customer.name},',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        );
                      } else if (state is AuthLoading) {
                        return const Text(
                          'Hi ...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        );
                      } else {
                        return const Text(
                          'Hi Guest,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'welcome',
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.location_on_outlined, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Manama, Dubai',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // Battery section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Baseline(
                  baseline: 65,
                  baselineType: TextBaseline.alphabetic,
                  child: const Icon(Icons.battery_3_bar, size: 70),
                ),
                const SizedBox(width: 10),
                Baseline(
                  baseline: 65,
                  baselineType: TextBaseline.alphabetic,
                  child: const Text(
                    '51',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Baseline(
                  baseline: 70,
                  baselineType: TextBaseline.alphabetic,
                  child: const Text(
                    'km',
                    style: TextStyle(fontSize: 24, height: 1),
                  ),
                ),
              ],
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: 0.55,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('55%', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // Map + Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'asset/home/map.png',
                      width: double.infinity,
                      height: 450,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Search Bar
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Find swap stations',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),

                  // Swap Now Button
                  Positioned(
                    bottom: 16,
                    left: 1,
                    right: 1,
                    child: GoButton(
                      onPressed: () {},
                      text: "SWAP NOW",
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

