import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questlings'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: QuestlingsTheme.textSecondary.withValues(alpha: 0.7),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Player Profile Card ─────────────────────────────────────
            _PlayerProfileCard(),
            const SizedBox(height: 20),

            // ── Daily Quest Progress ────────────────────────────────────
            const _SectionHeader(title: 'Daily Quests'),
            const SizedBox(height: 12),
            _QuestCard(
              icon: Icons.fitness_center,
              title: 'Morning Workout',
              xp: 50,
              progress: 0.7,
              isCompleted: false,
            ),
            const SizedBox(height: 8),
            _QuestCard(
              icon: Icons.menu_book,
              title: 'Read for 30 mins',
              xp: 30,
              progress: 0.4,
              isCompleted: false,
            ),
            const SizedBox(height: 8),
            _QuestCard(
              icon: Icons.cleaning_services,
              title: 'Clean workspace',
              xp: 20,
              progress: 1.0,
              isCompleted: true,
            ),
            const SizedBox(height: 24),

            // ── Weekly Goals ────────────────────────────────────────────
            const _SectionHeader(title: 'Weekly Goals'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    value: '4 / 7',
                    label: 'Days Active',
                    color: QuestlingsTheme.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.stars,
                    value: '1,250',
                    label: 'Total XP',
                    color: QuestlingsTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    value: '3',
                    label: 'Achievements',
                    color: QuestlingsTheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Active Boosts ───────────────────────────────────────────
            const _SectionHeader(title: 'Active Boosts'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: QuestlingsTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: QuestlingsTheme.cardShadow,
                border: Border.all(
                  color: QuestlingsTheme.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: QuestlingsTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: QuestlingsTheme.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'XP Boost Active',
                          style: TextStyle(
                            color: QuestlingsTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1.5x XP for all quests • 2h 34m remaining',
                          style: TextStyle(
                            color: QuestlingsTheme.accent.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Leaderboard Preview ──────────────────────────────────────
            const _SectionHeader(title: 'Leaderboard'),
            const SizedBox(height: 12),
            _LeaderboardTile(rank: 1, name: 'ShadowKnight', xp: 8450, avatarColor: QuestlingsTheme.secondary),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Divider(color: QuestlingsTheme.surfaceOverlay),
            ),
            _LeaderboardTile(rank: 2, name: 'QuestMaster42', xp: 7200, avatarColor: Colors.white38),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Divider(color: QuestlingsTheme.surfaceOverlay),
            ),
            _LeaderboardTile(rank: 3, name: 'You', xp: 3100, avatarColor: QuestlingsTheme.primaryLight, isYou: true),
          ],
        ),
      ),
    );
  }
}

// ── Player Profile Card ────────────────────────────────────────────────
class _PlayerProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [QuestlingsTheme.surfaceCard, QuestlingsTheme.surfaceOverlay],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: QuestlingsTheme.cardShadow,
        border: Border.all(
          color: QuestlingsTheme.primaryLight.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: QuestlingsTheme.primaryGradient,
                  boxShadow: QuestlingsTheme.glowShadow,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adventurer',
                      style: TextStyle(
                        color: QuestlingsTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: QuestlingsTheme.primaryLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Level 8',
                            style: TextStyle(
                              color: QuestlingsTheme.primaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '3150 XP',
                          style: TextStyle(
                            color: QuestlingsTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'XP to next level',
                    style: TextStyle(
                      color: QuestlingsTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '850 / 4000',
                    style: TextStyle(
                      color: QuestlingsTheme.primaryLight.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 850 / 4000,
                  backgroundColor: QuestlingsTheme.surfaceOverlay,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    QuestlingsTheme.primaryLight,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(label: 'STR', value: '12'),
              _MiniStat(label: 'DEX', value: '15'),
              _MiniStat(label: 'INT', value: '10'),
              _MiniStat(label: 'VIT', value: '8'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: QuestlingsTheme.surfaceOverlay,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: QuestlingsTheme.primaryLight.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: QuestlingsTheme.primaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: QuestlingsTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: QuestlingsTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

// ── Quest Card ─────────────────────────────────────────────────────────
class _QuestCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int xp;
  final double progress;
  final bool isCompleted;

  const _QuestCard({
    required this.icon,
    required this.title,
    required this.xp,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: QuestlingsTheme.cardShadow,
        border: isCompleted
            ? Border.all(color: QuestlingsTheme.success.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? QuestlingsTheme.success.withValues(alpha: 0.1)
                  : QuestlingsTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : icon,
              color: isCompleted ? QuestlingsTheme.success : QuestlingsTheme.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted
                        ? QuestlingsTheme.textSecondary
                        : QuestlingsTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: QuestlingsTheme.surfaceOverlay,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? QuestlingsTheme.success : QuestlingsTheme.primaryLight,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // XP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCompleted
                  ? QuestlingsTheme.success.withValues(alpha: 0.1)
                  : QuestlingsTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: isCompleted ? QuestlingsTheme.success : QuestlingsTheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '+$xp XP',
                  style: TextStyle(
                    color: isCompleted ? QuestlingsTheme.success : QuestlingsTheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: QuestlingsTheme.cardShadow,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: QuestlingsTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaderboard Tile ───────────────────────────────────────────────────
class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final Color avatarColor;
  final bool isYou;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatarColor,
    this.isYou = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isYou ? QuestlingsTheme.primaryLight.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: isYou ? QuestlingsTheme.primaryLight : QuestlingsTheme.textSecondary,
                fontSize: 14,
                fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: avatarColor.withValues(alpha: 0.2),
            child: Text(
              name[0],
              style: TextStyle(
                color: avatarColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isYou ? QuestlingsTheme.primaryLight : QuestlingsTheme.textPrimary,
                fontSize: 14,
                fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          // XP
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 12, color: QuestlingsTheme.secondary),
              const SizedBox(width: 4),
              Text(
                '$xp XP',
                style: const TextStyle(
                  color: QuestlingsTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}