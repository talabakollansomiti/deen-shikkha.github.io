import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

// নামাজের অ্যালার্ম নোটিফিকেশন
class AlarmService {
  static final AlarmService _i = AlarmService._internal();
  factory AlarmService() => _i;
  AlarmService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _init = false;

  Future<void> init() async {
    if (_init) return;
    tzdata.initializeTimeZones();
    // বাংলাদেশ টাইমজোন
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    } catch (_) {}

    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    _init = true;
  }

  int _idFor(String prayer) {
    const ids = {
      'ফজর': 101,
      'যোহর': 102,
      'আসর': 103,
      'মাগরিব': 104,
      'এশা': 105,
    };
    return ids[prayer] ?? 100;
  }

  // প্রতিদিন নির্দিষ্ট সময়ে অ্যালার্ম
  Future<void> setAlarm(
      String prayer, int hour, int minute) async {
    await init();
    await cancelAlarm(prayer);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _idFor(prayer),
      '🕌 $prayer-এর সময় হয়েছে',
      '$prayer-এর নামাজ পড়ুন',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'namaz_alarms',
          'নামাজের অ্যালার্ম',
          channelDescription: 'প্রতিদিন নামাজের সময় নোটিফিকেশন',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAlarm(String prayer) async {
    await init();
    await _plugin.cancel(_idFor(prayer));
  }
}
