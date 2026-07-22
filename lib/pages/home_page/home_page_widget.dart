import 'package:flutter/material.dart';
import 'package:finito/pages/lingua/lingua_widget.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  String _getFrase(BuildContext context) {
    final lingua = Localizations.localeOf(context).languageCode;
    switch (lingua) {
      case 'it':
        return 'Le ali te le fai volando.';
      case 'zh':
        return '翅膀在飞翔中生长。';
      case 'ja':
        return '翼は飛ぶことで育つ。';
      case 'fr':
        return 'Les ailes poussent en volant.';
      case 'es':
        return 'Las alas crecen volando.';
      default:
        return 'Wings grow by flying.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _getFrase(context),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}