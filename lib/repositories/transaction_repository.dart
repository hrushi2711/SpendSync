import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionRepository extends ChangeNotifier {
  static const String _boxName = 'transactionsBox';
  late Box<TransactionModel> _box;

  List<TransactionModel> get transactions => _box.values.toList();

  /// Returns only transactions belonging to the given user.
  List<TransactionModel> getByUserId(int userId) =>
      _box.values.where((t) => t.userId == userId).toList();

  Future<void> init() async {
    _box = await Hive.openBox<TransactionModel>(_boxName);
  }

  int _nextId() {
    if (_box.isEmpty) return 1;
    return _box.values.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  TransactionModel? getById(int id) {
    try {
      return _box.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<TransactionModel> create({
    int? cardId,
    required DateTime date,
    required String description,
    required String category,
    required double amount,
    required String paymentMode,
    String? notes,
    required int userId,
  }) async {
    final tx = TransactionModel(
      id: _nextId(),
      cardId: cardId,
      date: date,
      description: description,
      category: category,
      amount: amount,
      paymentMode: paymentMode,
      notes: notes,
      userId: userId,
    );
    await _box.add(tx);
    notifyListeners();
    return tx;
  }

  Future<void> update(TransactionModel tx) async {
    await tx.save();
    notifyListeners();
  }

  Future<void> delete(TransactionModel tx) async {
    await tx.delete();
    notifyListeners();
  }

  /// Migrate legacy data (userId == 0) to the given userId.
  Future<void> migrateOrphanedData(int userId) async {
    for (final tx in _box.values) {
      if (tx.userId == 0) {
        tx.userId = userId;
        await tx.save();
      }
    }
    notifyListeners();
  }

  /// Export all transactions for a user as a list of maps.
  List<Map<String, dynamic>> exportForUser(int userId) {
    return getByUserId(userId).map((t) => {
      'id': t.id,
      'cardId': t.cardId,
      'date': t.date.toIso8601String(),
      'description': t.description,
      'category': t.category,
      'amount': t.amount,
      'paymentMode': t.paymentMode,
      'notes': t.notes,
    }).toList();
  }

  /// Import transactions from a list of maps for the given userId.
  Future<void> importForUser(int userId, List<dynamic> data) async {
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final tx = TransactionModel(
        id: _nextId(),
        cardId: map['cardId'] as int?,
        date: DateTime.parse(map['date'] as String),
        description: map['description'] as String,
        category: map['category'] as String,
        amount: (map['amount'] as num).toDouble(),
        paymentMode: map['paymentMode'] as String,
        notes: map['notes'] as String?,
        userId: userId,
      );
      await _box.add(tx);
    }
    notifyListeners();
  }
}
