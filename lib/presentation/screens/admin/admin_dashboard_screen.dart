import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'artist_management_screen.dart';
import 'album_management_screen.dart';
import 'track_management_screen.dart';
import 'user_management_screen.dart';
import 'widgets/user_growth_chart.dart';
import 'widgets/genre_distribution_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const double _breakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          automaticallyImplyLeading: false,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _breakpoint;

            if (isWide) {
              return _buildWideLayout(context, constraints.maxWidth);
            }
            return _buildNarrowLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, double width) {
    final panelGap = width >= 1200 ? 24.0 : 16.0;
    final manageFlex = width >= 1200 ? 3 : 3;
    final chartsFlex = width >= 1200 ? 7 : 5;

    return Padding(
      padding: EdgeInsets.all(panelGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: manageFlex,
            child: _buildManagementPanel(context),
          ),
          SizedBox(width: panelGap),
          Expanded(
            flex: chartsFlex,
            child: _buildAnalyticsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Management'),
          const SizedBox(height: 16),
          ..._managementCards(context),
          const SizedBox(height: 24),
          _sectionHeader('Analytics Overview'),
          const SizedBox(height: 16),
          const UserGrowthChart(),
          const SizedBox(height: 16),
          const GenreDistributionChart(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Analytics Overview'),
          const SizedBox(height: 16),
          const UserGrowthChart(),
          const SizedBox(height: 16),
          const GenreDistributionChart(),
        ],
      ),
    );
  }

  Widget _buildManagementPanel(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Management'),
          const SizedBox(height: 16),
          ..._managementCards(context),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static List<Widget> _managementCards(BuildContext context) {
    final items = [
      _CardEntry(
        icon: Icons.people_rounded,
        title: 'Manage Artists',
        subtitle: 'Add, edit, or remove artists',
        destination: const ArtistManagementScreen(),
      ),
      _CardEntry(
        icon: Icons.album_rounded,
        title: 'Manage Albums',
        subtitle: 'Add, edit, or remove albums',
        destination: const AlbumManagementScreen(),
      ),
      _CardEntry(
        icon: Icons.audiotrack_rounded,
        title: 'Manage Tracks',
        subtitle: 'Add, edit, or remove tracks',
        destination: const TrackManagementScreen(),
      ),
      _CardEntry(
        icon: Icons.person_rounded,
        title: 'Manage Users',
        subtitle: 'View and manage user accounts',
        destination: const UserManagementScreen(),
      ),
    ];

    return [
      for (int i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        _buildAdminCard(
          context,
          icon: items[i].icon,
          title: items[i].title,
          subtitle: items[i].subtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => items[i].destination),
          ),
        ),
      ],
    ];
  }

  static Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryNeon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _CardEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _CardEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}
