import '../dto/expense.dto.dart';
import '../../domain/entities/expense.entity.dart';

class ExpenseModel extends ExpenseDto {
  const ExpenseModel({
    required super.id,
    required super.category,
    required super.amount,
    required super.currency,
    required super.expenseDate,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromDto(ExpenseDto dto) {
    return ExpenseModel(
      id: dto.id,
      category: dto.category,
      amount: dto.amount,
      currency: dto.currency,
      expenseDate: dto.expenseDate,
      description: dto.description,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      category: entity.category,
      amount: entity.amount,
      currency: entity.currency,
      expenseDate: entity.expenseDate,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      category: category,
      amount: amount,
      currency: currency,
      expenseDate: expenseDate,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
