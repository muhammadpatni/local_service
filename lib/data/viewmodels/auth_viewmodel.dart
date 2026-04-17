import 'package:flutter/material.dart';
import 'package:local_service/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;

  AuthViewModel(this.repository);

  bool isLoading = false;

  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  Future sendOTP(String phone) async {
    setLoading(true);
    await repository.sendOTP(phone);
    setLoading(false);
  }

  Future verifyOTP(String code) async {
    setLoading(true);
    await repository.verifyOTP(code);
    setLoading(false);
  }

  Future googleLogin() async {
    setLoading(true);
    await repository.googleLogin();
    setLoading(false);
  }
}
