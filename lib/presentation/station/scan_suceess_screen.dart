import 'package:flutter/material.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/model/qr_scan_data.dart';
import 'package:swap_app/presentation/bootmnav/bottm_nav.dart';
import 'package:swap_app/presentation/station/chekout_screen.dart';
import 'package:swap_app/presentation/station/sacn_details_screen.dart';

class ScanSuccessScreen extends StatelessWidget {
  final QRScanData? scannedData;

  const ScanSuccessScreen({super.key, this.scannedData});

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),

            // Green check circle
            Center(
              child: Image.asset(
                'asset/home/tic.png',
                fit: BoxFit.contain,
                height: 200,
              ),
            ),
            const SizedBox(height: 40),

            // Success text
            const Text(
              'Swap Successful',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Your battery has been successfully swapped.",
              style: TextStyle(fontSize: 16 ,color: Colors.black),
            ),

            const SizedBox(height: 16),

            const Spacer(),

            // Additional action buttons if scan data is available
            if (scannedData != null) ...[
              // View Details Button
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xff0A2342)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Navigate to scan details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScanDetailsScreen(scannedData: scannedData!),
                        ),
                      );
                    },
                    child: const Text(
                      "VIEW SCAN DETAILS",
                      style: TextStyle(
                        color: Color(0xff0A2342),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // DONE button
            GoButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  (route) => false, // Remove all previous routes
                );
              },
              text: 'CHECKOUT',
              backgroundColor: Color(0xff0A2342),
              textColor: Colors.white,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
