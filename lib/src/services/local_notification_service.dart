import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  // INFO: Constructor
  LocalNotificationService();

  final _localNotificationService = FlutterLocalNotificationsPlugin();

  Future<void> init() async{
    const AndroidInitializationSettings androidSettings = 
      AndroidInitializationSettings('ic_stat_menthor_icon');
  
    DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings (
        requestAlertPermission: true, 
        requestBadgePermission: true, 
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
  
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings);

    _localNotificationService.initialize(initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
  }

  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {}

  void _onDidReceiveNotificationResponse(NotificationResponse details) {}

  Future<void> showNotification({required int id, required String title, required String body}) async{
    final details = await _notificationsDetails();
    await _localNotificationService.show(id, title, body, details);
  }

  Future<NotificationDetails> _notificationsDetails() async{
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId', 
      'channelName',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.max);

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }
}