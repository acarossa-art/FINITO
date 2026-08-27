import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';
import 'pages/notifica/notifica_widget.dart';

class CloudMessagingService {
  static String? _initialPhrase;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _ensureAnonymousUser();

    final messaging = FirebaseMessaging.instance;
    await syncPreferences();

    messaging.onTokenRefresh.listen((_) {
      syncPreferences();
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);

    final initialMessage = await messaging.getInitialMessage();
    _initialPhrase = _phraseFrom(initialMessage);
  }

  static Future<void> syncPreferences({
    String? language,
    String? intensity,
  }) async {
    final user = await _ensureAnonymousUser();
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final selectedLanguage = language ?? prefs.getString('lingua');
    final selectedIntensity = intensity ?? prefs.getString('intensita');
    final timeZone = await FlutterTimezone.getLocalTimezone();

    const validLanguages = {
      'italiano',
      'english',
      'zhongwen',
      'nihongo',
      'francese',
      'espanol',
    };
    const validIntensities = {
      'bassa',
      'media',
      'alta',
      'imprevedibile',
    };

    final active = validLanguages.contains(selectedLanguage) &&
        validIntensities.contains(selectedIntensity);

    await FirebaseFirestore.instance
        .collection('devices')
        .doc(user.uid)
        .set({
      'token': token,
      'language': selectedLanguage,
      'intensity': selectedIntensity,
      'timeZone': timeZone.identifier,
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
      'nextNotificationAt': FieldValue.delete(),
      'dayKey': FieldValue.delete(),
      'sentToday': FieldValue.delete(),
      'dailyTarget': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  static void openInitialMessage() {
    final phrase = _initialPhrase;
    if (phrase == null || phrase.isEmpty) return;
    _initialPhrase = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPhrase(phrase);
    });
  }

  static Future<User> _ensureAnonymousUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) return currentUser;
    final credential = await FirebaseAuth.instance.signInAnonymously();
    return credential.user!;
  }

  static String? _phraseFrom(RemoteMessage? message) {
    if (message == null) return null;
    final dataPhrase = message.data['phrase'];
    if (dataPhrase is String && dataPhrase.isNotEmpty) return dataPhrase;
    return message.notification?.body;
  }

  static void _openMessage(RemoteMessage message) {
    final phrase = _phraseFrom(message);
    if (phrase == null || phrase.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPhrase(phrase);
    });
  }

  static void _openPhrase(String phrase) {
    NotificationService.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificaWidget(frase: phrase),
      ),
    );
  }
}
