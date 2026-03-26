import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class Authenticationservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> login(String username , String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username ,String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
   Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In failed: $e");
      return null;
    }
  }
   Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print('Facebook Sign-In failed: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}