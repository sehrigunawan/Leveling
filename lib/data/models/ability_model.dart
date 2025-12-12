class Ability {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int price;
  
  // Status User
  final bool isOwned;
  final int quantity; // Jumlah yang dimiliki (consumable)

  Ability({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    this.isOwned = false,
    this.quantity = 0,
  });

  // Data Static untuk Shop (Katalog)
  static List<Ability> get catalog => [
    Ability(
      id: 'shield_1', 
      name: 'Streak Shield', 
      description: 'Menahan Streak agar tidak putus 1x jika lupa latihan.', 
      icon: '🛡️', 
      price: 150
    ),
    Ability(
      id: 'xp_boost_1', 
      name: 'XP Booster', 
      description: 'Mendapatkan 2x XP selama 24 jam.', 
      icon: '⚡', 
      price: 300
    ),
    Ability(
      id: 'freeze_1', 
      name: 'Time Freeze', 
      description: 'Membekukan target harian selama 1 hari (Libur).', 
      icon: '🧊', 
      price: 200
    ),
    Ability(
      id: 'coin_magnet', 
      name: 'Coin Magnet', 
      description: 'Meningkatkan peluang dapat koin bonus 10%.', 
      icon: '🧲', 
      price: 500
    ),
  ];
}