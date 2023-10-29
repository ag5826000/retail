import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOTP(
      String phoneNumber, {
        required PhoneVerificationCompleted verificationCompleted,
        required PhoneVerificationFailed verificationFailed,
        required PhoneCodeSent codeSent,
        required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      // Handle exceptions
    }
  }


}