import 'package:flutter/material.dart';
import 'package:swap_app/const/go_button.dart';

class RoadsideAssistanceScreen extends StatelessWidget {
  const RoadsideAssistanceScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back,color: Colors.black, size: 28),
              ),
              SizedBox(height: size.height * 0.01),

              // Title
              Text(
                "Swap & go Roadside Assistance",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: size.height * 0.005),

              // Subtitle
              Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: size.height * 0.03),

              // What's Included Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  color: Color(0xff18191B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's included...",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    // List Items
                    ...[
                      "24/7 roadside assistance",
                      "Lorem Ipsum is simply dummy text of Lorem",
                      "Lorem Ipsum is simply dummy text of Lorem",
                      "Lorem Ipsum is simply dummy text of Lorem",
                    ].map(
                      (item) => Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(size.width * 0.025),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.battery_charging_full,
                                  color: Colors.white,
                                  size: size.width * 0.06,
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                            ),
                            child: Divider(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            

              SizedBox(height: size.height * 0.04),

              // Send Request Button
              GoButton(
                text: "Send Request",
                onPressed: () {},
                backgroundColor: Colors.black,
                textColor: Colors.white,
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
