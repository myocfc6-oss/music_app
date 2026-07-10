import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = true;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final data = await _supabase
          .from('user_tbl')
          .select()
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _user = UserModel.fromMap(data);
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
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

    if (confirmed != true || !mounted) return;

    await _supabase.auth.signOut();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
          : _user == null
              ? const Center(
                  child: Text('No user data found',
                      style: TextStyle(color: AppColors.textMuted)))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email,
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
              _user!.role.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryNeon,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildThemeToggle(),
          const SizedBox(height: 24),
          _buildSignOutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
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
          _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primaryNeon,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    final items = [
      _SettingEntry(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        onTap: () {},
      ),
      _SettingEntry(
        icon: Icons.lock_outline,
        title: 'Change Password',
        onTap: () {},
      ),
      _SettingEntry(
        icon: Icons.favorite_outline,
        title: 'Liked Songs',
        onTap: () {},
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

  Widget _buildThemeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        leading: Icon(
          _isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: AppColors.textMuted,
        ),
        title: const Text(
          'Dark Mode',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        trailing: Switch(
          value: _isDarkMode,
          onChanged: (value) => setState(() => _isDarkMode = value),
          activeThumbColor: AppColors.primaryNeon,
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _signOut,
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
