import 'package:flutter/material.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/bootmnav/bottm_nav.dart';

class ScanSuccessScreen extends StatelessWidget {
  const ScanSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16 , vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60,),
            // Green check circle
                   Image.asset('asset/home/tic.png', fit: BoxFit.contain, height: 200,),
            const SizedBox(height: 40),

            // Success text
            const Text(
              'Swap Successful',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Description text
            const Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.4,
              ),
            ),

           const Spacer(),

            // DONE button
           GoButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BottomNav()));
           }, text: 'DONE', backgroundColor: Colors.black, textColor: Colors.white, foregroundColor: Colors.white),
           const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
