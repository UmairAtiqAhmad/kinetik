import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kinetik/Models/kinetik_user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<KinetikUser?> get onAuthStateChanged =>
      _firebaseAuth.authStateChanges().map(
            (User? user) => user == null
                ? null
                : KinetikUser(
                    uid: user.uid, email: user.email, name: user.displayName),
          );

  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return authResult.user!.uid;
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user!
        .uid;
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth =
        await account!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    String uid =
        (await _firebaseAuth.signInWithCredential(credential)).user!.uid;

    return uid;
  }

  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  signOut() {
    return _firebaseAuth.signOut();
  }
}
