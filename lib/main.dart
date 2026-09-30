import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/download_provider.dart';
import 'providers/device_music_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/track_provider.dart';
import 'presentation/screens/library/downloads_screen.dart';
import 'presentation/screens/library/device_music_screen.dart';
import 'presentation/screens/welcome/welcome_screen.dart';
import 'presentation/screens/auth/auth_gate.dart';
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
import 'package:just_audio_background/just_audio_background.dart';
import 'presentation/screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.music_app.channel.audio',
    androidNotificationChannelName: 'Sonus Music Playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()..init()),
        ChangeNotifierProvider(create: (_) => DeviceMusicProvider()..init()),
        ChangeNotifierProvider(create: (_) => TrackProvider()),
        ChangeNotifierProxyProvider<TrackProvider, AudioProvider>(
          create: (_) => AudioProvider(),
          update: (_, trackProvider, audioProvider) {
            final audio = audioProvider ?? AudioProvider();
            audio.onStreamIncremented = trackProvider.notifyStreamIncremented;
            return audio;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Sonus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthGate(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/player': (context) => const PlayerScreen(),
              '/downloads': (context) => const DownloadsScreen(),
              '/device_music': (context) => const DeviceMusicScreen(),
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
        },
      ),
    );
  }
}
