import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../services/api_service.dart';

class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Loan> _fines = [];

  @override
  void initState() {
    super.initState();
    _loadFines();
  }

  Future<void> _loadFines() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getFines();
      setState(() => _fines = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load fines: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _payFine(Loan loan) async {
    try {
      await _apiService.payFine(loan.id);
      _loadFines();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pay fine: $e')),
        );
      }
    }
  }

  Future<void> _updateAmount(Loan loan) async {
    final controller = TextEditingController(text: loan.fineAmount.toString());
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Fine Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (amount == null) return;
    try {
      await _apiService.updateFineAmount(loan.id, amount);
      _loadFines();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _clearFine(Loan loan) async {
    try {
      await _apiService.clearFine(loan.id);
      _loadFines();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines Management'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fines.isEmpty
              ? const Center(child: Text('No unpaid fines'))
              : ListView.builder(
                  itemCount: _fines.length,
                  itemBuilder: (context, index) {
                    final fine = _fines[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF0F4C81),
                          child: Icon(Icons.payments, color: Colors.white),
                        ),
                        title: Text('Loan ID: ${fine.id}'),
                        subtitle: Text(
                          'User ID: ${fine.userId} - Amount: ${fine.fineAmount}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateAmount(fine),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle),
                              onPressed: () => _payFine(fine),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _clearFine(fine),
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
