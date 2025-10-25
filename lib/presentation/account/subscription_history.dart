import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/subscription_transaction_api/subscription_transaction_api_bloc.dart';
import 'package:swap_app/bloc/subscription_transaction_api/subscription_transaction_api_event.dart';
import 'package:swap_app/bloc/subscription_transaction_api/subscription_transaction_api_state.dart';
import 'package:swap_app/model/subscription_transaction_models.dart';
import 'package:swap_app/presentation/account/subscription_transaction_screen.dart';

class SubscriptionHistoryScreen extends StatelessWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionTransactionApiBloc()
        ..add(FetchSubscriptionTransactionsApi()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Transaction History",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<SubscriptionTransactionApiBloc, SubscriptionTransactionApiState>(
                    builder: (context, state) {
                      if (state is SubscriptionTransactionApiLoading) {
                        return _buildLoadingState();
                      } else if (state is SubscriptionTransactionApiLoaded) {
                        return _buildTransactionList(state.response, context);
                      } else if (state is SubscriptionTransactionApiEmpty) {
                        return _buildNoSubscriptionState(state.message, context);
                      } else if (state is SubscriptionTransactionApiError) {
                        return _buildErrorState(state.message, state.statusCode, context);
                      } else if (state is SubscriptionTransactionApiNetworkError) {
                        return _buildNetworkErrorState(state.message, context);
                      } else {
                        return _buildInitialState();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
          ),
          SizedBox(height: 16),
          Text(
            "Loading transactions...",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff5B626A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(SubscriptionTransactionResponse response, BuildContext context) {
    if (response.data == null || response.data!.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh
        BlocProvider.of<SubscriptionTransactionApiBloc>(context)
            .add(RefreshSubscriptionTransactionsApi());
      },
      child: Column(
        children: [
          // Summary Card
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xff2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xff2E7D32).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Transactions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                    Text(
                      "${response.data!.count}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Paid",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                    Text(
                      "AED ${response.data!.totalPaid}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: response.data!.transactions.length,
              itemBuilder: (context, index) {
                final transaction = response.data!.transactions[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionTransactionScreen(response: response),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction.formattedDate,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${transaction.currency} ${transaction.amount}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _getAmountColor(transaction.status),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: transaction.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    transaction.statusDisplayText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: transaction.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction ID: ${transaction.displayTransactionId}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff5B626A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Payment Method: ${transaction.paymentMethod}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff5B626A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (transaction.paidAt != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    "Paid: ${_formatPaidDate(transaction.paidAt!)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff4CAF50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Color(0xff5B626A).withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No Active Subscription",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff2E7D32),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff5B626A),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
        
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, int? statusCode, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Color(0xffF44336),
          ),
          SizedBox(height: 16),
          Text(
            "Error Loading Transactions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xffF44336),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff5B626A),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<SubscriptionTransactionApiBloc>(context)
                      .add(RefreshSubscriptionTransactionsApi());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2E7D32),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (statusCode == 401) ...[
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to login
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffFF9800),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color: Color(0xffFF9800),
          ),
          SizedBox(height: 16),
          Text(
            "No Internet Connection",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xffFF9800),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff5B626A),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<SubscriptionTransactionApiBloc>(context)
                  .add(RefreshSubscriptionTransactionsApi());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Retry",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Color(0xff5B626A).withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No Transactions Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff2E7D32),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your transaction history will appear here",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff5B626A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Text(
        "Loading...",
        style: TextStyle(
          fontSize: 16,
          color: Color(0xff5B626A),
        ),
      ),
    );
  }

  Color _getAmountColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'completed':
      case 'success':
        return Color(0xff4CAF50);
      case 'pending':
        return Color(0xffFF9800);
      case 'failed':
      case 'cancelled':
        return Color(0xffF44336);
      default:
        return Colors.black;
    }
  }

  String _formatPaidDate(DateTime paidAt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[paidAt.month - 1]} ${paidAt.day}, ${paidAt.hour.toString().padLeft(2, '0')}:${paidAt.minute.toString().padLeft(2, '0')} ${paidAt.hour >= 12 ? 'PM' : 'AM'}';
  }
}

