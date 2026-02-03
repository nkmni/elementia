class ElementData {
  final int atomicNumber;
  final String symbol;
  final String name;
  final String atomicMass;
  final String category;
  final int? group;
  final int period;
  final double? electronegativity;
  final List<int> oxidationStates;
  final String summary;
  final String electronicConfiguration;

  const ElementData({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.atomicMass,
    required this.category,
    this.group,
    required this.period,
    this.electronegativity,
    required this.oxidationStates,
    required this.summary,
    required this.electronicConfiguration,
  });
}
