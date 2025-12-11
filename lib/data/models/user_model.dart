// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String selectedCharacter;
  final String petName;
  final int petLevel;
  final int petExp;
  final int coins;
  final int level;
  final int currentXp;
  final int targetXp;
  final int streak;
  final int totalMinutes;
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
    this.coins = 0,
    this.level = 1,
    this.currentXp = 0,
    this.targetXp = 100, // Target awal
    this.streak = 0,
    this.totalMinutes = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Mengubah Data dari Firestore (Map) menjadi Object Dart
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? 'User',
      selectedCharacter: data['selectedCharacter'] ?? 'cat',
      petName: data['petName'] ?? 'Pet',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : DateTime.now(),
      // Ambil stats, default ke 0/1 jika belum ada
      level: data['level'] ?? 1,
      currentXp: data['currentXp'] ?? 0,
      targetXp: data['targetXp'] ?? 100,
      streak: data['streak'] ?? 0,
      totalMinutes: data['totalMinutes'] ?? 0,
      coins: data['coins'] ?? 0,
    );
  }

  // Konversi dari Object Dart ke Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'selectedCharacter': selectedCharacter,
      'petName': petName,
      'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt!.toIso8601String(),
      'level': level,
      'currentXp': currentXp,
      'targetXp': targetXp,
      'streak': streak,
      'totalMinutes': totalMinutes,
      'coins': coins,
    };
  }
}