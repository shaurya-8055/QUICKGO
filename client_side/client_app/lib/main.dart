import 'screen/splash_screen/splash_screen.dart';
import 'screen/login_screen/provider/user_provider.dart';
import 'screen/product_by_category_screen/provider/product_by_category_provider.dart';
import 'screen/product_cart_screen/provider/cart_provider.dart';
import 'screen/product_details_screen/provider/product_detail_provider.dart';
import 'screen/product_favorite_screen/provider/favorite_provider.dart';
import 'screen/profile_screen/provider/profile_provider.dart';
import 'core/providers/pagination_provider.dart';
import 'utility/app_theme.dart';
import 'utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/data/data_provider.dart';
import 'utility/theme_provider.dart';
import 'screen/notifications_screen/notifications_provider.dart';
import 'models/app_notification.dart';
import 'package:flutter/scheduler.dart';
import 'screen/services/provider/service_provider.dart';
import 'screen/services/provider/technician_provider.dart';
import 'services/local_notification_service.dart';
import 'screen/notifications_screen/notifications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Load environment variables (skip if file doesn't exist, e.g., on Vercel)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Note: .env file not found, using system environment variables');
  }
  var cart = FlutterCart();

  // Initialize OneSignal only on mobile platforms to avoid web plugin issues
  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (isMobile) {
    try {
      OneSignal.initialize("c8e0bbce-eb1a-483e-b976-44e5cd21b3d2");
      OneSignal.Notifications.requestPermission(true);
      await LocalNotificationService().initialize();
    } catch (_) {
      // Silently ignore in case plugin isn't available in certain builds
    }
  }
  await cart.initializeCart(isPersistenceSupportEnabled: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DataProvider()),
        ChangeNotifierProvider(create: (context) => PaginationProvider()),
        ChangeNotifierProvider(create: (context) => NotificationsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
            create: (context) => ProfileProvider(context.dataProvider)),
        ChangeNotifierProvider(
            create: (context) =>
                ProductByCategoryProvider(context.dataProvider)),
        ChangeNotifierProvider(
            create: (context) => ProductDetailProvider(context.dataProvider)),
        ChangeNotifierProvider(
            create: (context) => CartProvider(context.userProvider)),
        ChangeNotifierProvider(
            create: (context) => FavoriteProvider(context.dataProvider)),
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (context) => TechnicianProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Register OneSignal listeners after first frame to access providers
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final isMobile = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
      if (!isMobile) return;
      try {
        // Handle if app was opened by tapping a notification
        LocalNotificationService().handleInitialLaunchNavigation();
        OneSignal.Notifications.addForegroundWillDisplayListener((event) {
          // Avoid any default display and handle ourselves
          try {
            event.preventDefault();
          } catch (_) {}
          final notif = event.notification;
          // Show system tray notification for foreground messages
          LocalNotificationService().showSimple(
            id: notif.notificationId.hashCode,
            title: notif.title ?? 'Notification',
            body: notif.body ?? '',
          );
          context.read<NotificationsProvider>().add(
                AppNotification(
                  id: notif.notificationId,
                  title: notif.title ?? 'Notification',
                  body: notif.body ?? '',
                  timestamp: DateTime.now(),
                ),
              );
        });
        OneSignal.Notifications.addClickListener((event) {
          final notif = event.notification;
          context.read<NotificationsProvider>().add(
                AppNotification(
                  id: notif.notificationId,
                  title: notif.title ?? 'Notification',
                  body: notif.body ?? '',
                  timestamp: DateTime.now(),
                  read: true,
                ),
              );
          // Navigate to notifications screen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        });
      } catch (_) {
        // Ignore if OneSignal not available on some builds
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return GetMaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: AppTheme.lightAppTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
    );
  }
}
