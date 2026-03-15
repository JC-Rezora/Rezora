import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchMyProfile() async {
    final uid = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('profiles')
        .select('id, role, email, full_name, phone, venue_id')
        .eq('id', uid)
        .single();

    return data;
  }
}