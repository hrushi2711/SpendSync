import 'package:hive/hive.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class CardModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double annualFee;

  @HiveField(3)
  double waiverThreshold;

  @HiveField(4)
  DateTime cycleStart;

  @HiveField(5)
  DateTime cycleEnd;

  CardModel({
    required this.id,
    required this.name,
    required this.annualFee,
    required this.waiverThreshold,
    required this.cycleStart,
    required this.cycleEnd,
  });
}
