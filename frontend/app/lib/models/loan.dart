class Loan {
  final int id;
  final int bookId;
  final int userId;
  final int? issuedBy;
  final DateTime issuedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;
  final String status;
  final double fineAmount;
  final bool finePaid;

  Loan({
    required this.id,
    required this.bookId,
    required this.userId,
    this.issuedBy,
    required this.issuedAt,
    required this.dueDate,
    this.returnedAt,
    required this.status,
    required this.fineAmount,
    required this.finePaid,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      bookId: json['bookId'],
      userId: json['userId'],
      issuedBy: json['issuedBy'],
      issuedAt: DateTime.parse(json['issuedAt']),
      dueDate: DateTime.parse(json['dueDate']),
      returnedAt: json['returnedAt'] != null
          ? DateTime.parse(json['returnedAt'])
          : null,
      status: json['status'],
      fineAmount: (json['fineAmount'] ?? 0).toDouble(),
      finePaid: json['finePaid'] ?? false,
    );
  }
}
