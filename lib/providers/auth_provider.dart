import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  String? get error => _error;

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _fetchUserProfile();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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
        'role': 'user',
      });

      _user = UserModel(
        id: userId,
        name: name,
        email: email,
        role: 'user',
      );
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: no user returned');
      }

      await _fetchUserProfile();
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return;

    try {
      final userData = await _supabase
          .from('user_tbl')
          .select()
          .eq('user_id', userId)
          .single();

      _user = UserModel.fromMap(userData);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch user profile: $e');
    }
  }

  Future<void> refreshProfile() async {
    await _fetchUserProfile();
  }
}
