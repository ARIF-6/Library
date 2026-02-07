import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../models/reservation.dart';
import '../models/loan.dart';

class ApiService {
  static const String baseUrl = 'http://172.22.128.1:3000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _getHeaders(token: token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _delete(String endpoint, {String? token}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _getHeaders(token: token),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> register(
    String username,
    String email,
    String password, {
    String role = 'user',
  }) async {
    await _post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<User> login(String email, String password) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    final user = User.fromJson(data['user']);
    await _setToken(data['token']);
    await _setUserRole(user.role);
    return user;
  }

  Future<List<Book>> getBooks({String? search}) async {
    final token = await _getToken();
    final query = search != null && search.isNotEmpty ? '?search=$search' : '';
    final data = await _get('/books$query', token: token);
    final books = data['books'] as List<dynamic>? ?? [];
    return books.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Book> getBook(int id) async {
    final token = await _getToken();
    final data = await _get('/books/$id', token: token);
    return Book.fromJson(data['book'] as Map<String, dynamic>);
  }

  Future<Book> createBook(Book book) async {
    final token = await _getToken();
    final data =
        await _post('/books', book.toJson()..remove('id'), token: token);
    return Book.fromJson(data['book'] as Map<String, dynamic>);
  }

  Future<Book> updateBook(Book book) async {
    final token = await _getToken();
    final payload = book.toJson()..remove('id');
    final data = await _put('/books/${book.id}', payload, token: token);
    return Book.fromJson(data['book'] as Map<String, dynamic>);
  }

  Future<void> deleteBook(int id) async {
    final token = await _getToken();
    await _delete('/books/$id', token: token);
  }

  Future<Reservation> reserveBook(int bookId) async {
    final token = await _getToken();
    final data = await _post('/reservations', {'bookId': bookId}, token: token);
    return Reservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  Future<List<Reservation>> getMyReservations() async {
    final token = await _getToken();
    final data = await _get('/reservations/me', token: token);
    final reservations = data['reservations'] as List<dynamic>? ?? [];
    return reservations
        .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Reservation>> getAllReservations() async {
    final token = await _getToken();
    final data = await _get('/reservations', token: token);
    final reservations = data['reservations'] as List<dynamic>? ?? [];
    return reservations
        .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveReservation(int id, DateTime dueDate) async {
    final token = await _getToken();
    await _post(
      '/reservations/$id/approve',
      {'dueDate': dueDate.toIso8601String()},
      token: token,
    );
  }

  Future<void> rejectReservation(int id) async {
    final token = await _getToken();
    await _post('/reservations/$id/reject', {}, token: token);
  }

  Future<void> cancelReservation(int id) async {
    final token = await _getToken();
    await _post('/reservations/$id/cancel', {}, token: token);
  }

  Future<void> deleteReservation(int id) async {
    final token = await _getToken();
    await _delete('/reservations/$id', token: token);
  }

  Future<List<Loan>> getMyLoans() async {
    final token = await _getToken();
    final data = await _get('/loans/me', token: token);
    final loans = data['loans'] as List<dynamic>? ?? [];
    return loans.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Loan>> getAllLoans() async {
    final token = await _getToken();
    final data = await _get('/loans', token: token);
    final loans = data['loans'] as List<dynamic>? ?? [];
    return loans.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> issueLoan(int bookId, int userId, DateTime dueDate) async {
    final token = await _getToken();
    await _post(
      '/loans',
      {
        'bookId': bookId,
        'userId': userId,
        'dueDate': dueDate.toIso8601String(),
      },
      token: token,
    );
  }

  Future<void> returnLoan(int loanId) async {
    final token = await _getToken();
    await _post('/loans/$loanId/return', {}, token: token);
  }

  Future<void> updateDueDate(int loanId, DateTime dueDate) async {
    final token = await _getToken();
    await _put(
      '/loans/$loanId/due-date',
      {'dueDate': dueDate.toIso8601String()},
      token: token,
    );
  }

  Future<void> deleteLoan(int loanId) async {
    final token = await _getToken();
    await _delete('/loans/$loanId', token: token);
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final token = await _getToken();
    return _get('/dashboard/admin', token: token);
  }

  Future<Map<String, dynamic>> getUserDashboard() async {
    final token = await _getToken();
    return _get('/dashboard/user', token: token);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    return _get('/users/me', token: token);
  }

  Future<List<Loan>> getFines() async {
    final token = await _getToken();
    final data = await _get('/fines', token: token);
    final fines = data['fines'] as List<dynamic>? ?? [];
    return fines.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> payFine(int loanId) async {
    final token = await _getToken();
    await _post('/fines/$loanId/pay', {}, token: token);
  }

  Future<void> updateFineAmount(int loanId, double amount) async {
    final token = await _getToken();
    await _put('/fines/$loanId', {'amount': amount}, token: token);
  }

  Future<void> clearFine(int loanId) async {
    final token = await _getToken();
    await _delete('/fines/$loanId', token: token);
  }

  Future<Map<String, dynamic>> getIssuedReport() async {
    final token = await _getToken();
    return _get('/reports/issued', token: token);
  }

  Future<Map<String, dynamic>> getOverdueReport() async {
    final token = await _getToken();
    return _get('/reports/overdue', token: token);
  }

  Future<Map<String, dynamic>> getUserActivityReport() async {
    final token = await _getToken();
    return _get('/reports/users', token: token);
  }

  Future<Map<String, dynamic>> getInventoryReport() async {
    final token = await _getToken();
    return _get('/reports/inventory', token: token);
  }

  Future<void> logout() async {
    await _removeToken();
  }
}
