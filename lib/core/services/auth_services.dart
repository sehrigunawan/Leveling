import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/user_model.dart';
import '../../data/models/ability_model.dart';

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

  Future<void> updatePetName(String uid, String newName) async {
    try {
      await _db.collection('users').doc(uid).update({'petName': newName});
    } catch (e) {
      print("Error update pet name: $e");
    }
  }

  Future<Map<String, dynamic>> buyAbility(String userId, Ability ability) async {
    final userRef = _db.collection('users').doc(userId);
    
    return _db.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception("User not found");

      final currentCoins = userDoc.data()?['coins'] ?? 0;

      // 1. Cek Koin Cukup?
      if (currentCoins < ability.price) {
        return {'success': false, 'error': 'Koin tidak cukup!'};
      }

      // 2. Kurangi Koin
      transaction.update(userRef, {
        'coins': FieldValue.increment(-ability.price),
      });

      // 3. Tambah ke Inventory (Subcollection 'inventory')
      final itemRef = userRef.collection('inventory').doc(ability.id);
      final itemDoc = await transaction.get(itemRef);

      if (itemDoc.exists) {
        // Jika sudah punya, tambah quantity (Stackable)
        transaction.update(itemRef, {
          'quantity': FieldValue.increment(1),
        });
      } else {
        // Jika belum punya, buat baru
        transaction.set(itemRef, {
          'id': ability.id,
          'name': ability.name,
          'icon': ability.icon,
          'description': ability.description,
          'quantity': 1,
          'acquiredAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true};
    });
  }

  // --- STREAM INVENTORY USER ---
  Stream<List<Ability>> getUserInventory(String userId) {
    return _db.collection('users').doc(userId).collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Mapping dari Firestore ke Ability Model
        return Ability(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          icon: data['icon'],
          price: 0, // Harga beli tidak relevan di inventory
          isOwned: true,
          quantity: data['quantity'] ?? 1,
        );
      }).toList();
    });
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