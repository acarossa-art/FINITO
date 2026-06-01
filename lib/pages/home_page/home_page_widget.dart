import 'package:flutter/material.dart';
import 'package:finito/pages/lingua/lingua_widget.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
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
              const SizedBox(height: 60),
              const Text(
                'Le ali te le fai volando.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}