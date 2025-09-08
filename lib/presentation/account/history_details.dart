import 'package:flutter/material.dart';

class HistoryDetails extends StatelessWidget {
  const HistoryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Black header with date and back arrow
            Container(
              width: double.infinity,
              color: Colors.black,
      padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(onTap: () {
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back, color: Colors.white, size: 24)),
                  SizedBox(width: 16),
                  Text(
                    "July 27, 12:12 PM",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Swapping sessions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
        
                    SizedBox(height: 32),
        
                    // Session list
                    Expanded(
                      child: Column(
                        children: [
                          _buildSessionItem("May 15, 3:23 PM", "AED 25"),
                          SizedBox(height: 24),
                          _buildSessionItem("May 13, 3:23 PM", "AED 25"),
                          SizedBox(height: 24),
                          _buildSessionItem("June, 3:23 PM", "AED 25"),
                          SizedBox(height: 24),
                          _buildSessionItem("June, 21:23 PM", "AED 25"),
        
                          // Divider line
                          Container(
                            height: 1,
                            color: Colors.grey[300],
                            margin: EdgeInsets.symmetric(vertical: 16),
                          ),
        
                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff5D6067),
                                ),
                              ),
                              Text(
                                "AED 100.00",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff5D6067),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(String date, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xff56585D),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xff56585D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
