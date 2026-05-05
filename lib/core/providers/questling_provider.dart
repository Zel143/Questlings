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

  return supabase
      .from('questlings')
      .stream(primaryKey: ['id'])
      .eq('owner_id', userId)
      .eq('is_equipped', true)
      .limit(1)
      .map((data) => data.isNotEmpty ? Questling.fromJson(data.first) : null);
});
