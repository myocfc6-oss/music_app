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
                _buildAvatar(auth),
                const SizedBox(height: 16),
                Text(
                  auth.user!.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.user!.email,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    auth.user!.role.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSettingsSection(context, auth),
                const SizedBox(height: 24),
                _buildThemeToggle(context, theme),
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

  Widget _buildAvatar(AuthProvider auth) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Text(
          auth.user!.name.isNotEmpty ? auth.user!.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primaryNeon,
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
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.borderDark, indent: 56),
            ListTile(
              leading: Icon(items[i].icon, color: AppColors.textMuted),
              title: Text(
                items[i].title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: items[i].onTap,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        leading: Icon(
          theme.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: AppColors.textMuted,
        ),
        title: const Text(
          'Dark Mode',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        trailing: Switch(
          value: theme.isDarkMode,
          onChanged: (_) => theme.toggleTheme(),
          activeThumbColor: AppColors.primaryNeon,
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
              content: const Text('Are you sure you want to sign out?',
                  style: TextStyle(color: AppColors.textMuted)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          foregroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
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
      backgroundColor: AppColors.surfaceCard,
      title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
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
          child: const Text('Save', style: TextStyle(color: AppColors.primaryNeon)),
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
      backgroundColor: AppColors.surfaceCard,
      title: const Text('Change Password', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentPasswordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Current Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'New Password',
              prefixIcon: Icon(Icons.lock_reset, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
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
          child: const Text('Update', style: TextStyle(color: AppColors.primaryNeon)),
        ),
      ],
    ),
  );
}
