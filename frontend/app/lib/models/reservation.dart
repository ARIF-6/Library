class Reservation {
  final int id;
  final int bookId;
  final int userId;
  final String status;
  final int? approvedBy;

  Reservation({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.status,
    this.approvedBy,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      bookId: json['bookId'],
      userId: json['userId'],
      status: json['status'],
      approvedBy: json['approvedBy'],
    );
  }
}
