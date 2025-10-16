import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/subscription_plan/subscription_plan_bloc.dart';
import 'package:swap_app/bloc/subscription_plan/subscription_plan_event.dart';
import 'package:swap_app/bloc/subscription_plan/subscription_plan_state.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/model/subscription_plan_model.dart';
import 'package:swap_app/presentation/account/roadside_assistance_screnn.dart';
import 'package:swap_app/presentation/account/sawp_go_connted_screen.dart';
import 'package:swap_app/repo/subscription_plan_repository.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionPlanBloc(SubscriptionPlanRepository())
        ..add(LoadSubscriptionPlans()),
      child: const SubscriptionScreenContent(),
    );
  }
}

class SubscriptionScreenContent extends StatelessWidget {
  const SubscriptionScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SubscriptionPlanBloc>().add(RefreshSubscriptionPlans());
          // Wait for the refresh to complete
          await context.read<SubscriptionPlanBloc>().stream.firstWhere(
            (state) => state is! SubscriptionPlanRefreshing && state is! SubscriptionPlanLoading,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back & Title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Subscription",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
          
                  // First Card
                  _subscriptionCard(
                    title: "Swap & go",
                    description:
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                    buttonText: "View benefits",
                    outlinedButton: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SwapGoConnectScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
          
                  // Second Card
                  _subscriptionCard(
                    title: "Swap & go Road Assistence",
                    description:
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                    buttonText: "Buy",
                    outlinedButton: false,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoadsideAssistanceScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Subscription Plans Section
                  const Text(
                    "Subscription plans",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  // BLoC Consumer for Subscription Plans
                  BlocBuilder<SubscriptionPlanBloc, SubscriptionPlanState>(
                    builder: (context, state) {
                      if (state is SubscriptionPlanLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is SubscriptionPlanLoaded) {
                        return _buildPlansList(state.plans);
                      } else if (state is SubscriptionPlanRefreshing) {
                        return Column(
                          children: [
                            const LinearProgressIndicator(),
                            const SizedBox(height: 16),
                            _buildPlansList(state.currentPlans),
                          ],
                        );
                      } else if (state is SubscriptionPlanError) {
                        if (state.previousPlans != null && state.previousPlans!.isNotEmpty) {
                          return Column(
                            children: [
                              _buildErrorBanner(context, state.message),
                              const SizedBox(height: 16),
                              _buildPlansList(state.previousPlans!),
                            ],
                          );
                        }
                        return _buildErrorWidget(context, state.message);
                      } else if (state is SubscriptionPlanEmpty) {
                        return _buildEmptyWidget();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansList(List<SubscriptionPlan> plans) {
    return Column(
      children: plans
          .where((plan) => plan.isActive) // Only show active plans
          .map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlanCard(plan),
              ))
          .toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffD5DFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Name
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          
          // Plan Description
          Text(
            plan.description,
            style: const TextStyle(fontSize: 15, color: Color(0xff666666)),
          ),
          const SizedBox(height: 16),
          
          // Price
          Row(
            children: [
              Text(
                plan.currency,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xff1D1E20),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                plan.amount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                plan.formattedInterval,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xff1D1E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Choose Plan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add your plan selection logic here
                print('Selected plan: ${plan.name}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7F7F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(
                    color: Color(0xFF0A2342),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
              ),
              child: const Text(
                "Choose plan",
                style: TextStyle(
                  color: Color(0xFF0A2342),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Plan Features
          ...plan.featuresList.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0A2342),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff6D7081),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          
          const SizedBox(height: 8),
          const Divider(
            color: Color(0xffD5DFFF),
            thickness: 1,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              context.read<SubscriptionPlanBloc>().add(RefreshSubscriptionPlans());
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff666666),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SubscriptionPlanBloc>().add(LoadSubscriptionPlans());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2342),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No subscription plans available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff666666),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check back later',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String description,
    required String buttonText,
    required bool outlinedButton,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xff999999)),
          ),
          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            child: outlinedButton
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                : GoButton(
                    onPressed: onPressed,
                    text: buttonText,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    foregroundColor: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }
}
