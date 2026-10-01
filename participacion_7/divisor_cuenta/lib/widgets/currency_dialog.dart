import 'package:flutter/material.dart';
import 'currency_helper.dart';

class CurrencyDialog extends StatelessWidget {
  final String currentCurrency;
  final ValueChanged<String> onSelected;

  const CurrencyDialog({
    super.key,
    required this.currentCurrency,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Moneda'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: CurrencyHelper.availableCurrencies.map((curr) {
            final isSelected = curr == currentCurrency;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: isSelected ? Colors.white : null,
                child: Text(curr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                _currencyName(curr),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                onSelected(curr);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _currencyName(String symbol) {
    switch (symbol) {
      case r'$':
        return r'Dólares / Pesos ($)';
      case '€':
        return 'Euros (€)';
      case '£':
        return 'Libras Esterlinas (£)';
      case 'S/':
        return 'Soles Peruanos (S/)';
      case 'COP':
        return 'Pesos Colombianos (COP)';
      case 'MXN':
        return 'Pesos Mexicanos (MXN)';
      default:
        return symbol;
    }
  }
}
