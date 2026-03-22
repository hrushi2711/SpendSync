import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/card_model.dart';

class CardRepository extends ChangeNotifier {
  static const String _boxName = 'cardsBox';
  late Box<CardModel> _box;

  List<CardModel> get cards => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<CardModel>(_boxName);
  }

  int _nextId() {
    if (_box.isEmpty) return 1;
    return _box.values.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  CardModel? getById(int id) {
    try {
      return _box.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<CardModel> create({
    required String name,
    required double annualFee,
    required double waiverThreshold,
    required DateTime cycleStart,
    required DateTime cycleEnd,
  }) async {
    final card = CardModel(
      id: _nextId(),
      name: name,
      annualFee: annualFee,
      waiverThreshold: waiverThreshold,
      cycleStart: cycleStart,
      cycleEnd: cycleEnd,
    );
    await _box.add(card);
    notifyListeners();
    return card;
  }

  Future<void> update(CardModel card) async {
    await card.save();
    notifyListeners();
  }

  Future<void> delete(CardModel card) async {
    await card.delete();
    notifyListeners();
  }
}
