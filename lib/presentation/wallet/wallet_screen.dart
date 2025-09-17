import 'package:flutter/material.dart';
import 'package:swap_app/const/conts_colors.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/wallet/payment_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _showbottmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaymentBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Payments",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // Available Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'AED 13.50',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Balance Progress Bar
                    Column(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade200,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 27, // 13.50 out of 50
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: const Color(
                                      0xFF00C851,
                                    ), // Green color
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 73, // Remaining portion
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AED 0',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'AED 50',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Warning Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.goBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.memory,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            textAlign: TextAlign.start,
                            'For uninterrupted swapping battery, clear your dues before you run out of balance',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff212121),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GoButton(
                      onPressed: () {
                        _showbottmSheet(context);

                        // Handle payment action
                      },
                      text: 'Pay AED 36.50',
                      backgroundColor: AppColors.goBlue,
                      textColor: Colors.white,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pay Button
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentBottomSheet extends StatelessWidget {
  const PaymentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Image.asset(
              'asset/home/coin.png',
              fit: BoxFit.cover,
              height: 150,
              width: 196,
            ),
            const SizedBox(height: 12),

            // Title
            const Text(
              'Pay now for uninterrupted charging',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Clear your dues of AED36.50.\nThis will renew your balance to full amount',
              style: TextStyle(fontSize: 14, color: Color(0xff0E0E0E)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Continue Button
            GoButton(
              onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
              },
              text: 'Continue',
              backgroundColor: AppColors.goBlue,
              textColor: Colors.white,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
