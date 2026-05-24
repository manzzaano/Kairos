import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio de notificaciones locales para KAIROS.
/// Uso: await NotificationService.init() al arrancar la app.
/// Luego: await NotificationService.scheduleReminder(...) al crear un recordatorio.
abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── Canal Android ──────────────────────────────────────────────────────────
  static const _channelId = 'kairos_reminders';
  static const _channelName = 'Recordatorios KAIROS';
  static const _channelDesc = 'Notificaciones de tareas y hábitos';

  // ── Inicialización ─────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crear canal de notificaciones Android
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    debugPrint('[Notifications] Servicio inicializado');
  }

  // ── Solicitar permisos ─────────────────────────────────────────────────────
  static Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    debugPrint('[Notifications] Permiso concedido: $granted');
    return granted;
  }

  // ── Programar recordatorio ─────────────────────────────────────────────────
  /// Programa una notificación local en [when].
  /// [id] debe ser único por tarea (usa hashCode del id de la tarea).
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await init();
    if (when.isBefore(DateTime.now())) return;

    final location = tz.local;
    final scheduledDate = tz.TZDateTime.from(when, location);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF6366F1),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('[Notifications] Recordatorio programado: "$title" en $when');
  }

  // ── Notificación inmediata ─────────────────────────────────────────────────
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ── Cancelar ───────────────────────────────────────────────────────────────
  static Future<void> cancel(int id) async => _plugin.cancel(id);
  static Future<void> cancelAll() async => _plugin.cancelAll();

  // ── Callback de tap ───────────────────────────────────────────────────────
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[Notifications] Tap en notificación id=${response.id}');
    // Navegación futura: usar GoRouter para ir a la tarea correspondiente
  }
}
