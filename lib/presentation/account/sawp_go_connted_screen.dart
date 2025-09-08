import 'package:flutter/material.dart';

class SwapGoConnectScreen extends StatelessWidget {
  const SwapGoConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Icon
                GestureDetector(
                  child: Icon(Icons.arrow_back, size: 28, color: Colors.black),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 12),

                // Title & Subtitle
                Text(
                  "Swap & go Connect",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // Image
                Image.asset(
                  "asset/account/sub.png",
                  width: screenWidth,
                  height: 125,
                  fit: BoxFit.cover,
                ),

                // Black Container
                Container(
                  margin: const EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    color: Color(0xff18191B),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's included...",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        // List Items
                        ...List.generate(5, (index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xff282B30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.battery_charging_full,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      "Lorem Ipsum is simply dummy text of Lorem",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (index != 4) ...[
                                const SizedBox(height: 16),
                                Divider(
                                  color: Colors.grey.shade700,
                                  thickness: 0.5,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
