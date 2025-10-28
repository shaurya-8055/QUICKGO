import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/app_notification.dart';

class NotificationsProvider extends ChangeNotifier {
  final List<AppNotification> _items = [];
  final _box = GetStorage();
  static const _storeKey = 'notifications';

  NotificationsProvider() {
    _load();
  }

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.read).length;

  void add(AppNotification n) {
    _items.insert(0, n);
    _save();
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _items) {
      n.read = true;
    }
    _save();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _save();
    notifyListeners();
  }

  void _save() {
    try {
      _box.write(
        _storeKey,
        _items.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      // Silently handle storage errors - notifications are non-critical
      print('Storage error: $e');
    }
  }

  void _load() {
    try {
      final raw = _box.read<List>(_storeKey);
      if (raw == null) return;
      _items
        ..clear()
        ..addAll(raw
            .whereType<Map>()
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))));
    } catch (e) {
      // Silently handle storage errors - start with empty notifications
      print('Storage load error: $e');
    }
  }
}
