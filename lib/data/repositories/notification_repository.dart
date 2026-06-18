import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qcut_flutter/data/services/fcm_service.dart';

class NotificationRepository {
  final FcmService _fcmService;
  String? _cachedToken;

  NotificationRepository({required FcmService fcmService}) : _fcmService = fcmService;

  Future<String?> getToken() async {
    _cachedToken ??= await _fcmService.getToken();
    return _cachedToken;
  }

  Stream<String?> onTokenRefresh() => _fcmService.onTokenRefresh();

  Future<void> requestPermission() => _fcmService.requestPermission();

  Stream<RemoteMessage> get foregroundMessages => _fcmService.onMessage;
}
