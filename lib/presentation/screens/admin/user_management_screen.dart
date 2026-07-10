import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<UserModel> _users = [
    UserModel(id: '1', name: 'Alice Johnson', email: 'alice@example.com', role: 'admin'),
    UserModel(id: '2', name: 'Bob Smith', email: 'bob@example.com', role: 'user'),
    UserModel(id: '3', name: 'Carol Williams', email: 'carol@example.com', role: 'user'),
    UserModel(id: '4', name: 'David Brown', email: 'david@example.com', role: 'user'),
    UserModel(id: '5', name: 'Eve Martinez', email: 'eve@example.com', role: 'moderator'),
    UserModel(id: '6', name: 'Frank Lee', email: 'frank@example.com', role: 'user'),
  ];

  // ─── Edit Role ──────────────────────────────────────

  void _showEditRoleDialog(UserModel user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Edit User Role',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── User info header ──
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.surfaceElevated,
                    backgroundImage: NetworkImage(_avatarUrl(user.id)),
                    onBackgroundImageError: (e, st) {},
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Role selection ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Role',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ..._buildRoleOptions(ctx, setDialogState, selectedRole, (role) {
                selectedRole = role;
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedRole != user.role) {
                  setState(() {
                    final idx =
                        _users.indexWhere((u) => u.id == user.id);
                    if (idx != -1) {
                      _users[idx] = UserModel(
                        id: user.id,
                        name: user.name,
                        email: user.email,
                        role: selectedRole,
                      );
                    }
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.primaryNeon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleOptions(
    BuildContext ctx,
    StateSetter setDialogState,
    String current,
    ValueChanged<String> onChanged,
  ) {
    final roles = [
      ('admin', 'Admin', Icons.admin_panel_settings_rounded, AppColors.primaryNeon),
      ('moderator', 'Moderator', Icons.shield_rounded, AppColors.success),
      ('user', 'User', Icons.person_rounded, AppColors.textMuted),
    ];

    return roles.map((entry) {
      final (value, label, icon, color) = entry;
      final isSelected = current == value;

      return GestureDetector(
        onTap: () {
          setDialogState(() => onChanged(value));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.borderDark,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: color, size: 20),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ─── Delete ─────────────────────────────────────────

  void _deleteUser(UserModel user) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete User',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${user.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _users.removeWhere((u) => u.id == user.id));
      }
    });
  }

  // ─── Block ──────────────────────────────────────────

  void _blockUser(UserModel user) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Block User',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to block "${user.name}"? They will no longer be able to access the platform.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _users.removeWhere((u) => u.id == user.id));
      }
    });
  }

  // ─── Helpers ────────────────────────────────────────

  static const _avatarUrls = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
    'https://i.pravatar.cc/150?img=7',
    'https://i.pravatar.cc/150?img=8',
  ];

  String _avatarUrl(String userId) {
    final index = int.tryParse(userId) ?? 0;
    return _avatarUrls[index % _avatarUrls.length];
  }

  // ─── Build ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: _users.isEmpty
          ? const Center(
              child: Text(
                'No users yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              separatorBuilder: (_, i) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final user = _users[index];
                return _UserTile(
                  user: user,
                  avatarUrl: _avatarUrl(user.id),
                  onEditRole: () => _showEditRoleDialog(user),
                  onDelete: () => _deleteUser(user),
                  onBlock: () => _blockUser(user),
                );
              },
            ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  User Tile
// ──────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final UserModel user;
  final String avatarUrl;
  final VoidCallback onEditRole;
  final VoidCallback onDelete;
  final VoidCallback onBlock;

  const _UserTile({
    required this.user,
    required this.avatarUrl,
    required this.onEditRole,
    required this.onDelete,
    required this.onBlock,
  });

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
        leading: _buildAvatar(),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _RoleBadge(
              label: roleData.label,
              color: roleData.color,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            user.email,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionChip(
              icon: Icons.edit_rounded,
              tooltip: 'Edit Role',
              onTap: onEditRole,
            ),
            const SizedBox(width: 4),
            _ActionChip(
              icon: Icons.block_rounded,
              color: AppColors.error,
              tooltip: 'Block User',
              onTap: onBlock,
            ),
            const SizedBox(width: 4),
            _ActionChip(
              icon: Icons.delete_rounded,
              color: AppColors.error,
              tooltip: 'Delete User',
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => _avatarFallback(),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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

// ──────────────────────────────────────────────────────
//  Role Badge
// ──────────────────────────────────────────────────────

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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Action Chip (edit / block / delete)
// ──────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? tooltip;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    this.color = AppColors.textMuted,
    this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.overlay,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );

    if (tooltip == null) return chip;

    return Tooltip(message: tooltip!, child: chip);
  }
}
