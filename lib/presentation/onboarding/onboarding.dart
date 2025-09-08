// onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:swap_app/services/storage_helper.dart';

import 'package:swap_app/presentation/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "asset/login/onbodingcar.png",
      "text": "Locate your near by battery swapping station on map",
    },
    {
      "image": "asset/login/onbording2.png",
      "text": "Easily swap your battery in minutes at nearby stations",
    },
    {
      "image": "asset/login/onbodingcar.png",
      "text": "Enjoy seamless driving without charging delays",
    },
  ];

  Future<void> _completeOnboarding() async {
    try {
      await StorageHelper.setBool('has_seen_onboarding', true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    } catch (e) {
      print('Onboarding completion error: $e');
      // Navigate anyway if storage fails
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
    backgroundColor: Color(0xff0A2342),
      body: Stack(
        children: [
          // Large outer circle
          Positioned(
            top: -screenHeight * 0.3,
            left: -screenWidth * 0.4,
            right: -screenWidth * 0.4,
            child: Container(
              height: screenHeight * 1.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Inner circle
          Positioned(
            top: screenHeight * 0.11,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            bottom: screenHeight * 0.43,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),

          // PageView Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 6),
                          
                          // Car Image
                          SizedBox(
                            height: 200,
                            child: Image.asset(
                              onboardingData[index]["image"]!,
                              width: 300,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          const SizedBox(height: 60),

                          // Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Text(
                              onboardingData[index]["text"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                          ),
                          
                          const Spacer(flex: 2),
                        ],
                      );
                    },
                  ),
                ),

                // Dots Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 26,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),

                // Arrow Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (_currentPage < onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

