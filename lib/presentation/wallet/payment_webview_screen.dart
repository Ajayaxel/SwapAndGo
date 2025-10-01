import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:swap_app/const/conts_colors.dart';
import 'package:swap_app/presentation/bootmnav/bottm_nav.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String iframeUrl;
  final String paymentId;
  final double amount;

  const PaymentWebViewScreen({
    super.key,
    required this.iframeUrl,
    required this.paymentId,
    required this.amount,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    print('🌐 Loading iframe URL from API: ${widget.iframeUrl}');
    print('💳 Payment ID: ${widget.paymentId}');
    print('💰 Amount: AED ${widget.amount}');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📄 Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('✅ Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            // Check if payment is completed based on URL
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error: ${error.description}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading page: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onUrlChange: (change) {
            print('🔄 URL changed: ${change.url}');
          },
        ),
      )
      ..loadHtmlString(
        """
<html>
<head>
    
</head>
<body>
        <iframe src='${widget.iframeUrl}' width='100%' height='100%'></iframe>",
</body>
</html>
        """
      );
  }

  void _checkPaymentStatus(String url) {
    // Check if URL contains success indicators
    if (url.contains('success') || url.contains('callback') || url.contains('completed')) {
      // _showSuccessBottomSheet();
    } else if (url.contains('cancel') || url.contains('failed')) {
      _showFailureBottomSheet();
    }
  }

  void _showExitBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "asset/home/exit.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to exit?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your payment will be cancelled",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.goBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Continue to payment",
                      style: TextStyle(
                        color: AppColors.goBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.goBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const BottomNav(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Exit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "asset/home/paymentsucces.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "AED ${widget.amount.toStringAsFixed(2)} has been added to your wallet",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.goBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const BottomNav(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFailureBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Failed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your payment could not be processed",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.goBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const BottomNav(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitBottomSheet();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.goBlue,
        appBar: AppBar(
          backgroundColor: AppColors.goBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _showExitBottomSheet(),
          ),
          title: const Text(
            'Complete Payment',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.goBlue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading payment gateway...',
                        style: TextStyle(fontSize: 16),
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
}

