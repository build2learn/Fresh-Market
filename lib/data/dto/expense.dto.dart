import '../../core/constants/firestore_constants.dart';

class ExpenseDto {
  final String id;
  final String category;
  final double amount;
  final String currency;
  final DateTime expenseDate;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseDto({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.expenseDate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  factory ExpenseDto.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseDto(
      id: documentId,
      category: map['category'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'EGP',
      expenseDate: _toDateTime(map['expenseDate']),
      description: map['description'] as String? ?? '',
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'currency': currency,
      'expenseDate': expenseDate.toIso8601String(),
      'description': description,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
