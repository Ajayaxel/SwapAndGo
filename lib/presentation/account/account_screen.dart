import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/account/history_screen.dart';
import 'package:swap_app/presentation/account/my_profile.dart';
import 'package:swap_app/presentation/account/subscription_screen.dart';
import 'package:swap_app/presentation/account/transaction_history.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
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
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              "https://media.istockphoto.com/id/1682296067/photo/happy-studio-portrait-or-professional-man-real-estate-agent-or-asian-businessman-smile-for.jpg?s=612x612&w=0&k=20&c=9zbG2-9fl741fbTWw5fNgcEEe4ll-JegrGlQQ6m54rg=",
                            ),
                          ),
                          SizedBox(width: 16),

                          if (state is AuthSuccess)
                            Text(
                              state.customer.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 20,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 12),
              Container(
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTile(
                      icon: Icons.list_alt_outlined,
                      title: "My subscriptions",
                      subtitle: "Lorem ipsum",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _buildTile(
                      icon: Icons.history,
                      title: "History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _buildTile(
                      icon: Icons.receipt_long_outlined,
                      title: "Transaction History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TransactionHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              GoButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
                text: "Logout",
                backgroundColor: Colors.black,
                textColor: Colors.white,
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _divider() {
  return Divider(
    height: 1,
    thickness: 1,
    indent: 15,
    endIndent: 15,
    color: Color(0xffE6EAED),
  );
}

Widget _buildTile({
  required IconData icon,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.black),
    title: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xff98989A)),
          )
        : null,
    trailing: const Icon(
      Icons.arrow_forward_ios,
      color: Colors.black,
      size: 20,
    ),
    onTap: onTap,
  );
}
