import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:swap_app/model/qr_scan_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swap_app/presentation/qr_scanner/swap_details_screen.dart';
import 'package:swap_app/utils/permission_helper.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  MobileScannerController? scannerController;
  final ImagePicker _imagePicker = ImagePicker();
  
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

  void _initializeScanner() async {
    // Check camera permission before initializing scanner
    final hasPermission = await PermissionHelper.isCameraPermissionGranted();
    if (!hasPermission) {
      final granted = await PermissionHelper.requestCameraPermission();
      if (!granted) {
        setState(() {
          _errorMessage = 'Camera permission is required to scan QR codes';
        });
        return;
      }
    }
    
    scannerController = MobileScannerController();
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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (image != null) {
        setState(() {
          _isScanning = true;
        });

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Processing QR code from image...'),
                ],
              ),
            );
          },
        );

        // Process the image to extract QR code
        await _processImageForQR(image);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processImageForQR(XFile image) async {
    try {
      // Create a temporary scanner controller for image processing
      final MobileScannerController tempController = MobileScannerController();
      
      // Process the image file
      final BarcodeCapture? barcodeCapture = await tempController.analyzeImage(image.path);
      final List<Barcode> barcodes = barcodeCapture?.barcodes ?? [];
      
      // Dispose the temporary controller
      await tempController.dispose();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (barcodes.isNotEmpty) {
        final String? qrCode = barcodes.first.rawValue;
        
        if (qrCode != null) {
          // Parse QR data
          final QRScanData? parsedData = _parseQRData(qrCode);
          
          if (parsedData != null && _validateQRData(parsedData)) {
            // Success case
            setState(() {
              _scanCompleted = true;
              _scannedData = parsedData;
              _errorMessage = null;
              _isScanning = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR code processed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Invalid QR data
            setState(() {
              _errorMessage = 'Invalid QR code format or missing data';
              _isScanning = false;
            });
            _showErrorDialog();
          }
        } else {
          // No QR code found
          setState(() {
            _errorMessage = 'No QR code found in the selected image';
            _isScanning = false;
          });
          _showErrorDialog();
        }
      } else {
        // No barcodes found
        setState(() {
          _errorMessage = 'No QR code found in the selected image';
          _isScanning = false;
        });
        _showErrorDialog();
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      setState(() {
        _errorMessage = 'Error processing image: $e';
        _isScanning = false;
      });
      _showErrorDialog();
    }
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
                Navigator.of(context).pop();
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

  void _onStartSwap() {
    if (!_scanCompleted || _scannedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan a valid QR code first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to swap details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SwapDetailsScreen(
          scannedData: _scannedData!,
        ),
      ),
    );
  }

  void _onScanDetails() {
    if (!_scanCompleted || _scannedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan a valid QR code first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show scanned data details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scanned QR Code Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Battery Code: ${_scannedData!.batteryCode}'),
              Text('Model: ${_scannedData!.model}'),
              Text('Manufacturer: ${_scannedData!.manufacturer}'),
              Text('ID: ${_scannedData!.id}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
          'QR Scanner',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Permission Error Display
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Camera Permission Required',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final granted = await PermissionHelper.requestCameraPermission();
                                if (granted) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                  _initializeScanner();
                                } else {
                                  PermissionHelper.showPermissionDeniedDialog(context, 'camera');
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Grant Camera Permission'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Camera Preview or Placeholder
                  else if (!_scanCompleted)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: _onDetect,
                      ),
                    )
                  else if (_scanCompleted)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'QR Code Scanned Successfully!',
                              style: TextStyle(
                                fontSize: 16,
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
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
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

                  // Animated Scanner Line
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
                          color: _scanCompleted ? Colors.green : Colors.black,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                  // "Scan the QR" text overlay
                  if (!_scanCompleted)
                    const Positioned(
                      bottom: 20,
                      child: Text(
                        'Scan the QR',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Upload QR Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isScanning ? null : _pickImageFromGallery,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isScanning ? Colors.grey.shade300 : Colors.white,
                      border: Border.all(
                        color: _isScanning ? Colors.grey : const Color(0xff0A2342), 
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _isScanning 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0A2342)),
                          ),
                        )
                      : const Icon(
                          Icons.image,
                          color: Color(0xff0A2342),
                          size: 30,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isScanning ? 'Processing...' : 'Upload QR',
                  style: TextStyle(
                    color: _isScanning ? Colors.grey : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // START SWAP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _scanCompleted ? _onStartSwap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _scanCompleted 
                          ? const Color(0xff0A2342) 
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'START SWAP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // SCAN DETAILS Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _scanCompleted ? _onScanDetails : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _scanCompleted 
                            ? const Color(0xff0A2342) 
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'SCAN DETAILS',
                      style: TextStyle(
                        color: _scanCompleted 
                            ? const Color(0xff0A2342) 
                            : Colors.grey.shade400,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}