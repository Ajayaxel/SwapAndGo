import 'package:flutter/material.dart';
import 'package:swap_app/model/qr_scan_data.dart';

class SwapDetailsScreen extends StatelessWidget {
  final QRScanData scannedData;

  const SwapDetailsScreen({
    super.key,
    required this.scannedData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Swap Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff0A2342), Color(0xff1e3a5f)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.battery_charging_full,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Battery Swap Ready',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Battery Code: ${scannedData.batteryCode}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Battery Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Battery Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0A2342),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInfoRow(
                    icon: Icons.qr_code,
                    label: 'Battery Code',
                    value: scannedData.batteryCode,
                    color: const Color(0xff0A2342),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    icon: Icons.devices,
                    label: 'Model',
                    value: scannedData.model,
                    color: const Color(0xff2E7D32),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    icon: Icons.business,
                    label: 'Manufacturer',
                    value: scannedData.manufacturer,
                    color: const Color(0xff1976D2),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    icon: Icons.fingerprint,
                    label: 'Battery ID',
                    value: scannedData.id,
                    color: const Color(0xff7B1FA2),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Scan Time',
                    value: _formatTimestamp(scannedData.timestamp),
                    color: const Color(0xffF57C00),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Battery Verified',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This battery is ready for swap',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                // PROCEED WITH SWAP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _proceedWithSwap(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0A2342),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'PROCEED WITH SWAP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // SCAN ANOTHER Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _scanAnother(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xff0A2342),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SCAN ANOTHER',
                      style: TextStyle(
                        color: Color(0xff0A2342),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  void _proceedWithSwap(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Swap'),
          content: const Text(
            'Are you sure you want to proceed with this battery swap?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to swap process or show success
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Swap process initiated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // You can navigate to the next screen here
                // Navigator.push(context, MaterialPageRoute(builder: (context) => SwapProcessScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0A2342),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _scanAnother(BuildContext context) {
    // Go back to QR scanner
    Navigator.pop(context);
  }
}
