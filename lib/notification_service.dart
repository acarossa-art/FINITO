import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'frasi.dart';
import 'pages/notifica/notifica_widget.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final Random _random = Random();
  static String? _initialPayload;

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        _openPhrase(response.payload);
      },
    );

    final launchDetails =
        await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _initialPayload = launchDetails?.notificationResponse?.payload;
    }
  }

  static void openInitialNotification() {
    final payload = _initialPayload;
    if (payload == null || payload.isEmpty) return;
    _initialPayload = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPhrase(payload);
    });
  }

  static void _openPhrase(String? phrase) {
    if (phrase == null || phrase.isEmpty) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificaWidget(frase: phrase),
      ),
    );
    replenishIfNeeded();
  }

  static Future<void> _requestPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static int _dailyCount(String intensity) {
    switch (intensity) {
      case 'bassa':
        return 2;
      case 'media':
        return 4;
      case 'alta':
        return 6;
      case 'imprevedibile':
        return _random.nextInt(11);
      default:
        return 0;
    }
  }

  static Future<void> scheduleNotifications(
    String intensity,
    String language, {
    bool replaceExisting = true,
  }) async {
    await _requestPermission();
    if (replaceExisting) {
      await _notifications.cancelAll();
    }

    final prefs = await SharedPreferences.getInstance();
    final phrases = Frasi.tutte[language] ?? Frasi.tutte['english']!;
    final orderKey = 'phrase_order_$language';
    final positionKey = 'phrase_position_$language';
    var order = prefs.getStringList(orderKey)?.map(int.parse).toList() ?? <int>[];
    var position = prefs.getInt(positionKey) ?? 0;

    if (order.length != phrases.length ||
        order.toSet().length != phrases.length ||
        order.any((index) => index < 0 || index >= phrases.length)) {
      order = List<int>.generate(phrases.length, (index) => index)..shuffle(_random);
      position = 0;
    }

    String nextPhrase() {
      if (position >= order.length) {
        order.shuffle(_random);
        position = 0;
      }
      final phrase = phrases[order[position]];
      position++;
      return phrase;
    }

    final now = tz.TZDateTime.now(tz.local);
    var notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000000);
    var scheduledCount = 0;
    var dayOffset = 0;

    while (scheduledCount < 60 && dayOffset < 90) {
      final count = _dailyCount(intensity);
      final usedMinutes = <int>{};

      for (var i = 0; i < count && scheduledCount < 60; i++) {
        var minuteOfDay = 0;
        do {
          minuteOfDay = _random.nextInt(24 * 60);
        } while (usedMinutes.contains(minuteOfDay));
        usedMinutes.add(minuteOfDay);

        final hour = minuteOfDay ~/ 60;
        final minute = minuteOfDay % 60;
        final scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + dayOffset,
          hour,
          minute,
        );

        if (!scheduledDate.isAfter(now.add(const Duration(minutes: 1)))) {
          continue;
        }

        final phrase = nextPhrase();
        final androidDetails = AndroidNotificationDetails(
          'finito_messages',
          'Messaggi FINITO',
          channelDescription: 'Notifiche esistenziali di FINITO',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
          styleInformation: BigTextStyleInformation(
            phrase,
            contentTitle: 'FINITO',
          ),
        );
        const iosDetails = DarwinNotificationDetails();

        await _notifications.zonedSchedule(
          id: notificationId,
          title: 'FINITO',
          body: phrase,
          scheduledDate: scheduledDate,
          notificationDetails: NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: phrase,
        );
        notificationId++;
        scheduledCount++;
      }
      dayOffset++;
    }

    await prefs.setStringList(orderKey, order.map((index) => index.toString()).toList());
    await prefs.setInt(positionKey, position);
  }

  static Future<void> replenishIfNeeded() async {
    final pending = await _notifications.pendingNotificationRequests();
    if (pending.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final intensity = prefs.getString('intensita');
    final language = prefs.getString('lingua');
    const validIntensities = {'bassa', 'media', 'alta', 'imprevedibile'};

    if (intensity == null ||
        language == null ||
        validIntensities.contains(intensity) == false) {
      return;
    }

    await scheduleNotifications(
      intensity,
      language,
      replaceExisting: false,
    );
  }
}
