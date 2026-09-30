import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline AuthProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Continue as guest sets guest user and offline mode', () async {
      final auth = AuthProvider();
      await auth.continueAsGuest();

      expect(auth.isAuthenticated, isTrue);
      expect(auth.isGuest, isTrue);
      expect(auth.user?.id, 'guest');
      expect(auth.user?.name, 'Guest User');
    });

    test('Restores guest session from SharedPreferences on init', () async {
      SharedPreferences.setMockInitialValues({
        'sonus_guest_mode': true,
      });

      final auth = AuthProvider();
      await auth.init();

      expect(auth.isAuthenticated, isTrue);
      expect(auth.isGuest, isTrue);
      expect(auth.user?.id, 'guest');
    });

    test('Restores cached user from SharedPreferences on init offline', () async {
      const cachedUserJson = '{"user_id":"usr-1234","name":"Offline Listener","email":"listener@sonus.local","role":"user"}';

      SharedPreferences.setMockInitialValues({
        'sonus_cached_user': cachedUserJson,
        'sonus_guest_mode': false,
      });

      final auth = AuthProvider();
      await auth.init();

      expect(auth.isAuthenticated, isTrue);
      expect(auth.isGuest, isFalse);
      expect(auth.user?.id, 'usr-1234');
      expect(auth.user?.name, 'Offline Listener');
    });

    test('Sign out clears guest and cached user', () async {
      final auth = AuthProvider();
      await auth.continueAsGuest();
      expect(auth.isAuthenticated, isTrue);

      await auth.signOut();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.isGuest, isFalse);
      expect(auth.user, isNull);
    });
  });
}
