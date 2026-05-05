import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../models/habit.dart';

class HabitChecklist extends ConsumerWidget {
  const HabitChecklist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No habits yet. Add one in the Habits tab!'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            return HabitTile(habit: habits[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class HabitTile extends ConsumerWidget {
  final Habit habit;

  const HabitTile({super.key, required this.habit});

  bool get _isCompletedToday {
    if (habit.lastCompletedAt == null) return false;
    final now = DateTime.now();
    final last = habit.lastCompletedAt!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(habit.title),
        subtitle: Text('Streak: ${habit.currentStreak} 🔥'),
        trailing: Checkbox(
          value: _isCompletedToday,
          onChanged: _isCompletedToday
              ? null
              : (value) async {
                  if (value == true) {
                    await ref.read(habitControllerProvider).completeHabit(habit.id);
                  }
                },
        ),
      ),
    );
  }
}
