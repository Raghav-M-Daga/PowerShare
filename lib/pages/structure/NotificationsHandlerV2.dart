import 'package:flutter/foundation.dart';

// #1
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// #2
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class LocalNoticeService {
  // Singleton of the LocalNoticeService
  static final LocalNoticeService _notificationService =
      LocalNoticeService._internal();

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory LocalNoticeService() {
    return _notificationService;
  }

  LocalNoticeService._internal();

  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = IOSInitializationSettings(requestSoundPermission: false);

    const initSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  void addNotification(String title, String body, String description,
      {String channel = 'default'}) async {
    // #3
    const iosDetail = null;

    final androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
      description,
      playSound: true,
      importance: Importance.max,
      // icon: 'assets/res_notification.png', //TODO: Icon is in assets, but it needs to be linked here as a resource appropriately.
    );

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    // #4
    const id = 0;

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      noticeDetail,
    );
  }

  void cancelAllNotification() {
    _localNotificationsPlugin.cancelAll();
  }
}
