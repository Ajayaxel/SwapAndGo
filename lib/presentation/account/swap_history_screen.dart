import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/swap_history/swap_history_bloc.dart';
import 'package:swap_app/bloc/swap_history/swap_history_event.dart';
import 'package:swap_app/bloc/swap_history/swap_history_state.dart';
import 'package:swap_app/model/swap_history_model.dart';
import 'package:swap_app/repo/swap_history_repository.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SwapHistoryBloc(SwapHistoryRepository())..add(LoadSwapHistory()),
      child: const HistoryScreenContent(),
    );
  }
}

class HistoryScreenContent extends StatelessWidget {
  const HistoryScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SwapHistoryBloc, SwapHistoryState>(
                  builder: (context, state) {
                    if (state is SwapHistoryLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff45C85A),
                        ),
                      );
                    } else if (state is SwapHistoryEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No swap history yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your swap transactions will appear here",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is SwapHistoryError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Error",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<SwapHistoryBloc>().add(
                                  LoadSwapHistory(),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Retry"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff45C85A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is SwapHistoryLoaded ||
                        state is SwapHistoryRefreshing ||
                        state is SwapHistoryLoadingMore) {
                      final transactions = state is SwapHistoryLoaded
                          ? state.transactions
                          : state is SwapHistoryRefreshing
                          ? state.currentTransactions
                          : (state as SwapHistoryLoadingMore)
                                .currentTransactions;

                      final pagination = state is SwapHistoryLoaded
                          ? state.pagination
                          : state is SwapHistoryLoadingMore
                          ? state.pagination
                          : null;

                      return RefreshIndicator(
                        color: const Color(0xff45C85A),
                        onRefresh: () async {
                          context.read<SwapHistoryBloc>().add(
                            RefreshSwapHistory(),
                          );
                        },
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            if (index < transactions.length) {
                              return SwapCard(transaction: transactions[index]);
                            } else if (pagination?.hasNextPage == true) {
                              // Load more button
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: state is SwapHistoryLoadingMore
                                      ? const CircularProgressIndicator(
                                          color: Color(0xff45C85A),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: () {
                                            context.read<SwapHistoryBloc>().add(
                                              LoadMoreSwapHistory(),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.arrow_downward,
                                          ),
                                          label: const Text("Load More"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xff45C85A,
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            }
                            return null;
                          },
                          itemCount:
                              transactions.length +
                              (pagination?.hasNextPage == true ? 1 : 0),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwapCard extends StatelessWidget {
  final SwapTransaction transaction;

  const SwapCard({super.key, required this.transaction});

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMMM dd, hh:mm a');
    return formatter.format(dateTime);
  }

  String _formatDuration(DateTime transactionDate) {
    final now = DateTime.now();
    final difference = now.difference(transactionDate);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inDays < 30) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else {
      final months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''} ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with Date, Time and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(transaction.transactionDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.formattedType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff66696E),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.isCompleted
                            ? const Color(0xff45C85A).withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transaction.isCompleted ? "Completed" : "In Progress",
                        style: TextStyle(
                          fontSize: 12,
                          color: transaction.isCompleted
                              ? const Color(0xff45C85A)
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xffE7E7E7)),
            const SizedBox(height: 12),

            // Row with Battery Icon, Code and Time
            Row(
              children: [
                Icon(
                  Icons.battery_charging_full,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.battery?.batteryCode ??
                            transaction.batteryId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff5B626A),
                        ),
                      ),
                      Text(
                        "Charge:${transaction.battery?.currentCharge}%",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff5B626A),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                 
                    SizedBox(height: 4),
                    Text(
                      "Battery Status: ${transaction.battery?.status}",
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 2),
                    Text(
                      "Max charge: ${transaction.battery?.maxCharge}%",
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),

            if (transaction.station != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 12),

              // Station Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.ev_station, color: Color(0xff45C85A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.station!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        if (transaction.station!.address != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            transaction.station!.address!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff7A7B7D),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.notes!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
