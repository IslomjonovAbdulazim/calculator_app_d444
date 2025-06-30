class Calculation {
  final String expression;
  final String result;
  final DateTime timestamp;

  Calculation({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  String get displayText => '$expression = $result';
}