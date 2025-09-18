// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, defaultTargetPlatform;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/widgets.dart'; // Import for defaultTargetPlatform and WidgetsFlutterBinding

part 'notification_service.g.dart';

// --- TOP-LEVEL BACKGROUND NOTIFICATION HANDLER ---
// This function must be a top-level function or a static method.
// The @pragma('vm:entry-point') annotation is crucial for Flutter to find it
// when the app is in the background or terminated.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // This callback runs when a notification is tapped while the app is
  // in the background or terminated.
  final String? payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    debugPrint('Background Notification Tapped! Payload: $payload');

    // Example: Handle different payload types for deep linking.
    // In a real app, you would likely use a routing solution (e.g., go_router)
    // that can handle deep links to navigate to a specific screen
    // even if the app was terminated. This might involve a slightly delayed
    // navigation after the app fully initializes.
    if (payload.startsWith('assignment_')) {
      final assignmentId = payload.substring('assignment_'.length);
      debugPrint('Attempting background navigation to assignment: $assignmentId');
      // For actual navigation from background, you would need to:
      // 1. Ensure WidgetsFlutterBinding is initialized (already done in main).
      // 2. Potentially re-initialize Riverpod/routing if necessary for deep links.
      // 3. Use a GlobalKey<NavigatorState> or a routing package's deep link handling.
      // Example (pseudo-code, requires navigatorKey setup):
      // Future.delayed(Duration(milliseconds: 100), () {
      //   navigatorKey.currentState?.pushNamed('/assignmentDetails', arguments: assignmentId);
      // });
    }
  }
}

// Riverpod provider for NotificationService.
// `keepAlive: true` ensures the service remains initialized throughout the app's lifecycle.
@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  final service = NotificationService();
  service.init(); // Initialize the service when it's first accessed
  return service;
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint("Notifications are not supported on web.");
      return;
    }

    // Initialize timezone data for scheduled notifications
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(tz.local.name)); // Set to device's local timezone

    // --- Android Initialization Settings ---
    // Make sure 'ic_notification' is created via Android Studio's Image Asset studio
    // or manually placed in `mipmap` folders (e.g., `mipmap-hdpi/ic_notification.png`)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification'); // Referencing the new icon

    // --- iOS Initialization Settings ---
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin with settings and handlers
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveForegroundNotificationResponse, // For foreground taps
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,      // For background/terminated taps (top-level function)
    );

    // Request necessary permissions (e.g., Android 13+ notification permission, iOS permissions)
    await _requestPermissions();
  }

  // --- Permission Request Helper ---
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
       // Request permission for Android 13+ (API 33+)
       final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
           flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
               AndroidFlutterLocalNotificationsPlugin>();
       if (androidImplementation != null) {
         await androidImplementation.requestNotificationsPermission();
       }
    }
  }

  // --- HANDLER FOR FOREGROUND NOTIFICATION TAPS ---
  // This method handles foreground notification taps (when the app is open and visible).
  // It's an instance method, unlike the background handler.
  void onDidReceiveForegroundNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('Foreground Notification Tapped! Payload: $payload');

      // Example: Direct navigation within the app if a NavigatorState is available.
      if (payload.startsWith('assignment_')) {
        final assignmentId = payload.substring('assignment_'.length);
        debugPrint('Navigating to assignment details for: $assignmentId');
        // You can use a routing solution here. For example, if you're using GoRouter:
        // navigatorKey.currentState?.context.go('/assignments/$assignmentId');
        // Or if using standard Navigator:
        // navigatorKey.currentState?.pushNamed('/assignmentDetails', arguments: assignmentId);
      }
    }
  }

  // --- NOTIFICATION SCHEDULING AND DISPLAY METHODS ---

  /// Shows an immediate notification.
  Future<void> showNotification(int id, String title, String body, String? payload) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'chela_instant_channel_id', // Unique channel ID for instant notifications
      'Chela Instant Alerts',     // User-visible channel name
      channelDescription: 'Immediate notifications for important updates in Chela',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker', // Used for scrolling text on older Android versions
      icon: 'ic_notification', // Use the new icon
      // You can also add custom sound: sound: RawResourceAndroidNotificationSound('your_sound_file'),
    );
    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails, payload: payload);
    debugPrint('Shown instant notification ID: $id with payload: $payload');
  }

  /// Schedules a notification for a specific future time.
  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime, String? payload) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint("Warning: Attempted to schedule a notification in the past (ID: $id, Time: $scheduledTime). Not scheduling.");
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local), // Use local timezone for scheduling
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chela_scheduled_channel_id', // Unique channel ID for scheduled reminders
          'Chela Scheduled Reminders',  // User-visible channel name
          channelDescription: 'Time-based reminders for assignments, classes, and tasks in Chela',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: 'ic_notification', // Use the new icon
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Allows for more precise scheduling
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // `matchDateTimeComponents` can be used for recurring notifications (e.g., daily, weekly)
      // matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload, // Custom data passed with the notification
    );
    debugPrint('Scheduled notification ID: $id for $scheduledTime with payload: $payload');
  }

  /// Cancels a specific notification by its ID.
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Cancelled notification ID: $id');
  }

  /// Cancels all currently pending notifications.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('Cancelled all notifications.');
  }
}