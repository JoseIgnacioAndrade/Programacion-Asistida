import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/currency_helper.dart';

class QuickSplitScreen extends StatefulWidget {
  final String currency;

  const QuickSplitScreen({
    super.key,
    required this.currency,
  });

  @override
  State<QuickSplitScreen> createState() => _QuickSplitScreenState();
}

class _QuickSplitScreenState extends State<QuickSplitScreen> {
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();
  final TextEditingController _customTaxController = TextEditingController();

  int _peopleCount = 2;
  double _tipPercentage = 10.0;
  bool _isCustomTip = false;
  double _taxPercentage = 0.0;
  bool _isCustomTax = false;
  bool _taxIncludedInBill = false;
  bool _roundUp = false;

  final List<double> _tipPresets = [0.0, 5.0, 10.0, 15.0, 18.0, 20.0];
  final List<double> _taxPresets = [0.0, 12.0, 15.0];

  @override
  void initState() {
    super.initState();
    _billController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _billController.dispose();
    _customTipController.dispose();
    _customTaxController.dispose();
    super.dispose();
  }

  double get _billAmount {
    final text = _billController.text.replaceAll(',', '.');
    return double.tryParse(text) ?? 0.0;
  }

  double get _currentTipPercent {
    if (_isCustomTip) {
      final text = _customTipController.text.replaceAll(',', '.');
      return double.tryParse(text) ?? 0.0;
    }
    return _tipPercentage;
  }

  double get _currentTaxPercent {
    if (_isCustomTax) {
      final text = _customTaxController.text.replaceAll(',', '.');
      return double.tryParse(text) ?? 0.0;
    }
    return _taxPercentage;
  }

  double get _taxAmount {
    if (_taxIncludedInBill || _currentTaxPercent <= 0) return 0.0;
    return _billAmount * (_currentTaxPercent / 100);
  }

  double get _tipAmount {
    if (_currentTipPercent <= 0) return 0.0;
    return _billAmount * (_currentTipPercent / 100);
  }

  double get _grandTotal {
    return _billAmount + _taxAmount + _tipAmount;
  }

  double get _exactPerPerson {
    if (_peopleCount <= 0) return 0.0;
    return _grandTotal / _peopleCount;
  }

  double get _finalPerPerson {
    if (_roundUp) {
      return _exactPerPerson.ceilToDouble();
    }
    return _exactPerPerson;
  }

