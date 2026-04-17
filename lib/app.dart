import 'package:flutter/material.dart';
import 'package:local_service/data/viewmodels/auth_viewmodel.dart';
import 'package:local_service/views/auth/login_screen.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/google_auth_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            AuthRepository(FirebaseAuthService(), GoogleAuthService()),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
