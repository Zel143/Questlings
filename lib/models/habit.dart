enum HabitDifficulty { trivial, easy, medium, hard }

class Habit {
  final String id;
  final String userId;
  final String title;
  final HabitDifficulty difficulty;
  final String category;
  final int currentStreak;
  final DateTime? lastCompletedAt;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.difficulty,
    required this.category,
    required this.currentStreak,
    this.lastCompletedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      difficulty: HabitDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] ?? 'easy'),
        orElse: () => HabitDifficulty.easy,
      ),
      category: json['category'] ?? 'General',
      currentStreak: json['current_streak'] ?? 0,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'difficulty': difficulty.name,
      'category': category,
      'current_streak': currentStreak,
      'last_completed_at': lastCompletedAt?.toIso8601String(),
    };
  }
}
