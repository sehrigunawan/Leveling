import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; 
import 'logic/auth_logic.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthLogic()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil state AuthLogic
    final authLogic = Provider.of<AuthLogic>(context);
    
    // Inisialisasi Router dengan AuthLogic
    // (Agar router bisa refresh otomatis saat login/logout)
    final appRouter = AppRouter(authLogic);

    return MaterialApp.router(
      title: 'MyLeveling',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      // Sambungkan konfigurasi router
      routerConfig: appRouter.router,
    );
  }
}