import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getAdminDashboard();
      setState(() => _stats = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildGradientStatCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Overview',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Library Management',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _buildGradientStatCard(
                            label: 'Total Books',
                            value: '${_stats['totalBooks'] ?? 0}',
                            icon: Icons.library_books_rounded,
                            gradientColors: [
                              const Color(0xFF006B7D),
                              const Color(0xFF00A8C5),
                            ],
                            subtitle: 'In collection',
                          ),
                          _buildGradientStatCard(
                            label: 'Available',
                            value: '${_stats['availableBooks'] ?? 0}',
                            icon: Icons.check_circle_rounded,
                            gradientColors: [
                              const Color(0xFF10B981),
                              const Color(0xFF34D399),
                            ],
                            subtitle: 'Ready to borrow',
                          ),
                          _buildGradientStatCard(
                            label: 'Pending',
                            value: '${_stats['pendingBorrows'] ?? 0}',
                            icon: Icons.pending_actions_rounded,
                            gradientColors: [
                              const Color(0xFFF59E0B),
                              const Color(0xFFFBBF24),
                            ],
                            subtitle: 'Awaiting approval',
                          ),
                          _buildGradientStatCard(
                            label: 'Borrowed',
                            value: '${_stats['borrowedBooks'] ?? 0}',
                            icon: Icons.book_rounded,
                            gradientColors: [
                              const Color(0xFF8B5CF6),
                              const Color(0xFFA78BFA),
                            ],
                            subtitle: 'Currently out',
                          ),
                          _buildGradientStatCard(
                            label: 'Total Users',
                            value: '${_stats['totalUsers'] ?? 0}',
                            icon: Icons.people_rounded,
                            gradientColors: [
                              const Color(0xFFEC4899),
                              const Color(0xFFF472B6),
                            ],
                            subtitle: 'Registered',
                          ),
                          _buildGradientStatCard(
                            label: 'System Status',
                            value: '✓',
                            icon: Icons.cloud_done_rounded,
                            gradientColors: [
                              const Color(0xFF06B6D4),
                              const Color(0xFF22D3EE),
                            ],
                            subtitle: 'All systems operational',
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Quick Actions Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.flash_on_rounded,
                                  color: theme.colorScheme.secondary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Quick Actions',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildActionRow(
                              icon: Icons.library_add_rounded,
                              label: 'Add new books to collection',
                              color: const Color(0xFF006B7D),
                            ),
                            const Divider(height: 24),
                            _buildActionRow(
                              icon: Icons.assignment_turned_in_rounded,
                              label: 'Process pending reservations',
                              color: const Color(0xFFF59E0B),
                            ),
                            const Divider(height: 24),
                            _buildActionRow(
                              icon: Icons.analytics_rounded,
                              label: 'View detailed reports',
                              color: const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }
}
