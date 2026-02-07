import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUsername();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getUserDashboard();
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

  Future<void> _loadUsername() async {
    try {
      final profile = await _apiService.getProfile();
      if (mounted) {
        setState(() => _username = profile['user']?['username'] ?? 'User');
      }
    } catch (e) {
      // Silent fail for username
    }
  }

  Widget _buildGradientStatCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
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
        title: const Text('Dashboard'),
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
                      // Welcome Section
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _username,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.95,
                        children: [
                          _buildGradientStatCard(
                            label: 'Total Books',
                            value: '${_stats['totalBooks'] ?? 0}',
                            icon: Icons.library_books_rounded,
                            gradientColors: [
                              const Color(0xFF006B7D),
                              const Color(0xFF00A8C5),
                            ],
                          ),
                          _buildGradientStatCard(
                            label: 'Pending',
                            value: '${_stats['myPending'] ?? 0}',
                            icon: Icons.pending_actions_rounded,
                            gradientColors: [
                              const Color(0xFFF59E0B),
                              const Color(0xFFFBBF24),
                            ],
                          ),
                          _buildGradientStatCard(
                            label: 'Borrowed',
                            value: '${_stats['myBorrowed'] ?? 0}',
                            icon: Icons.book_rounded,
                            gradientColors: [
                              const Color(0xFF8B5CF6),
                              const Color(0xFFA78BFA),
                            ],
                          ),
                          _buildGradientStatCard(
                            label: 'Available',
                            value:
                                '${(_stats['totalBooks'] ?? 0) - (_stats['myBorrowed'] ?? 0)}',
                            icon: Icons.check_circle_rounded,
                            gradientColors: [
                              const Color(0xFF10B981),
                              const Color(0xFF34D399),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Quick Info Card
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
                                  Icons.info_outline_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Quick Info',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.book_outlined,
                              label: 'Browse all available books',
                              subtitle: 'Explore our collection',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.bookmark_border_rounded,
                              label: 'Reserve books online',
                              subtitle: 'Quick and easy reservations',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.schedule_rounded,
                              label: 'Track your borrowed books',
                              subtitle: 'Never miss a return date',
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF006B7D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF006B7D),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
