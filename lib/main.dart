import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:local_service/login_screen.dart';
import 'package:local_service/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // runApp ke andar MaterialApp lazmi hai
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Wrapper(), // Aapki login screen yahan wrap honi chahiye
    ),
  );
}
