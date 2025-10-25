// // presentation/account/payment_iframe_screen.dart
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:swap_app/model/payment_models.dart';

// class PaymentIframeScreen extends StatefulWidget {
//   final PaymentInitializationResponse paymentResponse;

//   const PaymentIframeScreen({
//     super.key,
//     required this.paymentResponse,
//   });

//   @override
//   State<PaymentIframeScreen> createState() => _PaymentIframeScreenState();
// }

// class _PaymentIframeScreenState extends State<PaymentIframeScreen> {
//   late WebViewController _webViewController;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String? _errorMessage;
//   bool _isExiting = false; // Prevent multiple exit attempts
//   bool _isDialogOpen = false; // Prevent multiple dialogs
//   DateTime? _lastBackPress; // Track last back press for debouncing

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//   }

//   void _initializeWebView() {
//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//               _hasError = false;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               _isLoading = false;
//             });
//           },
//           onWebResourceError: (WebResourceError error) {
//             setState(() {
//               _isLoading = false;
//               _hasError = true;
//               _errorMessage = error.description;
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Handle payment success/failure callbacks
//             final url = request.url.toLowerCase();
//             if (url.contains('success') || 
//                 url.contains('payment/success') ||
//                 url.contains('payment/callback') ||
//                 url.contains('completed') ||
//                 url.contains('approved')) {
//               _handlePaymentCallback(request.url);
//               return NavigationDecision.prevent;
//             } else if (url.contains('failure') ||
//                        url.contains('payment/failure') ||
//                        url.contains('cancelled') ||
//                        url.contains('declined')) {
//               _handlePaymentCallback(request.url);
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.paymentResponse.data.paymentUrl));
//   }

//   void _handlePaymentCallback(String url) {
//     // Handle payment success/failure based on URL
//     final lowerUrl = url.toLowerCase();
//     if (lowerUrl.contains('success') || 
//         lowerUrl.contains('payment/success') ||
//         lowerUrl.contains('completed') ||
//         lowerUrl.contains('approved')) {
//       _showSuccessDialog(context, 'Payment completed successfully!');
//     } else if (lowerUrl.contains('failure') || 
//                lowerUrl.contains('payment/failure') ||
//                lowerUrl.contains('cancelled') ||
//                lowerUrl.contains('declined')) {
//       _showFailureDialog(context, 'Payment failed. Please try again.');
//     }
//   }

//   // Handle back button press with confirmation
//   Future<bool> _onWillPop() async {
//     // Prevent multiple dialogs and rapid clicks
//     if (_isDialogOpen || _isExiting) {
//       return false;
//     }
    
//     // Debounce rapid back button presses (within 1 second)
//     final now = DateTime.now();
//     if (_lastBackPress != null && 
//         now.difference(_lastBackPress!).inMilliseconds < 1000) {
//       return false;
//     }
//     _lastBackPress = now;
    
//     _isDialogOpen = true;
//     final result = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           title: const Text(
//             'Exit Payment?',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: const Text(
//             'Are you sure you want to exit the payment process? Your payment will not be completed.',
//             style: TextStyle(fontSize: 14),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _isDialogOpen = false;
//                 });
//                 Navigator.pop(context, false); // Don't exit
//               },
//               child: const Text(
//                 'Continue Payment',
//                 style: TextStyle(
//                   color: Color(0xFF0A2342),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _isExiting = true;
//                   _isDialogOpen = false;
//                 });
//                 // Close dialog and exit
//                 Navigator.of(context).pop(true); // Exit
//                 // Add a small delay to ensure dialog is closed before navigation
//                 Future.delayed(const Duration(milliseconds: 100), () {
//                   _safeNavigateBack();
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//               ),
//               child: const Text('Exit'),
//             ),
//           ],
//         );
//       },
//     );
    
//     // Reset dialog state
//     setState(() {
//       _isDialogOpen = false;
//     });
    
//     return result ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//       backgroundColor: const Color(0xfff5f5f5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.black,
//           ),
//           onPressed: _isExiting || _isDialogOpen ? null : () async {
//             // Check debouncing for AppBar back button too
//             final now = DateTime.now();
//             if (_lastBackPress != null && 
//                 now.difference(_lastBackPress!).inMilliseconds < 1000) {
//               return;
//             }
            
//             final shouldExit = await _onWillPop();
//             if (shouldExit) {
//               _safeNavigateBack();
//             }
//           },
//         ),
//         title: const Text(
//           'Payment',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Payment Info Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: Colors.white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.paymentResponse.data.plan.name,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Text(
//                       widget.paymentResponse.data.currency,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.normal,
//                         color: Color(0xff1D1E20),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       widget.paymentResponse.data.amount,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // WebView Container
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Stack(
//                   children: [
//                     // WebView
//                     WebViewWidget(controller: _webViewController),
                    
//                     // Loading indicator
//                     if (_isLoading)
//                       const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Color(0xFF0A2342),
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'Loading payment page...',
//                               style: TextStyle(
//                                 color: Color(0xff666666),
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
                    
//                     // Error state
//                     if (_hasError)
//                       Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.error_outline,
//                               size: 64,
//                               color: Colors.red.shade300,
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Payment Error',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.red,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _errorMessage ?? 'Failed to load payment page',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xff666666),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             ElevatedButton.icon(
//                               onPressed: () {
//                                 setState(() {
//                                   _hasError = false;
//                                   _isLoading = true;
//                                 });
//                                 _webViewController.loadRequest(
//                                   Uri.parse(widget.paymentResponse.data.paymentUrl),
//                                 );
//                               },
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Retry'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF0A2342),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 24,
//                                   vertical: 12,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       ),
//     );
//   }

//   void _showSuccessDialog(BuildContext context, String message) {
//     // Prevent multiple success dialogs
//     if (_isExiting) return;
    
//     _isExiting = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 Icons.check_circle,
//                 color: Colors.green.shade600,
//                 size: 28,
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Payment Successful',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(fontSize: 14),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 // Navigate back to subscription screen and show success message
//                 if (context.mounted) {
//                   Navigator.of(context).pop(); // Go back to subscription screen
//                   _navigateToSubscriptionPage(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//               child: const Text('Continue'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showFailureDialog(BuildContext context, String message) {
//     // Prevent multiple failure dialogs
//     if (_isExiting) return;
    
//     _isExiting = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 Icons.cancel,
//                 color: Colors.red.shade600,
//                 size: 28,
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Payment Failed',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(fontSize: 14),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 if (context.mounted) {
//                   Navigator.of(context).pop(); // Go back to subscription screen
//                 }
//               },
//               child: const Text('Try Again'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _navigateToSubscriptionPage(BuildContext context) {
//     // Show success message on subscription screen
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 SizedBox(width: 8),
//                 Text('Subscription activated successfully!'),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 4),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     });
//   }

//   // Safe navigation method to prevent multiple navigations
//   void _safeNavigateBack() {
//     if (!_isExiting && context.mounted) {
//       setState(() {
//         _isExiting = true;
//       });
//       Navigator.of(context).pop();
//     }
//   }
// }