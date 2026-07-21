import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: no user returned');
    }

    final userId = response.user!.id;

    await _supabase.from('user_tbl').insert({
      'user_id': userId,
      'email': email,
      'name': name,
      'role': role,
    });

    return UserModel(
      id: userId,
      name: name,
      email: email,
      role: role,
    );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed: no user returned');
    }

    final userId = response.user!.id;

    final userData = await _supabase
        .from('user_tbl')
        .select()
        .eq('user_id', userId)
        .single();

    return UserModel.fromMap(userData);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    final userData = await _supabase
        .from('user_tbl')
        .select()
        .eq('user_id', user.id)
        .single();

    return UserModel.fromMap(userData);
  }
}
