import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:local_service/firebase_options.dart';
import 'package:local_service/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LoginScreen());
}