  double get _totalCollected => _finalPerPerson * _peopleCount;
  double get _extraRounding => _totalCollected - _grandTotal;

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _billController.clear();
      _customTipController.clear();
      _customTaxController.clear();
      _peopleCount = 2;
      _tipPercentage = 10.0;
      _isCustomTip = false;
      _taxPercentage = 0.0;
      _isCustomTax = false;
      _taxIncludedInBill = false;
      _roundUp = false;
    });
  }

  void _copySummary() {
    HapticFeedback.lightImpact();
    final buffer = StringBuffer();
    buffer.writeln('🧾 *DiviCuenta - Resumen de Pago*');
    buffer.writeln('─────────────────────────────');
    buffer.writeln('👥 Personas: $_peopleCount');
    buffer.writeln('💵 Subtotal: ${CurrencyHelper.format(_billAmount, symbol: widget.currency)}');
    if (_taxAmount > 0) {
      buffer.writeln('📊 Impuesto ($_currentTaxPercent%): ${CurrencyHelper.format(_taxAmount, symbol: widget.currency)}');
    }
    if (_tipAmount > 0) {
      buffer.writeln('🎁 Propina ($_currentTipPercent%): ${CurrencyHelper.format(_tipAmount, symbol: widget.currency)}');
    }
    buffer.writeln('💰 *Total Factura:* ${CurrencyHelper.format(_grandTotal, symbol: widget.currency)}');
    buffer.writeln('─────────────────────────────');
    buffer.writeln('👉 *CADA UNO PAGA:* ${CurrencyHelper.format(_finalPerPerson, symbol: widget.currency)}');
    if (_roundUp && _extraRounding > 0) {
      buffer.writeln('   *(Redondeado al entero superior)*');
    }
    buffer.writeln('─────────────────────────────');
    buffer.writeln('Calculado con DiviCuenta ✨');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('¡Resumen copiado para compartir!'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Result Card
          _buildHeroResultCard(theme, isDark),

          const SizedBox(height: 18),

          // Total de la cuenta input card
          _buildBillInputCard(theme, isDark),

          const SizedBox(height: 14),

          // Number of people card
          _buildPeopleSelectorCard(theme, isDark),

          const SizedBox(height: 14),

          // Tip selector card
          _buildTipSelectorCard(theme, isDark),

          const SizedBox(height: 14),

          // Tax / IVA selector card
          _buildTaxSelectorCard(theme, isDark),

          const SizedBox(height: 14),

          // Round up option card
          _buildRoundUpCard(theme, isDark),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _billAmount > 0 ? _copySummary : null,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Compartir'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  side: BorderSide(color: theme.colorScheme.outline.withAlpha(70)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeroResultCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F766E), const Color(0xFF134E4A)]
              : [const Color(0xFF0D9488), const Color(0xFF059669)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withAlpha(isDark ? 50 : 80),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.groups_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$_peopleCount ${_peopleCount == 1 ? "persona" : "personas"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_roundUp && _extraRounding > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Redondeado',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'CADA PERSONA PAGA',
            style: TextStyle(
              color: Color(0xFFCCFBF1),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyHelper.format(_finalPerPerson, symbol: widget.currency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildHeroSubMetric(
                  'Subtotal c/u',
                  CurrencyHelper.format(
                    _peopleCount > 0 ? _billAmount / _peopleCount : 0,
                    symbol: widget.currency,
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white.withAlpha(40)),
                _buildHeroSubMetric(
                  'Propina c/u',
                  CurrencyHelper.format(
                    _peopleCount > 0 ? _tipAmount / _peopleCount : 0,
                    symbol: widget.currency,
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white.withAlpha(40)),
                _buildHeroSubMetric(
                  'Total General',
                  CurrencyHelper.format(_grandTotal, symbol: widget.currency),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSubMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFCCFBF1),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillInputCard(ThemeData theme, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Total de la Cuenta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _billController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
              ],
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: Center(
                    widthFactor: 1.0,
                    child: Text(
                      widget.currency,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                hintText: '0.00',
                suffixIcon: _billController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _billController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleSelectorCard(ThemeData theme, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.group_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Número de Personas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$_peopleCount',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _peopleCount > 1
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() => _peopleCount--);
                        }
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                Expanded(
                  child: Slider(
                    value: _peopleCount.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: theme.colorScheme.primary,
                    label: '$_peopleCount',
                    onChanged: (val) {
                      setState(() => _peopleCount = val.round());
                    },
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _peopleCount < 50
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() => _peopleCount++);
                        }
                      : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick preset pills for diners
            Wrap(
              spacing: 8,
              children: [2, 3, 4, 5, 6, 8, 10].map((count) {
                final isSelected = _peopleCount == count;
                return ChoiceChip(
                  label: Text('$count'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _peopleCount = count);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSelectorCard(ThemeData theme, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.volunteer_activism_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Propina',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyHelper.format(_tipAmount, symbol: widget.currency),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tipPresets.map((pct) {
                  final isSelected = !_isCustomTip && _tipPercentage == pct;
                  return ChoiceChip(
                    label: Text('${pct.toInt()}%'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _tipPercentage = pct;
                          _isCustomTip = false;
                        });
                      }
                    },
                  );
                }),
                ChoiceChip(
                  label: const Text('Personalizado'),
                  selected: _isCustomTip,
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _isCustomTip = true);
                    }
                  },
                ),
              ],
            ),
            if (_isCustomTip) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customTipController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Porcentaje de propina personalizado',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSelectorCard(ThemeData theme, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.account_balance_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Impuesto / IVA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  _taxIncludedInBill
                      ? 'Incluido'
                      : CurrencyHelper.format(_taxAmount, symbol: widget.currency),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _taxIncludedInBill ? Colors.grey : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('El impuesto ya está incluido en la cuenta'),
              subtitle: const Text('No sumar porcentaje adicional al total'),
              value: _taxIncludedInBill,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _taxIncludedInBill = val);
              },
            ),
            if (!_taxIncludedInBill) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._taxPresets.map((pct) {
                    final isSelected = !_isCustomTax && _taxPercentage == pct;
                    return ChoiceChip(
                      label: Text('${pct.toInt()}%'),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _taxPercentage = pct;
                            _isCustomTax = false;
                          });
                        }
                      },
                    );
                  }),
                  ChoiceChip(
                    label: const Text('Personalizado'),
                    selected: _isCustomTax,
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _isCustomTax = true);
                      }
                    },
                  ),
                ],
              ),
              if (_isCustomTax) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customTaxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Porcentaje de impuesto personalizado',
                    suffixText: '%',
                    prefixIcon: Icon(Icons.percent_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoundUpCard(ThemeData theme, bool isDark) {
    return Card(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.arrow_upward_rounded, color: theme.colorScheme.secondary, size: 20),
        ),
        title: const Text(
          'Redondear al entero superior',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _roundUp && _extraRounding > 0
              ? 'Excedente total: ${CurrencyHelper.format(_extraRounding, symbol: widget.currency)}'
              : 'Facilita pagar sin centavos en efectivo o transferencias',
          style: TextStyle(
            fontSize: 12,
            color: _roundUp && _extraRounding > 0 ? theme.colorScheme.primary : null,
            fontWeight: _roundUp && _extraRounding > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        value: _roundUp,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          setState(() => _roundUp = val);
        },
      ),
    );
  }
}
