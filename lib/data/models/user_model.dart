import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String selectedCharacter; // 'cat', 'dog', 'hamster'
  final String petName;
  final int petLevel;
  final int petExp;
  final int totalCoins;
  final int currentStreak;
  final int longestStreak;
  final bool darkMode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.selectedCharacter,
    required this.petName,
    this.petLevel = 1,
    this.petExp = 0,
    this.totalCoins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.darkMode = false,
    this.createdAt,
    this.updatedAt,
  });

  // Mengubah Data dari Firestore (Map) menjadi Object Dart
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      selectedCharacter: data['selectedCharacter'] ?? 'cat',
      petName: data['petName'] ?? '',
      petLevel: (data['petLevel'] ?? 1).toInt(),
      petExp: (data['petExp'] ?? 0).toInt(),
      totalCoins: (data['totalCoins'] ?? 0).toInt(),
      currentStreak: (data['currentStreak'] ?? 0).toInt(),
      longestStreak: (data['longestStreak'] ?? 0).toInt(),
      darkMode: data['darkMode'] ?? false,
      // Handle konversi Timestamp Firebase ke DateTime Dart
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah Object Dart menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'selectedCharacter': selectedCharacter,
      'petName': petName,
      'petLevel': petLevel,
      'petExp': petExp,
      'totalCoins': totalCoins,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'darkMode': darkMode,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}