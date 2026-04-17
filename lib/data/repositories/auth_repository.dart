import '../../core/services/firebase_auth_service.dart';
import '../../core/services/google_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService firebase;
  final GoogleAuthService google;

  AuthRepository(this.firebase, this.google);

  Future sendOTP(String phone) => firebase.sendOTP(phone);

  Future verifyOTP(String code) => firebase.verifyOTP(code);

  Future googleLogin() => google.signInWithGoogle();
}
