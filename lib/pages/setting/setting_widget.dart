import '../../notification_service.dart';
import '../../cloud_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingWidget extends StatefulWidget {
  final String lingua;
  const SettingWidget({super.key, required this.lingua});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  String _intensita = '';

  final Map<String, Map<String, String>> testi = {
    'italiano': {'titolo': 'INTENSITA', 'bassa': 'BASSA', 'media': 'MEDIA', 'alta': 'ALTA', 'imprevedibile': 'IMPREVEDIBILE'},
    'english': {'titolo': 'INTENSITY', 'bassa': 'LOW', 'media': 'MEDIUM', 'alta': 'HIGH', 'imprevedibile': 'UNPREDICTABLE'},
    'zhongwen': {'titolo': '强度', 'bassa': '低', 'media': '中', 'alta': '高', 'imprevedibile': '不可预测'},
    'nihongo': {'titolo': '強度', 'bassa': '低い', 'media': '中程度', 'alta': '高い', 'imprevedibile': '予測不能'},
    'francese': {'titolo': 'INTENSITÉ', 'bassa': 'FAIBLE', 'media': 'MOYEN', 'alta': 'ÉLEVÉ', 'imprevedibile': 'IMPRÉVISIBLE'},
    'espanol': {'titolo': 'INTENSIDAD', 'bassa': 'BAJA', 'media': 'MEDIA', 'alta': 'ALTA', 'imprevedibile': 'IMPREVISIBLE'},
  };

  @override
  void initState() {
    super.initState();
    _caricaIntensita();
  }

  Future<void> _caricaIntensita() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _intensita = prefs.getString('intensita') ?? '';
    });
  }

  Future<void> _salvaIntensita(String valore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intensita', valore);
    if (!mounted) return;
    setState(() {
      _intensita = valore;
    });
    await NotificationService.scheduleNotifications(valore, widget.lingua);
    await CloudMessagingService.syncPreferences(
      language: widget.lingua,
      intensity: valore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = testi[widget.lingua] ?? testi['english']!;
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
            Text(t['titolo']!, style: const TextStyle(fontSize: 15, letterSpacing: 7, fontWeight: FontWeight.w300)),
            const SizedBox(height: 40),
            _buildButton(t['bassa']!, 'bassa'),
            const SizedBox(height: 24),
            _buildButton(t['media']!, 'media'),
            const SizedBox(height: 24),
            _buildButton(t['alta']!, 'alta'),
            const SizedBox(height: 24),
            _buildButton(t['imprevedibile']!, 'imprevedibile'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, String value) {
    final selected = _intensita == value;
    return TextButton(
      onPressed: () => _salvaIntensita(value),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : Colors.grey,
          fontSize: 12,
          letterSpacing: 4,
          fontWeight: selected ? FontWeight.w500 : FontWeight.w300,
        ),
      ),
    );
  }
}
