import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/card_model.dart';

class CardRepository extends ChangeNotifier {
  static const String _boxName = 'cardsBox';
  late Box<CardModel> _box;

  List<CardModel> get cards => _box.values.toList();

  /// Returns only cards belonging to the given user.
  List<CardModel> getByUserId(int userId) =>
      _box.values.where((c) => c.userId == userId).toList();

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
    required int userId,
  }) async {
    final card = CardModel(
      id: _nextId(),
      name: name,
      annualFee: annualFee,
      waiverThreshold: waiverThreshold,
      cycleStart: cycleStart,
      cycleEnd: cycleEnd,
      userId: userId,
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

  /// Migrate legacy data (userId == 0) to the given userId.
  Future<void> migrateOrphanedData(int userId) async {
    for (final card in _box.values) {
      if (card.userId == 0) {
        card.userId = userId;
        await card.save();
      }
    }
    notifyListeners();
  }

  /// Export all cards for a user as a list of maps.
  List<Map<String, dynamic>> exportForUser(int userId) {
    return getByUserId(userId).map((c) => {
      'id': c.id,
      'name': c.name,
      'annualFee': c.annualFee,
      'waiverThreshold': c.waiverThreshold,
      'cycleStart': c.cycleStart.toIso8601String(),
      'cycleEnd': c.cycleEnd.toIso8601String(),
    }).toList();
  }

  /// Import cards from a list of maps for the given userId (overrides existing).
  Future<void> importForUser(int userId, List<dynamic> data) async {
    // 1. Wipe current existing records for this user
    final existingKeys = _box.keys.where((k) {
      final item = _box.get(k);
      return item != null && item.userId == userId;
    }).toList();
    if (existingKeys.isNotEmpty) {
      await _box.deleteAll(existingKeys);
    }

    // 2. Insert imported records
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final card = CardModel(
        id: _nextId(),
        name: map['name'] as String,
        annualFee: (map['annualFee'] as num).toDouble(),
        waiverThreshold: (map['waiverThreshold'] as num).toDouble(),
        cycleStart: DateTime.parse(map['cycleStart'] as String),
        cycleEnd: DateTime.parse(map['cycleEnd'] as String),
        userId: userId,
      );
      await _box.add(card);
    }
    notifyListeners();
  }
}
