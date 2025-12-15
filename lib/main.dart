import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'views/home_view.dart';
import 'views/map_view.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load Environment Variables
  try {
     await dotenv.load(fileName: ".env");
  } catch(e) {
     print("Error loading .env: $e");
  }

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // 3. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  // 4. Initialize Services
  await Get.putAsync(() => NotificationService().init());
  Get.put(LocationService());
  Get.put(AuthController());
  Get.put(AppController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check initial auth state
    final session = Supabase.instance.client.auth.currentSession;
    final initialRoute = session != null ? '/home' : '/login';

    return GetMaterialApp(
      title: 'OverloadedClean',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/register', page: () => RegisterView()),
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/map', page: () => MapView()),
      ],
    );
  }
}
