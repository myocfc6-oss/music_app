import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const String _userCacheKey = 'sonus_cached_user';
  static const String _guestModeKey = 'sonus_guest_mode';

  final SupabaseClient? _supabaseClient;

  SupabaseClient? get _supabase {
    if (_supabaseClient != null) return _supabaseClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isGuest = false;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get isAdmin => _user?.role == 'admin';
  String? get error => _error;

  User? get currentUser {
    try {
      return _supabase?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    // 1. Immediately restore cached user or guest session for instant offline entry
    await _loadCachedUser();

    final client = _supabase;
    if (client != null) {
      try {
        _authSubscription = client.auth.onAuthStateChange.listen((data) async {
          final session = data.session;
          if (session != null && (_user == null || _isGuest)) {
            _isGuest = false;
            await _fetchUserProfile();
          } else if (session == null && _user != null && !_isGuest) {
            _user = null;
            await _clearUserCache();
            notifyListeners();
          }
        });

        final session = client.auth.currentSession;
        if (session != null) {
          _isGuest = false;
          await _fetchUserProfile();
        }
      } catch (e) {
        debugPrint('Supabase auth listener setup error: $e');
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool(_guestModeKey) ?? false;
      if (isGuest) {
        _isGuest = true;
        _user = UserModel(
          id: 'guest',
          name: 'Guest User',
          email: 'offline@sonus.local',
          role: 'user',
        );
        return;
      }

      final cachedUserRaw = prefs.getString(_userCacheKey);
      if (cachedUserRaw != null && cachedUserRaw.isNotEmpty) {
        final map = jsonDecode(cachedUserRaw) as Map<String, dynamic>;
        _user = UserModel.fromMap(map);
      }
    } catch (e) {
      debugPrint('Error loading cached user profile: $e');
    }
  }

  Future<void> _saveCachedUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCacheKey, jsonEncode(user.toMap()));
      await prefs.setBool(_guestModeKey, false);
    } catch (e) {
      debugPrint('Error saving cached user profile: $e');
    }
  }

  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userCacheKey);
      await prefs.remove(_guestModeKey);
    } catch (e) {
      debugPrint('Error clearing cached user: $e');
    }
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    _user = UserModel(
      id: 'guest',
      name: 'Guest User',
      email: 'offline@sonus.local',
      role: 'user',
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);
      await prefs.remove(_userCacheKey);
    } catch (e) {
      debugPrint('Error persisting guest mode: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final client = _supabase;
    if (client == null) throw Exception('Network client not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed: no user returned');
      }

      final userId = response.user!.id;

      await client.from('user_tbl').insert({
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
      _isGuest = false;
      await _saveCachedUser(_user!);
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
    final client = _supabase;
    if (client == null) throw Exception('Network client not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: no user returned');
      }

      _isGuest = false;
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
    final client = _supabase;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Supabase sign out error (may be offline): $e');
      }
    }
    _user = null;
    _isGuest = false;
    await _clearUserCache();
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    final client = _supabase;
    if (client == null) return;

    final userId = currentUser?.id ?? _user?.id;
    if (userId == null || userId == 'guest') return;

    try {
      final userData = await client
          .from('user_tbl')
          .select()
          .eq('user_id', userId)
          .single();

      _user = UserModel.fromMap(userData);
      await _saveCachedUser(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch user profile (likely offline): $e');
      // If we already have _user cached, retain it silently
    }
  }

  Future<void> refreshProfile() async {
    await _fetchUserProfile();
  }
}
