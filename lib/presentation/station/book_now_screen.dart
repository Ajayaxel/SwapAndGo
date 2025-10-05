import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:swap_app/bloc/qrcode/qrcode_bloc.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/model/qr_scan_data.dart';
import 'package:swap_app/model/station_model.dart';
import 'package:swap_app/presentation/station/scan_suceess_screen.dart';

class BookNowScreen extends StatelessWidget {
  final QRScanData? scannedData;
  final Station station;
  const BookNowScreen({super.key, this.scannedData, required this.station});
 

  @override
  Widget build(BuildContext context) {
    double chargePercent = 14; // current battery percentage
    double percentValue = chargePercent / 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Battery Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF0A1A3D),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Current Charge",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0A1A3D),
            ),
          ),
          const SizedBox(height: 20),

          // Circular Battery Indicator
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 12.0,
            animation: true,
            percent: percentValue,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.red,
            backgroundColor: Colors.grey.shade300,
            center: Text(
              "${chargePercent.toInt()}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.red,
              ),
            ),
          ),

          const SizedBox(height: 40),
          const Text(
            "Time to 90%",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "11:25 PM",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: GoButton(
              onPressed: () {
                context.read<QrcodeBloc>().add(QrCodeCheckoutRequested(qrCode: scannedData?.batteryCode?? ''));
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScanSuccessScreen(scannedData: scannedData,station: station)));
              },
              text: "Swap now",
              backgroundColor: Color(0xff0A2342),
              textColor: Colors.white,
              foregroundColor: Colors.white,
           
            ),
          ),

          // Bottom Button
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
