import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/api_service.dart';

class UserReservationsScreen extends StatefulWidget {
  const UserReservationsScreen({super.key});

  @override
  State<UserReservationsScreen> createState() => _UserReservationsScreenState();
}

class _UserReservationsScreenState extends State<UserReservationsScreen> {
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
      final data = await _apiService.getMyReservations();
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

  Future<void> _cancelReservation(Reservation r) async {
    try {
      await _apiService.cancelReservation(r.id);
      _loadReservations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
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
                        subtitle: Text('Status: ${r.status}'),
                        trailing: r.status == 'pending'
                            ? IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () => _cancelReservation(r),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
