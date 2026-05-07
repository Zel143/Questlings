enum QuestlingStatus { healthy, sick, tired, sad }

class Questling {
  final String id;
  final String userId;
  final String speciesId;
  final String name;
  final int level;
  final QuestlingStatus status;
  final String? habitId;
  final bool equipped;

  Questling({
    required this.id,
    required this.userId,
    required this.speciesId,
    required this.name,
    required this.level,
    required this.status,
    this.habitId,
    required this.equipped,
  });

  factory Questling.fromJson(Map<String, dynamic> json) {
    return Questling(
      id: json['id'],
      userId: json['user_id'],
      speciesId: json['species_id'],
      name: json['name'] ?? 'Unnamed',
      level: json['level'] ?? 1,
      status: QuestlingStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'healthy'),
        orElse: () => QuestlingStatus.healthy,
      ),
      habitId: json['habit_id'],
      equipped: json['equipped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'species_id': speciesId,
      'name': name,
      'level': level,
      'status': status.name,
      'habit_id': habitId,
      'equipped': equipped,
    };
  }
}
