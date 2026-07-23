import 'package:flutter/material.dart';
import 'package:finito/pages/setting/setting_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinguaWidget extends StatefulWidget {
  const LinguaWidget({super.key});

  @override
  State<LinguaWidget> createState() => _LinguaWidgetState();
}

class _LinguaWidgetState extends State<LinguaWidget> {
  String _lingua = '';

  @override
  void initState() {
    super.initState();
    _caricaLingua();
  }

  Future<void> _caricaLingua() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lingua = prefs.getString('lingua') ?? '';
    });
  }

  Future<void> _salvaLingua(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lingua', key);
    setState(() {
      _lingua = key;
    });
    if (!mounted) return;
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => SettingWidget(lingua: key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('LANGUAGE',
              style: TextStyle(fontSize: 15, letterSpacing: 7, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 48),
            _buildButton('ITALIANO', 'italiano'),
            const SizedBox(height: 36),
            _buildButton('ENGLISH', 'english'),
            const SizedBox(height: 36),
            _buildButton('中文', 'zhongwen'),
            const SizedBox(height: 36),
            _buildButton('日本語', 'nihongo'),
            const SizedBox(height: 36),
            _buildButton('FRANÇAIS', 'francese'),
            const SizedBox(height: 36),
            _buildButton('ESPAÑOL', 'espanol'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String display, String key) {
    bool selected = _lingua == key;
    return TextButton(
      onPressed: () => _salvaLingua(key),
      child: Text(display,
        style: TextStyle(
          color: selected ? Colors.black : Colors.grey,
          fontSize: 14,
          letterSpacing: 4,
          fontWeight: selected ? FontWeight.w500 : FontWeight.w300,
        ),
      ),
    );
  }
}
