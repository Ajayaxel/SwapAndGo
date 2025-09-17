import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/model/qr_scan_data.dart';
import 'package:swap_app/presentation/station/sacn_details_screen.dart';
import 'package:swap_app/presentation/station/scan_suceess_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  MobileScannerController? scannerController;
  
  // State variables
  bool _isScanning = false;
  bool _scanCompleted = false;
  QRScanData? _scannedData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
    _setupAnimation();
  }

  void _initializeScanner() {
    scannerController = MobileScannerController();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 200,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    scannerController?.dispose();
    super.dispose();
  }

  // Parse QR code data
  QRScanData? _parseQRData(String qrString) {
    try {
      final Map<String, dynamic> jsonData = json.decode(qrString);
      return QRScanData.fromJson(jsonData);
    } catch (e) {
      print('Error parsing QR data: $e');
      return null;
    }
  }

  // Validate QR data
  bool _validateQRData(QRScanData data) {
    return data.batteryCode.isNotEmpty &&
           data.model.isNotEmpty &&
           data.manufacturer.isNotEmpty &&
           data.id.isNotEmpty;
  }

  void _onDetect(BarcodeCapture barcode) {
    if (_scanCompleted || _isScanning) return;

    final String? code = barcode.barcodes.first.rawValue;
    if (code != null) {
      setState(() {
        _isScanning = true;
      });

      // Stop animation
      _controller.stop();
      
      // Parse QR data
      final QRScanData? parsedData = _parseQRData(code);
      
      if (parsedData != null && _validateQRData(parsedData)) {
        // Success case
        setState(() {
          _scanCompleted = true;
          _scannedData = parsedData;
          _errorMessage = null;
        });
        _showSuccessAndNavigate();
      } else {
        // Failure case
        setState(() {
          _errorMessage = 'Invalid QR code format or missing data';
          _isScanning = false;
        });
        _showErrorDialog();
      }
    }
  }

  void _showSuccessAndNavigate() {
    // Show success message briefly
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code scanned successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Navigate to success screen after a brief delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScanSuccessScreen(scannedData: _scannedData),
          ),
        );
      }
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Failed'),
          content: Text(_errorMessage ?? 'Unknown error occurred'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryScanning();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _retryScanning() {
    setState(() {
      _isScanning = false;
      _scanCompleted = false;
      _scannedData = null;
      _errorMessage = null;
    });
    
    // Restart animation
    _controller.repeat(reverse: true);
    
    // Restart scanner
    scannerController?.start();
  }

  void _onStartSwapPressed() {
    if (!_scanCompleted || _scannedData == null) {
      // Show message that scan is required first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan the QR code first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to success screen with scanned data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScanSuccessScreen(scannedData: _scannedData),
      ),
    );
  }

  void _onScanDetailsPressed() {
    if (!_scanCompleted || _scannedData == null) {
      // Show message that scan is required first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan the QR code first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to scan details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanDetailsScreen(scannedData: _scannedData!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Camera Preview
                if (!_scanCompleted)
                  MobileScanner(
                    controller: scannerController,
                    onDetect: _onDetect,
                  )
                else
                  Container(
                    color: Colors.green.shade100,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Scan Completed Successfully!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Scanning indicator overlay
                if (_isScanning && !_scanCompleted)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Processing QR Code...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Animated Scanner Line (only show when actively scanning)
                if (!_scanCompleted && !_isScanning)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value,
                        child: Container(
                          width: 250,
                          height: 2,
                          color: Colors.redAccent,
                        ),
                      );
                    },
                  ),

                // Frame Overlay
                if (!_scanCompleted)
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _scanCompleted ? Colors.green : Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Steps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Steps to swap',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _scanCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: _scanCompleted ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '1. Scan DR Station',
                        style: TextStyle(
                          fontSize: 20,
                          color: _scanCompleted ? Colors.green : Colors.black,
                          fontWeight: _scanCompleted ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2. Insert old battery',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3. Collect new battery',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Start Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GoButton(
              onPressed: _onStartSwapPressed,
              text: 'START SWAP',
              backgroundColor: _scanCompleted 
                  ? const Color(0xff0A2342) 
                  : Colors.grey,
              textColor: Colors.white,
              foregroundColor: Colors.white,
            ),
          ),

          // Scan Details Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: _scanCompleted 
                        ? const Color(0xff0A2342) 
                        : Colors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _onScanDetailsPressed,
                child: Text(
                  "SCAN DETAILS",
                  style: TextStyle(
                    color: _scanCompleted 
                        ? const Color(0xff0A2342) 
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
