class Profile {
  final String id;
  final String username;
  final int level;
  final int xp;
  final int stardust;

  Profile({
    required this.id,
    required this.username,
    required this.level,
    required this.xp,
    required this.stardust,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'] ?? '',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      stardust: json['stardust'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'level': level,
      'xp': xp,
      'stardust': stardust,
    };
  }
}
