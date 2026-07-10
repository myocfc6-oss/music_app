import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/welcome/welcome_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/dashboard/home_screen.dart';
import 'presentation/screens/now_playing/player_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/admin/track_management_screen.dart';
import 'presentation/screens/admin/artist_management_screen.dart';
import 'presentation/screens/admin/album_management_screen.dart';
import 'presentation/screens/admin/user_management_screen.dart';
import 'presentation/screens/dashboard/album_detail_screen.dart';
import 'presentation/screens/dashboard/artist_detail_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rlxmvbvlhthxkoxqnxvp.supabase.co',
    publishableKey: 'sb_publishable_0n1OixvALU0pHkqFpPVDfA_ljQ7JrWl',
  );

  runApp(const SonusApp());
}

class SonusApp extends StatelessWidget {
  const SonusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonus Music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/player': (context) => const PlayerScreen(),
        '/album_detail': (context) => const AlbumDetailScreen(),
        '/artist_detail': (context) => const ArtistDetailScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/tracks': (context) => const TrackManagementScreen(),
        '/admin/artists': (context) => const ArtistManagementScreen(),
        '/admin/albums': (context) => const AlbumManagementScreen(),
        '/admin/users': (context) => const UserManagementScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
