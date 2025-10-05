import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/qrcode/qrcode_bloc.dart';

class QrCodeExampleWidget extends StatelessWidget {
  const QrCodeExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrcodeBloc, QrcodeState>(
      listener: (context, state) {
        if (state is QrcodeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('QR Code processed successfully: ${state.message ?? 'Success'}'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is QrcodeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // QR Code Input Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter QR Code',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (qrCode) {
                  if (qrCode.isNotEmpty) {
                    context.read<QrcodeBloc>().add(
                      QrCodeCheckoutRequested(qrCode: qrCode),
                    );
                  }
                },
              ),
            ),
            
            // Process Button
            ElevatedButton(
              onPressed: () {
                // Example QR code - replace with actual scanned code
                const exampleQrCode = 'SAM-GRI-0049-2a4a';
                context.read<QrcodeBloc>().add(
                  QrCodeCheckoutRequested(qrCode: exampleQrCode),
                );
              },
              child: const Text('Process Example QR Code'),
            ),
            
            // Reset Button
            ElevatedButton(
              onPressed: () {
                context.read<QrcodeBloc>().add(const QrCodeReset());
              },
              child: const Text('Reset'),
            ),
            
            // State Display
            const SizedBox(height: 20),
            _buildStateDisplay(state),
          ],
        );
      },
    );
  }

  Widget _buildStateDisplay(QrcodeState state) {
    if (state is QrcodeInitial) {
      return const Text('Ready to scan QR code');
    } else if (state is QrcodeLoading) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text('Processing QR code: ${state.qrCode}'),
        ],
      );
    } else if (state is QrcodeSuccess) {
      return Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          Text('Success! QR Code: ${state.qrCode}'),
          if (state.message != null) Text('Message: ${state.message}'),
          if (state.data != null) 
            Text('Data: ${state.data.toString()}'),
        ],
      );
    } else if (state is QrcodeError) {
      return Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text('Error with QR Code: ${state.qrCode}'),
          Text('Error: ${state.error}'),
        ],
      );
    }
    
    return const Text('Unknown state');
  }
}

/// Example usage in a screen
class QrCodeExampleScreen extends StatelessWidget {
  const QrCodeExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Example'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const QrCodeExampleWidget(),
    );
  }
}
