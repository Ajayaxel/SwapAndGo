import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
   const HistoryScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(onTap: () {
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back, color: Colors.black)),
                  SizedBox(width: 16),
                  Text(
                    "History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return SwapCard();
                  },
                  itemCount: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwapCard extends StatelessWidget {
  const SwapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with Date, Time and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "July 27, 12:12 PM",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Swap Completed",
                      style: TextStyle(fontSize: 11, color: Color(0xff66696E)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "AED 16.50",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff45C85A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Paid",
                      style: TextStyle(fontSize: 12, color: Color(0xff45C85A)),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xffE7E7E7)),

            const SizedBox(height: 12),

            // Row with Icon, Code and Duration
            Row(
              children: [
                Icon(
                  Icons.battery_charging_full,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "ABCFDSGHNBV1234V54",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff5B626A),
                    ),
                  ),
                ),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  "24.45 mins",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff5B626A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),

            const SizedBox(height: 12),

            // Station Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.ev_station, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "STATION NAME",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "STATION NAME, 6TH STREET, OPP JUMA MASJID, SHARJAH, DUBAI",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff7A7B7D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
