import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/calculation.dart';
import 'widgets/calculator_button.dart';
import 'widgets/history_panel.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String previousValue = '';
  String operation = '';
  bool waitingForOperand = false;
  List<Calculation> history = [];

  void inputNumber(String num) {
    if (waitingForOperand) {
      display = num;
      waitingForOperand = false;
    } else {
      if (display.length >= 15) return;
      display = display == '0' ? num : display + num;
    }
    setState(() {});
  }

  void inputOperation(String nextOperation) {
    double inputValue = double.parse(display);

    if (previousValue.isEmpty) {
      previousValue = display;
    } else if (operation.isNotEmpty) {
      double prevValue = double.parse(previousValue);
      double result = calculate(prevValue, inputValue, operation);

      display = formatResult(result);
      previousValue = display;
    }

    waitingForOperand = true;
    operation = nextOperation;
    setState(() {});
  }

  void inputEquals() {
    if (operation.isEmpty || previousValue.isEmpty) return;

    double inputValue = double.parse(display);
    double prevValue = double.parse(previousValue);
    String expression = '$previousValue $operation $display';

    double result = calculate(prevValue, inputValue, operation);
    String resultStr = formatResult(result);

    addToHistory(expression, resultStr);

    display = resultStr;
    previousValue = '';
    operation = '';
    waitingForOperand = true;
    setState(() {});
  }

  double calculate(double firstOperand, double secondOperand, String operation) {
    switch (operation) {
      case '+':
        return firstOperand + secondOperand;
      case '-':
        return firstOperand - secondOperand;
      case '*':
        return firstOperand * secondOperand;
      case '/':
        if (secondOperand == 0) {
          throw Exception('Division by zero');
        }
        return firstOperand / secondOperand;
      default:
        return secondOperand;
    }
  }

  String formatResult(double result) {
    if (result.isInfinite || result.isNaN) {
      return 'Error';
    }

    String formatted = result.toStringAsFixed(8);
    formatted = formatted.replaceAll(RegExp(r'\.?0*$'), '');

    if (formatted.length > 15) {
      return result.toStringAsExponential(6);
    }

    return formatted;
  }

  void addToHistory(String expression, String result) {
    history.add(Calculation(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    ));

    if (history.length > 50) {
      history.removeAt(0);
    }
  }

  void clear() {
    display = '0';
    previousValue = '';
    operation = '';
    waitingForOperand = false;
    setState(() {});
  }

  void clearHistory() {
    history.clear();
    setState(() {});
  }

  void copyResult() {
    Clipboard.setData(ClipboardData(text: display));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Result copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: copyResult,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (previousValue.isNotEmpty && operation.isNotEmpty)
                    Text(
                      '$previousValue $operation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  SizedBox(height: 8),
                  Text(
                    display,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      CalculatorButton(
                        text: 'C',
                        onPressed: clear,
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        textColor: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      CalculatorButton(text: '±', onPressed: () {}),
                      CalculatorButton(text: '%', onPressed: () {}),
                      CalculatorButton(
                        text: '÷',
                        onPressed: () => inputOperation('/'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(text: '7', onPressed: () => inputNumber('7')),
                      CalculatorButton(text: '8', onPressed: () => inputNumber('8')),
                      CalculatorButton(text: '9', onPressed: () => inputNumber('9')),
                      CalculatorButton(
                        text: '×',
                        onPressed: () => inputOperation('*'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(text: '4', onPressed: () => inputNumber('4')),
                      CalculatorButton(text: '5', onPressed: () => inputNumber('5')),
                      CalculatorButton(text: '6', onPressed: () => inputNumber('6')),
                      CalculatorButton(
                        text: '-',
                        onPressed: () => inputOperation('-'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(text: '1', onPressed: () => inputNumber('1')),
                      CalculatorButton(text: '2', onPressed: () => inputNumber('2')),
                      CalculatorButton(text: '3', onPressed: () => inputNumber('3')),
                      CalculatorButton(
                        text: '+',
                        onPressed: () => inputOperation('+'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(text: '0', onPressed: () => inputNumber('0')),
                      CalculatorButton(text: '0', onPressed: () => inputNumber('0')),
                      CalculatorButton(text: '.', onPressed: () => inputNumber('.')),
                      CalculatorButton(
                        text: '=',
                        onPressed: inputEquals,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: HistoryPanel(
              history: history,
              onClear: clearHistory,
            ),
          ),
        ],
      ),
    );
  }
}