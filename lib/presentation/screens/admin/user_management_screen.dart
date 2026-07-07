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
    UserModel(userId: 1, name: 'Alice Johnson', email: 'alice@example.com', role: 'admin'),
    UserModel(userId: 2, name: 'Bob Smith', email: 'bob@example.com', role: 'user'),
    UserModel(userId: 3, name: 'Carol Williams', email: 'carol@example.com', role: 'user'),
    UserModel(userId: 4, name: 'David Brown', email: 'david@example.com', role: 'user'),
  ];

  void _toggleRole(UserModel user) {
    setState(() {
      final index = _users.indexWhere((u) => u.userId == user.userId);
      if (index != -1) {
        _users[index] = UserModel(
          userId: user.userId,
          name: user.name,
          email: user.email,
          role: user.role == 'admin' ? 'user' : 'admin',
        );
      }
    });
  }

  void _deleteUser(UserModel user) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete User', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${user.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    ).then((value) {
      if (value == true) {
        setState(() => _users.removeWhere((u) => u.userId == user.userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: _users.isEmpty
          ? const Center(child: Text('No users yet', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isAdmin = user.role == 'admin';
                return Card(
                  color: AppColors.surfaceCard,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdmin
                          ? AppColors.primaryNeon.withValues(alpha: 0.2)
                          : AppColors.surfaceElevated,
                      child: Icon(
                        Icons.person,
                        color: isAdmin ? AppColors.primaryNeon : AppColors.textMuted,
                      ),
                    ),
                    title: Text(user.name, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Row(
                      children: [
                        Text(
                          user.email,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? AppColors.primaryNeon.withValues(alpha: 0.15)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              color: isAdmin ? AppColors.primaryNeon : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.person_add,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => _toggleRole(user),
                          tooltip: isAdmin ? 'Demote to User' : 'Promote to Admin',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () => _deleteUser(user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
