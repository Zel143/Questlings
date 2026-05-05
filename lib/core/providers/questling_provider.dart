import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';
import '../../models/questling.dart';

/// Provides a real-time stream of the current user's equipped Questling.
final equippedQuestlingProvider = StreamProvider<Questling?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value(null);
  }

  // Supabase streams only support a single .eq() filter, so we filter
  // by user_id server-side and apply the equipped check client-side.
  return supabase
      .from('questlings')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((data) {
        final equipped = data.where((row) => row['equipped'] == true).toList();
        return equipped.isNotEmpty
            ? Questling.fromJson(equipped.first)
            : null;
      });
});
