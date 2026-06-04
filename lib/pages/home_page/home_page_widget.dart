import 'package:flutter/material.dart';
import 'package:finito/pages/lingua/lingua_widget.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LinguaWidget()),
            );
          },
          child: const Text(
            'FINITO',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 50,
              letterSpacing: 9,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
