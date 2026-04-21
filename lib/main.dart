import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_service/location_provider.dart';
import 'package:provider/provider.dart'; // 1. Provider import karein
import 'package:local_service/wrapper.dart';
// Apni location_provider file ka sahi path yahan likhein

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();

  runApp(
    // 2. MultiProvider yahan add karein taaki har screen isay access kar sakay
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LocationProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Service',

      // Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0E6BBB), // Spanish Blue
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0E6BBB),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),

      themeMode: _themeMode,
      home: const Wrapper(),
    );
  }
}
