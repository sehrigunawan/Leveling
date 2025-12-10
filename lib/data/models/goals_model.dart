class GoalModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int durationDays;
  final int dailyDurationMinutes;
  final String status; // active, completed, abandoned
  final int totalMinutesSpent;

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.dailyDurationMinutes,
    required this.status,
    this.totalMinutesSpent = 0,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationDays: (json['durationDays'] ?? 0).toInt(),
      dailyDurationMinutes: (json['dailyDurationMinutes'] ?? 0).toInt(),
      status: json['status'] ?? 'active',
      totalMinutesSpent: (json['totalMinutesSpent'] ?? 0).toInt(),
    );
  }
}