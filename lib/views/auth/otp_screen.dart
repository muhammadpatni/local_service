import 'package:flutter/material.dart';
import 'package:local_service/data/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class OTPScreen extends StatelessWidget {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("OTP Verification")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: otpController, hint: "Enter OTP"),
            SizedBox(height: 20),
            CustomButton(
              text: "Verify OTP",
              onTap: () async {
                await vm.verifyOTP(otpController.text);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        Scaffold(body: Center(child: Text("Login Success"))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
