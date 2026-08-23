import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? loginStatus;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  // ---------------------------------------------------------
  // GOOGLE SIGN IN
  // ---------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
  try {
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message);
  } catch (e) {
    throw Exception(e.toString());
  }
}

  // ---------------------------------------------------------
  // EMAIL SIGN IN
  // ---------------------------------------------------------

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception("Unable to sign in.");
      }

      loginStatus = "Existing User";

      print("👋 Existing Email User");

      await _saveUser(user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  // ---------------------------------------------------------
  // EMAIL SIGN UP
  // ---------------------------------------------------------

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          "Unable to create account.",
        );
      }

      await user.updateDisplayName(name);

      loginStatus = "New User";

      print("🆕 New Email User");

      await _saveUser(user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  // ---------------------------------------------------------
  // SAVE USER TO FIRESTORE
  // ---------------------------------------------------------

  Future<void> _saveUser(User user) async {
    final providers = user.providerData
        .map((provider) => provider.providerId)
        .toSet()
        .toList();

    await _firestore
        .collection("users")
        .doc(user.uid)
        .set(
      {
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photoUrl": user.photoURL ?? "",
        "providers": providers,
        "lastLogin": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ---------------------------------------------------------
  // GET SIGN IN METHODS
  // ---------------------------------------------------------

  List<String> get signInMethods {
    final user = currentUser;

    if (user == null) {
      return [];
    }

    return user.providerData
        .map((provider) => provider.providerId)
        .toList();
  }

  // ---------------------------------------------------------
  // PASSWORD RESET
  // ---------------------------------------------------------

  Future<void> sendPasswordReset({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e),
      );
    }
  }

  // ---------------------------------------------------------
  // SIGN OUT
  // ---------------------------------------------------------

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();

      await _auth.signOut();

      loginStatus = null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ---------------------------------------------------------
  // AUTH STATE
  // ---------------------------------------------------------

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // ---------------------------------------------------------
  // AUTH ERROR MESSAGES
  // ---------------------------------------------------------

  String _getAuthErrorMessage(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case "user-not-found":
        return "No account found with this email.";

      case "wrong-password":
        return "Email or password is incorrect.";

      case "invalid-credential":
        return "Email or password is incorrect.";

      case "invalid-email":
        return "Please enter a valid email address.";

      case "email-already-in-use":
        return "An account already exists with this email.";

      case "account-exists-with-different-credential":
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