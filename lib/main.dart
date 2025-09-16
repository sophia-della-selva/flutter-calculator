import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sophia's Calculator",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.black, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
      home: const MyHomePage(title: "Sophia's Calculator"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _expression = '', _accumulator = '';

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _accumulator = '';
      } else if (value == '=') {
        final exprNoSpaces = _expression.replaceAll(' ', '');

        // Allow leading negative number, but check the rest
        final checkExpr = exprNoSpaces.startsWith('-')
            ? exprNoSpaces.substring(1)
            : exprNoSpaces;

        if (RegExp(r'^[+*/]|[+\-*/]{2,}|[+\-*/]$').hasMatch(checkExpr)) {
          _accumulator = '$_expression = Error';
          _expression = '';
          return;
        }

        try {
          final exp = Expression.parse(_expression.trim());
          final result = const ExpressionEvaluator().eval(exp, {});
          if (result == double.infinity ||
              result == double.negativeInfinity ||
              result.isNaN) {
            _accumulator = '$_expression = Error';
            _expression = '';
          } else {
            _accumulator = '$_expression = $result';
            _expression = result.toString();
          }
        } catch (_) {
          _accumulator = '$_expression = Error';
          _expression = '';
        }
      } else {
        // Concatenate consecutive digits automatically
        if (_expression.isNotEmpty &&
            RegExp(r'\d$').hasMatch(_expression) &&
            RegExp(r'^\d$').hasMatch(value)) {
          _expression += value;
        } else if (_expression.isEmpty && value == '-') {
          _expression += '-';
        } else if (RegExp(r'^\d+$').hasMatch(value)) {
          _expression += value;
        } else {
          _expression += ' $value ';
        }

        _accumulator = _expression;
      }
    });
  }

  Widget _btn(String label) => Expanded(
        child: ElevatedButton(
          onPressed: () => _onPressed(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 24),
            minimumSize: const Size.fromHeight(60),
            backgroundColor: Colors.deepPurple.shade100,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 22),
          ),
          child: Text(label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['7', '8', '9', '/'],
      ['4', '5', '6', '*'],
      ['1', '2', '3', '-'],
      ['0', 'C', '=', '+'],
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _accumulator,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...keys.map((row) => Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: row.map(_btn).toList(),
                ),
              )),
        ],
      ),
    );
  }
}
