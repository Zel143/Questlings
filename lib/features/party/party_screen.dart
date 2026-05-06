import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: QuestlingsTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 14, color: QuestlingsTheme.primaryLight),
                SizedBox(width: 4),
                Text(
                  '3 / 4',
                  style: TextStyle(
                    color: QuestlingsTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Party Members ─────────────────────────────────────────────
            const _SectionHeader(title: 'Party Members'),
            const SizedBox(height: 12),
            _PartyMemberCard(
              name: 'ShadowBlade',
              title: 'Rogue',
              level: 12,
              hp: 85,
              maxHp: 100,
              xp: 4200,
              avatarColor: QuestlingsTheme.rarityEpic,
              status: 'Online',
              isLeader: true,
            ),
            const SizedBox(height: 8),
            _PartyMemberCard(
              name: 'FrostMage',
              title: 'Mage',
              level: 10,
              hp: 62,
              maxHp: 80,
              xp: 3100,
              avatarColor: QuestlingsTheme.rarityRare,
              status: 'Online',
              isLeader: false,
            ),
            const SizedBox(height: 8),
            _PartyMemberCard(
              name: 'IronShield',
              title: 'Tank',
              level: 14,
              hp: 145,
              maxHp: 150,
              xp: 5600,
              avatarColor: QuestlingsTheme.success,
              status: 'Away',
              isLeader: false,
            ),
            const SizedBox(height: 8),
            _InviteSlot(),
            const SizedBox(height: 24),

            // ── Party Stats ───────────────────────────────────────────────
            const _SectionHeader(title: 'Party Stats'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up,
                    value: '12,900',
                    label: 'Total XP',
                    color: QuestlingsTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    value: '42',
                    label: 'Quests Done',
                    color: QuestlingsTheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    value: '7',
                    label: 'Day Streak',
                    color: QuestlingsTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Recent Activity ───────────────────────────────────────────
            const _SectionHeader(title: 'Recent Activity'),
            const SizedBox(height: 12),
            _ActivityTile(
              name: 'ShadowBlade',
              action: 'completed "Dungeon Crawl"',
              xp: '+150 XP',
              time: '2m ago',
              color: QuestlingsTheme.primaryLight,
            ),
            const SizedBox(height: 8),
            _ActivityTile(
              name: 'FrostMage',
              action: 'crafted "Frost Staff"',
              xp: '+80 XP',
              time: '15m ago',
              color: QuestlingsTheme.rarityRare,
            ),
            const SizedBox(height: 8),
            _ActivityTile(
              name: 'IronShield',
              action: 'defeated "Iron Golem"',
              xp: '+200 XP',
              time: '1h ago',
              color: QuestlingsTheme.success,
            ),
          ],
        ),
      ),
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

// ── Party Member Card ──────────────────────────────────────────────────
class _PartyMemberCard extends StatelessWidget {
  final String name;
  final String title;
  final int level;
  final int hp;
  final int maxHp;
  final int xp;
  final Color avatarColor;
  final String status;
  final bool isLeader;

  const _PartyMemberCard({
    required this.name,
    required this.title,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.xp,
    required this.avatarColor,
    required this.status,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    final hpPercent = hp / maxHp;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: QuestlingsTheme.cardShadow,
        border: Border.all(
          color: avatarColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarColor.withValues(alpha: 0.2),
                      border: Border.all(color: avatarColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: TextStyle(
                          color: avatarColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isLeader)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: QuestlingsTheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 10,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: QuestlingsTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: avatarColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Lv.$level',
                            style: TextStyle(
                              color: avatarColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$title • $status',
                      style: TextStyle(
                        color: QuestlingsTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // XP
              Column(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: QuestlingsTheme.secondary),
                  const SizedBox(height: 2),
                  Text(
                    '$xp XP',
                    style: const TextStyle(
                      color: QuestlingsTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // HP Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HP',
                    style: TextStyle(
                      color: QuestlingsTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '$hp / $maxHp',
                    style: TextStyle(
                      color: hpPercent > 0.3
                          ? QuestlingsTheme.success
                          : QuestlingsTheme.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: hpPercent,
                  backgroundColor: QuestlingsTheme.surfaceOverlay,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    hpPercent > 0.6
                        ? QuestlingsTheme.success
                        : hpPercent > 0.3
                            ? QuestlingsTheme.warning
                            : QuestlingsTheme.danger,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Invite Slot ────────────────────────────────────────────────────────
class _InviteSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuestlingsTheme.primaryLight.withValues(alpha: 0.1),
          strokeAlign: BorderSide.strokeAlignInside,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1,
            color: QuestlingsTheme.primaryLight.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Invite a Friend',
            style: TextStyle(
              color: QuestlingsTheme.primaryLight.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
          Icon(icon, color: color, size: 24),
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

// ── Activity Tile ──────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final String name;
  final String action;
  final String xp;
  final String time;
  final Color color;

  const _ActivityTile({
    required this.name,
    required this.action,
    required this.xp,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: QuestlingsTheme.cardShadow,
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              name[0],
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Activity Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text: name,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' $action',
                        style: const TextStyle(
                          color: QuestlingsTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: QuestlingsTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: QuestlingsTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              xp,
              style: const TextStyle(
                color: QuestlingsTheme.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}