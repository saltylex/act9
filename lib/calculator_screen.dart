import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstController = TextEditingController();
  final _secondController = TextEditingController();
  String _result = 'Enter two numbers and choose an operation.';
  String? _divisionError;

  String? _validateNumber(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Enter a number.';
    final number = double.tryParse(value!.trim());
    if (number == null || !number.isFinite) {
      return 'Enter a valid finite number.';
    }
    return null;
  }

  void _calculate(String operation) {
    setState(() => _divisionError = null);
    if (!_formKey.currentState!.validate()) {
      setState(() => _result = 'Check the number inputs.');
      return;
    }
    FocusScope.of(context).unfocus();
    final first = double.parse(_firstController.text.trim());
    final second = double.parse(_secondController.text.trim());
    if (operation == '÷' && second == 0) {
      setState(() {
        _divisionError = 'Cannot divide by zero.';
        _result = 'Cannot divide by zero.';
      });
      return;
    }
    final result = switch (operation) {
      '+' => first + second,
      '−' => first - second,
      '×' => first * second,
      '÷' => first / second,
      _ => throw ArgumentError.value(operation),
    };
    setState(() {
      _result = result.isFinite
          ? '${_format(first)} $operation ${_format(second)} = ${_format(result)}'
          : 'Result is too large. Try smaller numbers.';
    });
  }

  String _format(double value) {
    return value.toString();
  }

  void _clear() {
    FocusScope.of(context).unfocus();
    _formKey.currentState!.reset();
    _firstController.clear();
    _secondController.clear();
    setState(() {
      _divisionError = null;
      _result = 'Enter two numbers and choose an operation.';
    });
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calculator')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.calculate, size: 64, color: Colors.indigo),
        const SizedBox(height: 16),
        const Text(
          'Basic Calculator',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const ValueKey('first-number'),
                controller: _firstController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'First number'),
                validator: _validateNumber,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('second-number'),
                controller: _secondController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Second number',
                  errorText: _divisionError,
                ),
                validator: _validateNumber,
                onChanged: (_) {
                  if (_divisionError != null) {
                    setState(() => _divisionError = null);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final operation in const [
              ('+', 'Add'),
              ('−', 'Subtract'),
              ('×', 'Multiply'),
              ('÷', 'Divide'),
            ])
              FilledButton(
                key: ValueKey(operation.$2),
                onPressed: () => _calculate(operation.$1),
                child: Text('${operation.$1} ${operation.$2}'),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Result',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _result,
                  key: const ValueKey('result'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
        ),
      ],
    ),
  );
}
