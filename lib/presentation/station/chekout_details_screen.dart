import 'package:flutter/material.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/bootmnav/bottm_nav.dart';

class CheckoutDetailsScreen extends StatelessWidget {
  const CheckoutDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back and Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNav(),
                        ),
                        (route) => false, // Remove all previous routes
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Checkout Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow("Booking ID", "#SWP12345"),
                    const SizedBox(height: 15),
                    _buildDetailRow("Battery ID", "BATT-12345"),
                    const SizedBox(height: 15),
                    _buildDetailRow("Station", "Karama Centre Dubai"),
                    const SizedBox(height: 15),
                    _buildDetailRow("Date & Time", "11 Sept 2025, 09:30 AM"),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Download Invoice Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "DOWNLOAD INVOICE",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Back to Home Button
              GoButton(
                onPressed: () {},
                text: 'BACK TO HOME',
                backgroundColor: Color(0xff0A2342),
                textColor: Colors.white,
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xff0A2342),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ),
      ],
    );
  }
}
