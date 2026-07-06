/// Health-derived resources available for camp actions today.
class CampResources {
  const CampResources({
    required this.totalMomentum,
    required this.totalFuel,
    required this.totalFocus,
    required this.totalSpirit,
    required this.spentMomentum,
    required this.spentFuel,
    required this.spentFocus,
    required this.spentSpirit,
    this.restMultiplier = 1.0,
  });

  final int totalMomentum;
  final int totalFuel;
  final int totalFocus;
  final int totalSpirit;
  final int spentMomentum;
  final int spentFuel;
  final int spentFocus;
  final int spentSpirit;

  /// Applied after overnight Rest; boosts tomorrow's resource caps.
  final double restMultiplier;

  int get availableMomentum =>
      (totalMomentum - spentMomentum).clamp(0, totalMomentum);
  int get availableFuel => (totalFuel - spentFuel).clamp(0, totalFuel);
  int get availableFocus => (totalFocus - spentFocus).clamp(0, totalFocus);
  int get availableSpirit =>
      (totalSpirit - spentSpirit).clamp(0, totalSpirit);

  bool canSpendMomentum(int amount) => availableMomentum >= amount;
  bool canSpendFuel(int amount) => availableFuel >= amount;
  bool canSpendFocus(int amount) => availableFocus >= amount;
  bool canSpendSpirit(int amount) => availableSpirit >= amount;

  CampResources copyWith({
    int? totalMomentum,
    int? totalFuel,
    int? totalFocus,
    int? totalSpirit,
    int? spentMomentum,
    int? spentFuel,
    int? spentFocus,
    int? spentSpirit,
    double? restMultiplier,
  }) =>
      CampResources(
        totalMomentum: totalMomentum ?? this.totalMomentum,
        totalFuel: totalFuel ?? this.totalFuel,
        totalFocus: totalFocus ?? this.totalFocus,
        totalSpirit: totalSpirit ?? this.totalSpirit,
        spentMomentum: spentMomentum ?? this.spentMomentum,
        spentFuel: spentFuel ?? this.spentFuel,
        spentFocus: spentFocus ?? this.spentFocus,
        spentSpirit: spentSpirit ?? this.spentSpirit,
        restMultiplier: restMultiplier ?? this.restMultiplier,
      );

  CampResources withSpent({
    int momentum = 0,
    int fuel = 0,
    int focus = 0,
    int spirit = 0,
  }) =>
      copyWith(
        spentMomentum: spentMomentum + momentum,
        spentFuel: spentFuel + fuel,
        spentFocus: spentFocus + focus,
        spentSpirit: spentSpirit + spirit,
      );
}
