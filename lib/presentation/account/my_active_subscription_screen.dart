import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/active_subscription/active_subscription_bloc.dart';
import 'package:swap_app/bloc/active_subscription/active_subscription_event.dart';
import 'package:swap_app/bloc/active_subscription/active_subscription_state.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/model/active_subscription_models.dart';
import 'package:swap_app/services/active_subscription_service.dart';

class MyActiveSubscriptionScreen extends StatelessWidget {
  const MyActiveSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveSubscriptionBloc(
        activeSubscriptionService: ActiveSubscriptionService(),
      )..add(FetchActiveSubscription()),
      child: const MyActiveSubscriptionView(),
    );
  }
}

class MyActiveSubscriptionView extends StatelessWidget {
  const MyActiveSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Active Subscription',
          style: TextStyle(
            color: Color(0xff333333),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ActiveSubscriptionBloc, ActiveSubscriptionState>(
        listener: (context, state) {
          if (state is ActiveSubscriptionCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            // Navigate back or refresh
            Navigator.pop(context);
          } else if (state is ActiveSubscriptionPaymentUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is ActiveSubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is ActiveSubscriptionNetworkError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ActiveSubscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4CAF50)),
              ),
            );
          } else if (state is ActiveSubscriptionLoaded) {
            return _buildSubscriptionDetails(context, state);
          } else if (state is ActiveSubscriptionEmpty) {
            return _buildEmptyState(context, state.message);
          } else if (state is ActiveSubscriptionError) {
            return _buildErrorState(context, state.message);
          } else if (state is ActiveSubscriptionNetworkError) {
            return _buildNetworkErrorState(context, state.message);
          } else if (state is ActiveSubscriptionCancelling) {
            return _buildLoadingState(context, 'Cancelling subscription...');
          } else if (state is ActiveSubscriptionUpdatingPayment) {
            return _buildLoadingState(context, 'Updating payment method...');
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildSubscriptionDetails(
    BuildContext context,
    ActiveSubscriptionLoaded state,
  ) {
    final subscription = state.subscription;
    final plan = state.plan;
    final transactions = state.transactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription Status Card
          _buildStatusCard(context, subscription),
          const SizedBox(height: 16),

          // Plan Details Card
          _buildPlanDetailsCard(context, plan),
          const SizedBox(height: 16),

          // Billing Information Card
          _buildBillingInfoCard(context, subscription),
          const SizedBox(height: 16),

          // Recent Transactions Card
          if (transactions.isNotEmpty) ...[
            _buildTransactionsCard(context, transactions),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          _buildActionButtons(context, subscription),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    ActiveSubscriptionData subscription,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: subscription.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription.statusDisplayText,
                  style: TextStyle(
                    color: subscription.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: subscription.statusColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Subscription Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subscription.isActive
                ? 'Your subscription is active and running smoothly'
                : 'Your subscription is currently inactive',
            style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard(BuildContext context, SubscriptionPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xff4CAF50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.formattedAmount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.intervalDisplayText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              plan.description!,
              style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
            ),
          ],
          if (plan.planFeatures.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Plan Features',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 8),
            ...plan.planFeatures.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xff4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingInfoCard(
    BuildContext context,
    ActiveSubscriptionData subscription,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff333333),
            ),
          ),
          const SizedBox(height: 16),
          _buildBillingInfoRow('Started', subscription.formattedStartDate),
          const SizedBox(height: 12),
          _buildBillingInfoRow(
            'Next Billing',
            subscription.formattedNextBillingDate,
          ),
          const SizedBox(height: 12),
          _buildBillingInfoRow(
            'Days Remaining',
            '${subscription.daysUntilNextBilling} days',
          ),
          if (subscription.cardLastFour != null) ...[
            const SizedBox(height: 12),
            _buildBillingInfoRow(
              'Payment Method',
              '**** ${subscription.cardLastFour}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff333333),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsCard(
    BuildContext context,
    List<SubscriptionTransaction> transactions,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff333333),
            ),
          ),
          const SizedBox(height: 16),
          ...transactions
              .take(3)
              .map((transaction) => _buildTransactionItem(transaction)),
          if (transactions.length > 3) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full transaction history
                },
                child: const Text(
                  'View All Transactions',
                  style: TextStyle(
                    color: Color(0xff4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(SubscriptionTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt,
              color: transaction.statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.formattedBillingDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff666666),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ActiveSubscriptionData subscription,
  ) {
    // Don't show cancel button if subscription is already cancelled or inactive
    if (subscription.status.toLowerCase() == 'cancelled' || 
        subscription.status.toLowerCase() == 'canceled' ||
        subscription.status.toLowerCase() == 'inactive') {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: GoButton(
            onPressed: () {
              _showCancelSubscriptionDialog(context);
            },
            text: "cancel subscription",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            foregroundColor: Colors.white,
          ),
        ),

      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xff4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.subscriptions,
                size: 40,
                color: Color(0xff4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Subscription',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to subscription plans
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                backgroundColor: const Color(0xff4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Browse Plans',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Subscription',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ActiveSubscriptionBloc, ActiveSubscriptionState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<ActiveSubscriptionBloc>().add(
                      RefreshActiveSubscription(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0xff4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.wifi_off, size: 40, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              'Network Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ActiveSubscriptionBloc, ActiveSubscriptionState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<ActiveSubscriptionBloc>().add(
                      RefreshActiveSubscription(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0xff4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4CAF50)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Color(0xff666666)),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel your subscription? This action cannot be undone.'),
            const SizedBox(height: 16),
            const Text(
              'Reason for cancellation (optional):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason for cancellation...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ActiveSubscriptionBloc>().add(
                CancelActiveSubscription(
                  reason: reasonController.text.trim().isNotEmpty 
                      ? reasonController.text.trim() 
                      : null,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF44336),
            ),
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

}
