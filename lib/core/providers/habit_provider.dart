import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';
import '../../models/habit.dart';

/// Provides a real-time stream of the current user's habits.
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return supabase
      .from('habits')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((data) => data.map((json) => Habit.fromJson(json)).toList());
});

/// Controller for habit-related actions (e.g., completion).
final habitControllerProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return HabitController(supabase);
});

class HabitController {
  final SupabaseClient _supabase;

  HabitController(this._supabase);

  /// Calls the `complete_habit` RPC function in Supabase.
  Future<void> completeHabit(String habitId) async {
    try {
      await _supabase.rpc('complete_habit', params: {
        'target_habit_id': habitId,
      });
    } catch (e) {
      // Re-throw or handle error as needed for UI feedback
      rethrow;
    }
  }
}
