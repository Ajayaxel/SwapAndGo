import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:swap_app/const/go_button.dart';
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcode) {
    final String? code = barcode.barcodes.first.rawValue;
    if (code != null) {
      // Stop animation & navigate
      _controller.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScanSuccessScreen(),
        ),
      );
    }
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
                MobileScanner(
                  onDetect: _onDetect,
                ),

                // Shaking Scanner Line
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
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
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
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Steps to swap',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('1.  Scan DR Station', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text('2.  Insert old battery', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text('3.  Collect new battery', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Start Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScanSuccessScreen()),
                );
              },
              text: 'START SWAP',
              backgroundColor: Colors.black,
              textColor: Colors.white,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

