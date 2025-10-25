import 'package:flutter/material.dart';
import 'package:swap_app/model/subscription_transaction_models.dart';

class SubscriptionTransactionScreen extends StatelessWidget {
  final SubscriptionTransactionResponse response;

  const SubscriptionTransactionScreen({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "Subscription Transactions",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (response.data != null) ...[
                _buildSummaryCard(response.data!),
                SizedBox(height: 16),
                Expanded(
                  child: _buildTransactionList(response.data!.transactions),
                ),
              ] else ...[
                Expanded(
                  child: _buildNoDataState(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SubscriptionTransactionData data) {
    return Container(
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
                "${data.count}",
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
                "AED ${data.totalPaid}",
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
    );
  }

  Widget _buildTransactionList(List<SubscriptionTransaction> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return SubscriptionTransactionCard(transaction: transaction);
      },
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
            "No Transactions Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff2E7D32),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your subscription transactions will appear here",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff5B626A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
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
            "No Data Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xffF44336),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Unable to load transaction data",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff5B626A),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionTransactionCard extends StatelessWidget {
  final SubscriptionTransaction transaction;

  const SubscriptionTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          _showTransactionDetails(context, transaction);
        },
        child: Container(
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
                          color: _getAmountColor(),
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
      ),
    );
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

  String _formatPaidDate(DateTime paidAt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[paidAt.month - 1]} ${paidAt.day}, ${paidAt.hour.toString().padLeft(2, '0')}:${paidAt.minute.toString().padLeft(2, '0')} ${paidAt.hour >= 12 ? 'PM' : 'AM'}';
  }

  void _showTransactionDetails(BuildContext context, SubscriptionTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsModal(transaction: transaction),
    );
  }
}

class TransactionDetailsModal extends StatelessWidget {
  final SubscriptionTransaction transaction;

  const TransactionDetailsModal({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xffE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Transaction Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Color(0xff5B626A)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildDetailRow("Transaction ID", transaction.displayTransactionId),
                _buildDetailRow("Amount", "${transaction.currency} ${transaction.amount}"),
                _buildDetailRow("Status", transaction.statusDisplayText),
                _buildDetailRow("Payment Method", transaction.paymentMethod),
                _buildDetailRow("Billing Date", transaction.formattedBillingDate),
                if (transaction.paidAt != null)
                  _buildDetailRow("Paid At", _formatPaidDate(transaction.paidAt!)),
                _buildDetailRow("Created At", transaction.formattedDate),
                if (transaction.failureReason != null)
                  _buildDetailRow("Failure Reason", transaction.failureReason!),
                SizedBox(height: 20),
                if (transaction.metadata.isNotEmpty) ...[
                  Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2E7D32),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (transaction.metadata['order'] != null)
                          _buildMetadataRow("Order ID", transaction.metadata['order'].toString()),
                        if (transaction.metadata['merchant_order_id'] != null)
                          _buildMetadataRow("Merchant Order", transaction.metadata['merchant_order_id'].toString()),
                        if (transaction.metadata['data_message'] != null)
                          _buildMetadataRow("Message", transaction.metadata['data_message'].toString()),
                        if (transaction.metadata['txn_response_code'] != null)
                          _buildMetadataRow("Response Code", transaction.metadata['txn_response_code'].toString()),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                color: Color(0xff5B626A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff5B626A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaidDate(DateTime paidAt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[paidAt.month - 1]} ${paidAt.day}, ${paidAt.hour.toString().padLeft(2, '0')}:${paidAt.minute.toString().padLeft(2, '0')} ${paidAt.hour >= 12 ? 'PM' : 'AM'}';
  }
}
