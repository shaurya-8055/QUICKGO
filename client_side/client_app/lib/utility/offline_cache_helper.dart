import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Call this once in main() before using Hive
Future<void> initializeHive() async {
  await Hive.initFlutter();
}

class OfflineCacheHelper {
  static Future<void> saveProduct(
      String productId, Map<String, dynamic> data) async {
    final box = await Hive.openBox('product_cache');
    await box.put(productId, data);
  }

  static Future<Map<String, dynamic>?> getProduct(String productId) async {
    final box = await Hive.openBox('product_cache');
    final result = box.get(productId);
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    return null;
  }
}
