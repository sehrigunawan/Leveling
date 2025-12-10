class StatisticsModel {
  final String userId;
  final int totalMinutes;
  final int totalCoins;
  final int goalsCompleted;
  final int currentLevel;

  StatisticsModel({
    required this.userId,
    required this.totalMinutes,
    required this.totalCoins,
    required this.goalsCompleted,
    required this.currentLevel,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      userId: json['userId'] ?? '',
      totalMinutes: (json['totalMinutes'] ?? 0).toInt(),
      totalCoins: (json['totalCoins'] ?? 0).toInt(),
      goalsCompleted: (json['goalsCompleted'] ?? 0).toInt(),
      currentLevel: (json['currentLevel'] ?? 1).toInt(),
    );
  }
}