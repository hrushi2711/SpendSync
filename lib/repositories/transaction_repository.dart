import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionRepository extends ChangeNotifier {
  static const String _boxName = 'transactionsBox';
  late Box<TransactionModel> _box;

  List<TransactionModel> get transactions => _box.values.toList();

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
}
