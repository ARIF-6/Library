import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _inventory = {};
  int _issuedCount = 0;
  int _overdueCount = 0;
  List<dynamic> _userActivity = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final inventory = await _apiService.getInventoryReport();
      final issued = await _apiService.getIssuedReport();
      final overdue = await _apiService.getOverdueReport();
      final userActivity = await _apiService.getUserActivityReport();
      setState(() {
        _inventory = inventory;
        _issuedCount = issued['count'] ?? 0;
        _overdueCount = overdue['count'] ?? 0;
        _userActivity = userActivity['activity'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _statCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded), onPressed: _loadReports),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      _statCard(
                          'Total Books', '${_inventory['totalBooks'] ?? 0}'),
                      _statCard(
                          'Available', '${_inventory['availableBooks'] ?? 0}'),
                      _statCard(
                          'Pending', '${_inventory['pendingBooks'] ?? 0}'),
                      _statCard(
                          'Borrowed', '${_inventory['borrowedBooks'] ?? 0}'),
                      _statCard('Issued Books', '$_issuedCount'),
                      _statCard('Overdue Books', '$_overdueCount'),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'User Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userActivity.length,
                    itemBuilder: (context, index) {
                      final item = _userActivity[index] as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(item['username'] ?? ''),
                          subtitle: Text(
                            'Loans: ${item['totalLoans']} - Active: ${item['activeLoans']}',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
