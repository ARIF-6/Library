import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _apiService = ApiService();
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _apiService.getUserRole();
    if (mounted) setState(() => _role = role);
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0F4C81)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'E-Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (_role == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Admin Dashboard'),
              onTap: () => Navigator.pushNamed(context, '/admin_home'),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Manage Books'),
              onTap: () => Navigator.pushNamed(context, '/books'),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Reservations'),
              onTap: () => Navigator.pushNamed(context, '/admin_reservations'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Issue/Return'),
              onTap: () => Navigator.pushNamed(context, '/admin_loans'),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Fines'),
              onTap: () => Navigator.pushNamed(context, '/fines'),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Reports'),
              onTap: () => Navigator.pushNamed(context, '/reports'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
          if (_role == 'user') ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('User Dashboard'),
              onTap: () => Navigator.pushNamed(context, '/user_home'),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Browse Books'),
              onTap: () => Navigator.pushNamed(context, '/books'),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('My Reservations'),
              onTap: () => Navigator.pushNamed(context, '/my_reservations'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('My Issued Books'),
              onTap: () => Navigator.pushNamed(context, '/my_loans'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
