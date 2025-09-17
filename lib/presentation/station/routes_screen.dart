import 'package:flutter/material.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Map
          Image.asset("asset/home/Route.png", fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 50),
            child: IconButton(
              icon: const Icon(Icons.arrow_back , color: Colors.black , size: 25,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}