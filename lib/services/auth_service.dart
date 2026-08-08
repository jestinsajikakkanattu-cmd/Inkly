import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? loginStatus;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) return userCredential;

      final userDoc = _firestore.collection("users").doc(user.uid);

      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        await userDoc.set({
          "uid": user.uid,
          "name": user.displayName ?? "",
          "email": user.email ?? "",
          "photoUrl": user.photoURL ?? "",
          "provider": "google",
          "createdAt": FieldValue.serverTimestamp(),
          "lastLogin": FieldValue.serverTimestamp(),
          "isPremium": false,
        });

        loginStatus = "New User";
        print("🆕 New Google User");
      } else {
        await userDoc.update({"lastLogin": FieldValue.serverTimestamp()});

        loginStatus = "Existing User";
        print("👋 Existing Google User");
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception("Unable to sign in");
      }

      final userDoc = _firestore.collection("users").doc(user.uid);

      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        await userDoc.set({
          "uid": user.uid,
          "name": user.displayName ?? "",
          "email": user.email ?? "",
          "photoUrl": "",
          "provider": "email",
          "createdAt": FieldValue.serverTimestamp(),
          "lastLogin": FieldValue.serverTimestamp(),
          "isPremium": false,
        });

        loginStatus = "New User";
        print("🆕 New Email User");
      } else {
        await userDoc.update({"lastLogin": FieldValue.serverTimestamp()});

        loginStatus = "Existing User";
        print("👋 Existing Email User");
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Sign In Error: ${e.code}");
      throw Exception(getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception("Unable to create user");
      }

      await user.updateDisplayName(name);

      await _firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": user.email ?? "",
        "photoUrl": "",
        "provider": "email",
        "createdAt": FieldValue.serverTimestamp(),
        "lastLogin": FieldValue.serverTimestamp(),
        "isPremium": false,
      });

      print("🆕 New Email User");

      return credential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Sign Up Error: ${e.code}");
      throw Exception(getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "No account found with this email.";

      case "wrong-password":
        return "Incorrect password. Please try again.";

      case "invalid-credential":
        return "Email or password is incorrect.";

      case "invalid-email":
        return "Please enter a valid email address.";

      case "email-already-in-use":
        return "An account already exists with this email.";

      case "weak-password":
        return "Password is too weak.";

      case "user-disabled":
        return "This account has been disabled.";

      case "too-many-requests":
        return "Too many attempts. Please try again later.";

      case "network-request-failed":
        return "Please check your internet connection.";

      case "operation-not-allowed":
        return "This sign-in method is currently unavailable.";

      default:
        return "Something went wrong. Please try again.";
    }
  }
}
