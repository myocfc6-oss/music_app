import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../dashboard/home_screen.dart';
import '../welcome/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 42,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppColors.primaryNeon,
                  ),
                ],
              ),
            ),
          );
        }

        if (auth.isAuthenticated) {
          if (auth.isAdmin) {
            return const AdminDashboardScreen();
          }
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
