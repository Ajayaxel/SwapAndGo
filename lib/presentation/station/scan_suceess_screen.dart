import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/qrcode/qrcode_bloc.dart';
import 'package:swap_app/bloc/station/station_bloc.dart';
import 'package:swap_app/bloc/station/station_event.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/model/qr_scan_data.dart';
import 'package:swap_app/model/station_model.dart';
import 'package:swap_app/presentation/station/chekout_screen.dart';
import 'package:swap_app/presentation/station/sacn_details_screen.dart';
import 'package:swap_app/presentation/station/station_screen.dart';


Station? selectedStation;
class ScanSuccessScreen extends StatelessWidget {
  final QRScanData? scannedData;
  final Station station;
  const ScanSuccessScreen({super.key, this.scannedData, required this.station});


  @override
  Widget build(BuildContext context) {
    
    return BlocConsumer<QrcodeBloc, QrcodeState>(
      listener: (context, state) {
        if (state is QrcodeError) {
          _showErrorDialog(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 70),

                // Show different content based on QR code state
                _buildContent(context, state),

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

                // Action buttons based on state
                _buildActionButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, QrcodeState state) {
    if (state is QrcodeLoading) {
      return Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xff0A2342),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Processing QR Code...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (state.qrCode.isNotEmpty)
            Text(
              'Code: ${state.qrCode}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
        ],
      );
    } else if (state is QrcodeError) {
      return Column(
        children: [
          // Error icon
          Icon(
            Icons.error_outline,
            size: 120,
            color: Colors.red[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'Processing Failed',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    } else if (state is QrcodeSuccess) {
      return Column(
        children: [
          // Success icon
          Image.asset(
            'asset/home/tic.png',
            fit: BoxFit.contain,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Swap Successful',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            state.message ?? "AED 1.00 Debited from your wallet",
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          if (state.data != null) ...[
            const SizedBox(height: 10),
            Text(
              'Transaction ID: ${state.data?['transaction_id'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      );
    } else {
      // Default success state (when no QR code processing)
      return Column(
        children: [
          // Green check circle
          Image.asset(
            'asset/home/tic.png',
            fit: BoxFit.contain,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Swap Successful',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "AED 1.00 Debited from your wallet",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, QrcodeState state) {
    if (state is QrcodeLoading) {
      return const SizedBox.shrink(); // No buttons during loading
    } else if (state is QrcodeError) {
      return Column(
        children: [
          // Retry button
          GoButton(
            onPressed: () {
              // Retry QR code processing
              if (scannedData != null) {
                context.read<QrcodeBloc>().add(
                  QrCodeCheckoutRequested(qrCode: scannedData!.batteryCode),
                );
              }
            },
            text: 'RETRY',
            backgroundColor: const Color(0xff0A2342),
            textColor: Colors.white,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          // Back button
          GoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            text: 'BACK',
            backgroundColor: Colors.grey[600]!,
            textColor: Colors.white,
            foregroundColor: Colors.white,
          ),
        ],
      );
    } else {
      // Success state buttons
      return Column(
        children: [
          // CHECKOUT button
          // GoButton(
          //   onPressed: () {
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(builder: (context) => const CheckoutScreen()),
          //       (route) => false, // Remove all previous routes
          //     );
          //   },
          //   text: 'CHECKOUT',
          //   backgroundColor: const Color(0xff0A2342),
          //   textColor: Colors.white,
          //   foregroundColor: Colors.white,
          // ),
          const SizedBox(height: 12),
          // Done button
          GoButton(
            onPressed: () {
              // Reset QR code state and navigate back
              context.read<QrcodeBloc>().add(const QrCodeReset());
              selectedStation = station;
              Navigator.popUntil(context, (route){
                return route.isFirst;
              } );

              stationScreenKey.currentState?.showStationModal(context, station);
             

            },
            text: 'DONE',
            backgroundColor: const Color(0xff0A2342),
            textColor: Colors.white,
            foregroundColor: Colors.white,
          ),
        ],
      );
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
