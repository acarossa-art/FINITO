import 'package:flutter/material.dart';
class NotificaWidget extends StatelessWidget {
  final String frase;
  
  const NotificaWidget({super.key, required this.frase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              frase,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w300,
                height: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
