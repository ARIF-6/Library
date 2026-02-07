import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/api_service.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getAllReservations();
      setState(() => _reservations = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reservations: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(Reservation r) async {
    final controller = TextEditingController(text: '14');
    final days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set due date'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Days from now'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 14;
              Navigator.pop(context, value);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (days == null) return;
    try {
      final dueDate = DateTime.now().add(Duration(days: days));
      await _apiService.approveReservation(r.id, dueDate);
      _loadReservations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    }
  }

  Future<void> _reject(Reservation r) async {
    try {
      await _apiService.rejectReservation(r.id);
      _loadReservations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  Future<void> _deleteReservation(Reservation r) async {
    try {
      await _apiService.deleteReservation(r.id);
      _loadReservations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? const Center(child: Text('No reservations'))
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final r = _reservations[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF0F4C81),
                          child: Icon(Icons.bookmark, color: Colors.white),
                        ),
                        title: Text('Book ID: ${r.bookId}'),
                        subtitle: Text('User ID: ${r.userId} - ${r.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (r.status == 'pending') ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                onPressed: () => _approve(r),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () => _reject(r),
                              ),
                            ],
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteReservation(r),
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
