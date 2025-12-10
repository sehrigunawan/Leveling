import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import standar
import '../../data/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Constructor standar

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- REGISTER ---
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String selectedCharacter,
    required String petName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user == null) throw Exception("User creation failed");

      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        selectedCharacter: selectedCharacter,
        petName: petName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(newUser.toMap());

      return {'success': true, 'user': user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- LOGIN EMAIL ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'user': result.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- LOGIN GOOGLE ---
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Trigger Login Pop-up
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Jika user menutup pop-up / batal
      if (googleUser == null) return {'success': false, 'error': 'Login dibatalkan'};

      // 2. Ambil token autentikasi
      // Note: Jika error "await" muncul disini, berarti versi library Anda berbeda.
      // Namun dengan versi ^6.2.1, 'authentication' adalah Future jadi wajib await.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Buat kredensial Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Masuk ke Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // 5. Simpan data user ke Firestore jika pengguna baru
      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          UserModel newUser = UserModel(
            uid: user.uid,
            email: user.email!,
            name: user.displayName ?? 'User',
            selectedCharacter: 'cat',
            petName: 'Pet-mu',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
        }
      }

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut(); // Wajib sign out dari Google juga
      await _auth.signOut();
    } catch (e) {
      print("Logout error: $e");
    }
  }

  // --- UTILS ---
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final query = await _db.collection('users').where('email', isEqualTo: email).limit(1).get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}