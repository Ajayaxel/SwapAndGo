import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/wallet/wallet_bloc.dart';
import 'package:swap_app/bloc/wallet/wallet_event.dart';
import 'package:swap_app/bloc/wallet/wallet_state.dart';
import 'package:swap_app/const/conts_colors.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/account/my_profile.dart';
import 'package:swap_app/presentation/bootmnav/bottm_nav.dart';
import 'package:swap_app/presentation/wallet/payment_webview_screen.dart';
import 'package:swap_app/services/auth_handler.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isPayitSelected = false;
  final TextEditingController _payitController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Exit bottom sheet
  void _showExitBottomSheet(BuildContext context) {
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
                  "Are you sure want to exit?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You will be taken back to Swap & Go app",
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
                      Navigator.of(context).pop(); // Close exit sheet
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
                GoButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const BottomNav(),
                      ),
                      (route) => false,
                    );
                  },
                  text: "Exit",
                  backgroundColor: AppColors.goBlue,
                  textColor: Colors.white,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Initiate payment with API
  void _initiatePayment(BuildContext context) {
    final amount = double.tryParse(_amountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Trigger deposit event
    context.read<WalletBloc>().add(DepositCashEvent(amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(),
      child: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletDepositSuccess) {
            print('🚀 Navigating to payment iframe...');
            print('📍 iframe URL: ${state.depositResponse.data.iframeUrl}');
            // Navigate to WebView screen with iframe URL from API
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaymentWebViewScreen(
                  iframeUrl: state.depositResponse.data.iframeUrl,
                  paymentId: state.depositResponse.data.paymentId,
                  amount: state.depositResponse.data.amount,
                ),
              ),
            );
          } else if (state is WalletError) {
            // Use the new authentication handler
            AuthHandler.handleAuthError(context, state.statusCode, state.message);
          }
        },
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return _buildPaymentScreen(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildPaymentScreen(BuildContext context, WalletState state) {
    final isLoading = state is WalletLoading;
    
    return WillPopScope(
      onWillPop: () async {
        _showExitBottomSheet(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.goBlue,
        body: Column(
          children: [
            // Header & Price Section
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              color: AppColors.goBlue,
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showExitBottomSheet(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Image(
                        image: AssetImage("asset/home/mediumlogo.png"),
                        height: 50,
                        width: 75,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyProfilePage())),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.goBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price Summary",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration:  InputDecoration(
                            hintText: 'Enter amount (AED)',
                            prefixText: 'AED ',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom White Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Options',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Available Offers',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, size: 18, color: Colors.black),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Win flat AED 50 cashback on a...',
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isPayitSelected ? 'Pay it ID / Number' : 'Recommended',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPayitSelected = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isPayitSelected
                            ? TextField(
                                controller: _payitController,
                                keyboardType: TextInputType.number,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Payit ID or Number',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 10, top: 9, right: 10),
                                ),
                              )
                            : Row(
                                children: const [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Payit',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(
                    _amountController.text.isNotEmpty
                        ? 'AED ${_amountController.text}'
                        : 'AED 0.00',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Expanded(
                    child: GoButton(
                      onPressed: isLoading ? null : () => _initiatePayment(context),
                      text: isLoading ? "Processing..." : "Continue",
                      backgroundColor: AppColors.goBlue,
                      textColor: Colors.white,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

