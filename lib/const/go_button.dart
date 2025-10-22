import 'package:flutter/material.dart';

class GoButton extends StatelessWidget {
  const GoButton({
    super.key, 
    this.onPressed, 
    required this.text, 
    required this.backgroundColor, 
    required this.textColor, 
    required this.foregroundColor,
    this.isLoading = false,
    this.loadingText,
  });

  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color foregroundColor;
  final bool isLoading;
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? backgroundColor.withOpacity(0.7) : backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: isLoading ? backgroundColor.withOpacity(0.7) : backgroundColor,
          disabledForegroundColor: textColor,
          overlayColor: Colors.transparent, // prevent pressed color overlay
          splashFactory: NoSplash.splashFactory, // remove ripple/splash effect
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 2,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading 
          ? Text(
              loadingText ?? 'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
      ),
    );
  }
}
