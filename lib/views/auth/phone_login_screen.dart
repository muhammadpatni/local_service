import 'package:flutter/material.dart';
import 'package:local_service/data/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import 'otp_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class PhoneLoginScreen extends StatelessWidget {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Phone Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: phoneController,
              hint: "Enter phone +92XXXXXXXXXX",
            ),
            SizedBox(height: 20),
            CustomButton(
              text: vm.isLoading ? "Loading..." : "Send OTP",
              onTap: () async {
                await vm.sendOTP(phoneController.text);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OTPScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Login with Google",
              onTap: () async {
                await vm.googleLogin();
              },
            ),
          ],
        ),
      ),
    );
  }
}
