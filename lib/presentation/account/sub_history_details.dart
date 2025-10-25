import 'package:flutter/material.dart';
import 'package:swap_app/model/subscription_transaction_models.dart';

class HistoryDetails extends StatelessWidget {
  final SubscriptionTransaction transaction;
  final SubscriptionPlan? plan;

  const HistoryDetails({
    super.key,
    required this.transaction,
    this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Black header with date and back arrow
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.formattedDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (transaction.status.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              transaction.statusDisplayText,
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction details
                    _buildTransactionDetails(),
                    
                    SizedBox(height: 24),
                    
                    // Title
                    Text(
                      "Transaction Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
        
                    SizedBox(height: 16),
        
                    // Transaction info
                    _buildInfoRow("Transaction ID", transaction.displayTransactionId),
                    _buildInfoRow("Payment Method", transaction.paymentMethod),
                    _buildInfoRow("Amount", "${transaction.currency} ${transaction.amount}"),
                    _buildInfoRow("Status", transaction.statusDisplayText),
                    _buildInfoRow("Billing Date", transaction.formattedBillingDate),
                    if (transaction.paidAt != null)
                      _buildInfoRow("Paid At", _formatDateTime(transaction.paidAt!)),
                    _buildInfoRow("Created At", _formatDateTime(transaction.createdAt)),
                    
                    if (transaction.failureReason != null) ...[
                      SizedBox(height: 16),
                      _buildInfoRow("Failure Reason", transaction.failureReason!),
                    ],
                    
                    SizedBox(height: 24),
                    
                    // Payment details from metadata
                    if (transaction.metadata.isNotEmpty) ...[
                      Text(
                        "Payment Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            if (transaction.metadata['order'] != null)
                              _buildInfoRow("Order ID", transaction.metadata['order'].toString()),
                            if (transaction.metadata['merchant_order_id'] != null)
                              _buildInfoRow("Merchant Order", transaction.metadata['merchant_order_id'].toString()),
                            if (transaction.metadata['data_message'] != null)
                              _buildInfoRow("Message", transaction.metadata['data_message'].toString()),
                            if (transaction.metadata['txn_response_code'] != null)
                              _buildInfoRow("Response Code", transaction.metadata['txn_response_code'].toString()),
                          ],
                        ),
                      ),
                    ],
                    
                    if (plan != null) ...[
                      SizedBox(height: 24),
                      _buildPlanInfo(),
                    ],
                    
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Amount",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff5D6067),
                ),
              ),
              Text(
                "${transaction.currency} ${transaction.amount}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getAmountColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff5D6067),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfo() {
    if (plan == null) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subscription Plan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildInfoRow("Plan Name", plan!.name),
              _buildInfoRow("Amount", "${plan!.currency} ${plan!.amount}"),
              _buildInfoRow("Billing Cycle", plan!.billingCycle),
              _buildInfoRow("Sessions", "${plan!.swappingSessions} swapping sessions"),
              _buildInfoRow("Status", plan!.isActive ? "Active" : "Inactive"),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getAmountColor() {
    switch (transaction.status.toLowerCase()) {
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

  Color _getStatusColor() {
    switch (transaction.status.toLowerCase()) {
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
        return Color(0xff757575);
    }
  }
}
