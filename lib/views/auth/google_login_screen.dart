import 'package:flutter/material.dart';
import 'package:local_service/data/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../home/home_screen.dart';

class GoogleLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Google Login")),
      body: Center(
        child: vm.isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                child: Text("Continue with Google"),
                onPressed: () async {
                  await vm.googleLogin();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),
      ),
    );
  }
}
