import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int? cardId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String description;

  @HiveField(4)
  String category;

  @HiveField(5)
  double amount;

  @HiveField(6)
  String paymentMode;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  int userId;

  TransactionModel({
    required this.id,
    this.cardId,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    required this.paymentMode,
    this.notes,
    this.userId = 0,
  });
}
