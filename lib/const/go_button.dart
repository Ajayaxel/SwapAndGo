import 'package:flutter/material.dart';

class GoButton extends StatelessWidget {
  const GoButton({super.key, required this.onPressed, required this.text , required this.backgroundColor , required this.textColor , required this.foregroundColor});

  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text , style: TextStyle(fontSize: 16 ,fontWeight: FontWeight.bold),),
        
      ),
      
    );
  }
}
