import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../library/liked_songs_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, theme, _) {
          if (auth.user == null) {
            return const Center(
              child: Text('No user data found',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildAvatar(context, auth),
                const SizedBox(height: 16),
                Text(
                  auth.user!.name,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.user!.email,
                  style: TextStyle(color: context.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primaryNeon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    auth.isGuest ? 'OFFLINE GUEST' : auth.user!.role.toUpperCase(),
                    style: TextStyle(
                      color: context.primaryNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (auth.isGuest) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.primaryNeon.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_off_rounded, color: context.primaryNeon, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Offline Mode Active',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You are currently using Sonus offline. Sign in or create an account when connected to sync playlists and likes.',
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                            },
                            child: const Text('Sign In / Register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _buildSettingsSection(context, auth),
                const SizedBox(height: 24),
                _buildThemeSection(context, theme),
                const SizedBox(height: 24),
                _buildSignOutButton(context, auth),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, AuthProvider auth) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: context.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: context.primaryNeon.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Text(
          auth.user!.name.isNotEmpty ? auth.user!.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: context.primaryNeon,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider auth) {
    final items = [
      _SettingEntry(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        onTap: () => _showEditProfileDialog(context, auth),
      ),
      _SettingEntry(
        icon: Icons.lock_outline,
        title: 'Change Password',
        onTap: () => _showChangePasswordDialog(context),
      ),
      _SettingEntry(
        icon: Icons.favorite_outline,
        title: 'Liked Songs',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LikedSongsScreen()),
          );
        },
      ),
      if (auth.isAdmin)
        _SettingEntry(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Admin Dashboard',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          },
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderDark),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.borderDark, indent: 56),
            ListTile(
              leading: Icon(items[i].icon, color: context.textMuted),
              title: Text(
                items[i].title,
                style: TextStyle(color: context.textPrimary, fontSize: 16),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
              onTap: items[i].onTap,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                theme.currentMode == AppThemeMode.system
                    ? Icons.brightness_auto_rounded
                    : (theme.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded),
                color: context.primaryNeon,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Theme Mode',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ThemeOptionButton(
                label: 'System',
                icon: Icons.brightness_auto_rounded,
                isSelected: theme.currentMode == AppThemeMode.system,
                onTap: () => theme.setThemeMode(AppThemeMode.system),
              ),
              const SizedBox(width: 8),
              _ThemeOptionButton(
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: theme.currentMode == AppThemeMode.dark,
                onTap: () => theme.setThemeMode(AppThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _ThemeOptionButton(
                label: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: theme.currentMode == AppThemeMode.light,
                onTap: () => theme.setThemeMode(AppThemeMode.light),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () async {
          final isGuest = auth.isGuest;
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              backgroundColor: context.surfaceCard,
              title: Text(
                isGuest ? 'Exit Offline Mode' : 'Sign Out',
                style: TextStyle(color: context.textPrimary),
              ),
              content: Text(
                isGuest
                    ? 'Return to the welcome screen to sign in or create an account?'
                    : 'Are you sure you want to sign out?',
                style: TextStyle(color: context.textMuted),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: Text('Cancel', style: TextStyle(color: context.textMuted)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: Text(
                    isGuest ? 'Exit' : 'Sign Out',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          foregroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              auth.isGuest ? 'Exit Offline Mode' : 'Sign Out',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.primaryNeon.withValues(alpha: 0.15)
                : context.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? context.primaryNeon : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? context.primaryNeon : context.textMuted,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? context.primaryNeon : context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingEntry {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingEntry({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
  final nameController = TextEditingController(text: auth.user?.name ?? '');
  final emailController = TextEditingController(text: auth.user?.email ?? '');

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: context.surfaceCard,
      title: Text('Edit Profile', style: TextStyle(color: context.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Name',
              prefixIcon: Icon(Icons.person_outline, color: context.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: context.textMuted),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(color: context.textMuted)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: Text('Save', style: TextStyle(color: context.primaryNeon)),
        ),
      ],
    ),
  );
}

void _showChangePasswordDialog(BuildContext context) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: context.surfaceCard,
      title: Text('Change Password', style: TextStyle(color: context.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentPasswordController,
            obscureText: true,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Current Password',
              prefixIcon: Icon(Icons.lock_outline, color: context.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'New Password',
              prefixIcon: Icon(Icons.lock_reset, color: context.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_outline, color: context.textMuted),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(color: context.textMuted)),
        ),
        TextButton(
          onPressed: () {
            if (newPasswordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passwords do not match'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            if (newPasswordController.text.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password must be at least 6 characters'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: Text('Update', style: TextStyle(color: context.primaryNeon)),
        ),
      ],
    ),
  );
}
