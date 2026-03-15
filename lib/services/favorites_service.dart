import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final _sb = Supabase.instance.client;

  Future<Set<String>> fetchMyFavorites() async {
    final uid = _sb.auth.currentUser!.id;

    final rows = await _sb
        .from('favorites')
        .select('venue_id')
        .eq('user_id', uid);

    return rows.map<String>((e) => e['venue_id'] as String).toSet();
  }

  Future<void> addFavorite(String venueId) async {
    final uid = _sb.auth.currentUser!.id;

    await _sb.from('favorites').insert({
      'user_id': uid,
      'venue_id': venueId,
    });
  }

  Future<void> removeFavorite(String venueId) async {
    final uid = _sb.auth.currentUser!.id;

    await _sb
        .from('favorites')
        .delete()
        .eq('user_id', uid)
        .eq('venue_id', venueId);
  }
}