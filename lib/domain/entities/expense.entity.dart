import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String category; // Rent, Salaries, Fuel, Electricity, Internet, Maintenance
  final double amount;
  final String currency; // EGP, E£
  final DateTime expenseDate;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.expenseDate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        amount,
        currency,
        expenseDate,
        description,
        createdAt,
        updatedAt,
      ];

  ExpenseEntity copyWith({
    String? id,
    String? category,
    double? amount,
    String? currency,
    DateTime? expenseDate,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      expenseDate: expenseDate ?? this.expenseDate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
