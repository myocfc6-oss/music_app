import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/track_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackProvider>().fetchUsers();
    });
  }

  void _showEditRoleDialog(UserModel user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit User Role', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.surfaceElevated,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Role', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              ..._buildRoleOptions(setDialogState, selectedRole, (role) { selectedRole = role; }),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (selectedRole != user.role) {
                  context.read<TrackProvider>().updateUserRole(user.id, selectedRole);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(color: AppColors.primaryNeon)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleOptions(StateSetter setDialogState, String current, ValueChanged<String> onChanged) {
    final roles = [
      ('admin', 'Admin', Icons.admin_panel_settings_rounded, AppColors.primaryNeon),
      ('moderator', 'Moderator', Icons.shield_rounded, AppColors.success),
      ('user', 'User', Icons.person_rounded, AppColors.textMuted),
    ];

    return roles.map((entry) {
      final (value, label, icon, color) = entry;
      final isSelected = current == value;

      return GestureDetector(
        onTap: () => setDialogState(() => onChanged(value)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppColors.borderDark, width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: TextStyle(color: isSelected ? color : AppColors.textSecondary, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ),
              if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 20),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Consumer<TrackProvider>(
        builder: (context, tp, _) {
          final users = tp.users;
          if (tp.isLoadingUsers) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
          }
          if (users.isEmpty) {
            return const Center(child: Text('No users yet', style: TextStyle(color: AppColors.textMuted)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, i) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserTile(
                user: user,
                onEditRole: () => _showEditRoleDialog(user),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditRole;

  const _UserTile({required this.user, required this.onEditRole});

  @override
  Widget build(BuildContext context) {
    final roleData = _roleStyle(user.role);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipOval(
          child: Container(
            width: 44, height: 44,
            color: AppColors.surfaceElevated,
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            _RoleBadge(label: roleData.label, color: roleData.color),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        trailing: GestureDetector(
          onTap: onEditRole,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.overlay, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.edit_rounded, color: AppColors.textMuted, size: 18),
          ),
        ),
      ),
    );
  }

  static ({String label, Color color}) _roleStyle(String role) {
    switch (role) {
      case 'admin':
        return (label: 'ADMIN', color: AppColors.primaryNeon);
      case 'moderator':
        return (label: 'MOD', color: AppColors.success);
      default:
        return (label: 'USER', color: AppColors.textMuted);
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}
