import 'package:flutter/material.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/account/roadside_assistance_screnn.dart';
import 'package:swap_app/presentation/account/sawp_go_connted_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back & Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24 , color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Subscription",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // First Card
              _subscriptionCard(
                title: "Swap & go",
                description:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                buttonText: "View benefits",
                outlinedButton: true,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SwapGoConnectScreen()));
                },
              ),
              const SizedBox(height: 16),

              // Second Card
              _subscriptionCard(
                title: "Swap & go Road Assistence",
                description:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                buttonText: "Buy",
                outlinedButton: false,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RoadsideAssistanceScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String description,
    required String buttonText,
    required bool outlinedButton,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff999999),
            ),
          ),
          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            child: outlinedButton
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  )
                : GoButton(
                    onPressed: onPressed,
                    text: buttonText,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    foregroundColor: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }
}
